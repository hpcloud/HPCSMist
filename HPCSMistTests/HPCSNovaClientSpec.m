#import "Kiwi.h"
#import "HPCSIdentityClient.h"
#import "OHHTTPStubs.h"
#import "AFNetworking.h"
#import "KWSpec+WaitFor.h"

//TODO failures should have userInfo["NSError"] == the error

SPEC_BEGIN(ComputeClientSpec)

    describe(@"HPCSNovaClient", ^{
      __block BOOL requestCompleted = NO;;

      __block HPCSComputeClient *client = nil;
      __block HPCSIdentityClient *identityClient = nil;
      beforeEach(^{
        [OHHTTPStubs setEnabled:YES];
        [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
          if ([request.URL.absoluteString hasSuffix:@"/v2.0/tokens"]) {
            NSString *basename = [request.URL.absoluteString lastPathComponent];
            NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
            id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
            return stubResponse;
          } else {
            return nil; // Don't stub
          }
        }];

        NSString *userName = @"abc";
        NSString *password = @"password";
        NSString *tenantId = @"12345";

        identityClient = [[HPCSIdentityClient alloc] initWithUsername:userName andPassword:password andTenantId:tenantId];

        NSArray __block *authResult;
        [identityClient authenticate:^(NSArray *serviceCatalog) {
          authResult = serviceCatalog;

        } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {

        }];

        while (authResult == nil) {
          // run runloop so that async dispatch can be handled on main thread AFTER the operation has
          // been marked as finished (even though the call backs haven't finished yet).
          [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                   beforeDate:[NSDate date]];
        }

        [[authResult shouldNot] beEmpty];
        client = [identityClient computeClient];

      });
      afterEach(^{
        [OHHTTPStubs removeLastRequestHandler];
         requestCompleted = NO;
      });

      context(@"after authenticating", ^{
        it(@"sets the identityClient", ^{
          [client.identityClient shouldNotBeNil];
        });
        it(@"sets the authheader", ^{
          [[client defaultValueForHeader:@"X-Auth-Token"] shouldNotBeNil];
        });
        it(@"sets the Accept header to json", ^{
          [[[client defaultValueForHeader:@"Accept"]should] equal:@"application/json"];
        });
      });
      context(@"when you want to see the images available", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/images"]) {
              NSString *basename = [request.URL.absoluteString lastPathComponent];
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];

        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });

        it(@"allows you to get the list", ^{
          [client shouldNotBeNil];
          NSArray __block *result;
          [client images:^(NSArray *records) {
            result = records;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {

          }];

          while (result == nil) {
            // run runloop so that async dispatch can be handled on main thread AFTER the operation has
            // been marked as finished (even though the call backs haven't finished yet).
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate date]];
          }

          [[result shouldNot] beEmpty];

        });
        context(@"and you want to see details about an image", ^{
          beforeEach(^{
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
              if ([request.URL.absoluteString hasSuffix:@"/images/1"]) {
                NSString *basename = @"image_details";
                NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
                return stubResponse;
              } else {
                return nil; // Don't stub
              }
            }];

          });
          afterEach(^{
            [OHHTTPStubs removeLastRequestHandler];
          });

          it(@"shows you the details", ^{
            NSArray __block *result;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"imageId", nil];
            [client imageDetailsFor:attribs success:^(id imageInfo) {
              result = imageInfo;
            } failure:^(NSHTTPURLResponse *response, NSError *error) {

            }];

            while (result == nil) {
              // run runloop so that async dispatch can be handled on main thread AFTER the operation has
              // been marked as finished (even though the call backs haven't finished yet).
              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                       beforeDate:[NSDate date]];
            }

            [[result shouldNot] beEmpty];

          });

        });
      });
      context(@"and you want to see flavors available", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/flavors"]) {
              NSString *basename = [request.URL.absoluteString lastPathComponent];
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];

        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });

        it(@"allows you to get the list", ^{
          [client shouldNotBeNil];
          NSArray __block *result;

          [client flavors:^(NSArray *records) {
            result = records;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {

          }];

          while (result == nil) {
            // run runloop so that async dispatch can be handled on main thread AFTER the operation has
            // been marked as finished (even though the call backs haven't finished yet).
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate date]];
          }

          [[result shouldNot] beEmpty];
          [[result should] haveCountOf:6];

        });
        context(@"and you want to see flavor details", ^{
          beforeEach(^{
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
              if ([request.URL.absoluteString hasSuffix:@"/flavors/1"]) {
                NSString *basename = @"flavor_details";
                NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
                return stubResponse;
              } else {
                return nil; // Don't stub
              }
            }];

          });
          afterEach(^{
            [OHHTTPStubs removeLastRequestHandler];
          });

          it(@"shows you the details", ^{
            NSArray __block *result;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"flavorId", nil];

            [client flavorDetailsFor:attribs success:^(id flavorInfo) {
              result = flavorInfo;
            } failure:^(NSHTTPURLResponse *response, NSError *error) {

            }];

            while (result == nil) {
              // run runloop so that async dispatch can be handled on main thread AFTER the operation has
              // been marked as finished (even though the call backs haven't finished yet).
              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                       beforeDate:[NSDate date]];
            }

            [[result shouldNot] beEmpty];

          });

        });


      });
      context( @"#servers", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/servers"] && [request.HTTPMethod isEqualToString:@"GET"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
             NSError __block *err;
             [client servers:^(NSArray *records) {
                 requestCompleted = YES;

              } failure:^(NSHTTPURLResponse *response, NSError *error) {
                  requestCompleted = YES;
                  err = error;
                }
                 ];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context( @"#terminateServer:", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/servers/1"] && [request.HTTPMethod isEqualToString:@"DELETE"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
            NSError __block *err;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];
           
            [client terminateServer:attribs success:nil failure:^(NSHTTPURLResponse *response, NSError *error){
              err = error;
            } ];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context( @"#serverDetailsFor:", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/servers/1"] && [request.HTTPMethod isEqualToString:@"DELETE"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
            NSError __block *err;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];
            [client serverDetailsFor:attribs success:nil failure:^(NSHTTPURLResponse *response, NSError *error) {
              err = error;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context( @"#flavors", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/flavors"]) {
                NSString *basename = @"nonexistant";
                NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
                id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
                return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
            NSError __block *err;

            [client flavors:nil failure:^(NSHTTPURLResponse *response, NSError *error) {
              err = error;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context( @"#flavorDetailsFor:", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/flavors/1"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
            NSError __block *err;

            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"flavorId", nil];

            [client flavorDetailsFor:attribs success:nil failure:^(NSHTTPURLResponse *response, NSError *error) {
                err = error;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context( @"#images", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/images"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
            NSError __block *err;

            [client images:nil failure:^(NSHTTPURLResponse *response, NSError *error) {
              err = error;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context( @"#imageDetailsFor:", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/images/1"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });
        context(@"error", ^{
          it(@"sets NSError appropriately", ^{
            NSError __block *err;

            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"imageId", nil];
            [client imageDetailsFor:attribs success:nil  failure:^(NSHTTPURLResponse *response, NSError *error) {
               err = error;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];
            [err shouldNotBeNil];


          });
        });

      });
      context(@"and you want to see the servers available", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/servers"]) {
              NSString *basename = [request.URL.absoluteString lastPathComponent];
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];

        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });

        it(@"allows you to get the list", ^{
          [client shouldNotBeNil];
          NSArray __block *result;

          [client servers:^(NSArray *records) {
            result = records;
          } failure:nil];

          while (result == nil) {
            // run runloop so that async dispatch can be handled on main thread AFTER the operation has
            // been marked as finished (even though the call backs haven't finished yet).
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate date]];
          }

          [[result shouldNot] beEmpty];
          [[result should] haveCountOf:4];

        });

        context(@"and you want to see details on a server", ^{
          beforeEach(^{
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
              if ([request.URL.absoluteString hasSuffix:@"/servers/1"]) {
                NSString *basename = @"server_details";
                NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
                return stubResponse;
              } else {
                return nil; // Don't stub
              }
            }];

          });
          afterEach(^{
            [OHHTTPStubs removeLastRequestHandler];
          });
          it(@"gives you the details", ^{
            NSArray __block *result;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];

            [client serverDetailsFor:attribs success:^(id serverInfo) {
              result = serverInfo;
            } failure:^(NSHTTPURLResponse *response, NSError *error) {

            }];

            while (result == nil) {
              // run runloop so that async dispatch can be handled on main thread AFTER the operation has
              // been marked as finished (even though the call backs haven't finished yet).
              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                       beforeDate:[NSDate date]];
            }

            [[result shouldNot] beEmpty];

          });

        });
      });
      context(@"and you want to terminate a server", ^{
        beforeEach(^{
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"/servers/1"] && [request.HTTPMethod isEqualToString:@"DELETE"]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              NSDictionary* headers = [NSDictionary dictionaryWithObject:@"text/json" forKey:@"Content-Type"];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:204 responseTime:0.1 headers:headers];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];

        });
        afterEach(^{
          [OHHTTPStubs removeLastRequestHandler];
        });


        it(@"sends a 204 with no body",^{
          NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];
          NSHTTPURLResponse * __block success;
          [client terminateServer:attribs success:^(NSHTTPURLResponse *response){
            success = response;
          } failure:^(NSHTTPURLResponse *response, NSError *error){

          } ];
          while (success == nil) {
            // run runloop so that async dispatch can be handled on main thread AFTER the operation has
            // been marked as finished (even though the call backs haven't finished yet).
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate date]];
          }

          [[theValue(success.statusCode) should] equal:theValue(204)];


        });

      });
    });
    SPEC_END