#import "Kiwi.h"
#import "HPCSIdentityClient.h"
#import "OHHTTPStubs.h"
#import "AFNetworking.h"
#import "KWSpec+WaitFor.h"
#import "HPCSCDNClient.h"

//TODO failures should have userInfo["NSError"] == the error

SPEC_BEGIN(ComputeClientSpec)

    describe(@"HPCSNovaClient", ^{
      __block HPCSComputeClient *client = nil;
      __block HPCSIdentityClient *identityClient = nil;
      __block BOOL requestCompleted = NO;

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

      });
      afterEach(^{
        [OHHTTPStubs removeLastRequestHandler];
         requestCompleted = NO;
      });

      it(@"should authenticate", ^{
        NSString *userName = @"abc";
        NSString *password = @"password";
        NSString *tenantId = @"12345";

        identityClient = [[HPCSIdentityClient alloc] initWithUsername:userName andPassword:password andTenantId:tenantId];

        NSArray __block *authResult;
        [identityClient authenticate:^(NSArray *serviceCatalog) {
          authResult = serviceCatalog;
          requestCompleted = YES;

        } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
          requestCompleted = YES;
        }];


        [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
          return requestCompleted;
        }];

        [[authResult shouldNot] beEmpty];
        client = [identityClient computeClient];
      });


      context(@"after creation",^{
          it(@"should be a HPCSNovaClient",^{
              [[client should] beKindOfClass:[HPCSComputeClient class]];
          });
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
        it(@"returns a singleton", ^{
         HPCSComputeClient *a = [identityClient computeClient];
         HPCSComputeClient *b = [identityClient computeClient];
         [[a should] beIdenticalTo:b];
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
          requestCompleted = NO;
        });

        it(@"allows you to get the list", ^{
          [client shouldNotBeNil];
          NSArray __block *result;
          [client images:^(NSArray *records) {
            result = records;
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {

          }];

          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[result shouldNot] beEmpty];

        });

        context(@"and there is an error",^{
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
          it(@"returns an NSError", ^{
            NSError __block *err;
            [client images:nil
                   failure:^(NSHTTPURLResponse *response, NSError *error) {
                     err = error;
                     requestCompleted = YES;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [err shouldNotBeNil];

          }) ;
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
              requestCompleted = YES;
            } failure:^(NSHTTPURLResponse *response, NSError *error) {

            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [[result shouldNot] beEmpty];

          });

          context(@"and there is an error",^{
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
            it(@"returns an NSError", ^{
              NSError __block *err;
              NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"imageId", nil];
              [client imageDetailsFor:attribs success:^(id imageInfo) {

              } failure:^(NSHTTPURLResponse *response, NSError *error) {
                requestCompleted = YES;
                err = error;
              }];

              [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                return requestCompleted;
              }];

              [err shouldNotBeNil];

            }) ;
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
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {

          }];

          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[result shouldNot] beEmpty];
          [[result should] haveCountOf:6];

        });

        context(@"and there is an error",^{
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
          it(@"returns an NSError", ^{
            NSError __block *err;

            [client flavors:nil
                    failure:^(NSHTTPURLResponse *response, NSError *error) {
                      err = error;
                      requestCompleted = YES;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [err shouldNotBeNil];

          }) ;
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
            requestCompleted = NO;
          });

          it(@"shows you the details", ^{
            NSArray __block *result;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"flavorId", nil];

            [client flavorDetailsFor:attribs success:^(id flavorInfo) {
              result = flavorInfo;
              requestCompleted = YES;
            } failure:^(NSHTTPURLResponse *response, NSError *error) {

            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [[result shouldNot] beEmpty];

          });

          context(@"and there is an error",^{
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
            it(@"returns an NSError", ^{
              NSError __block *err;
              NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"flavorId", nil];

              [client flavorDetailsFor:attribs success:nil
                               failure:^(NSHTTPURLResponse *response, NSError *error) {
                                 err = error;
                                 requestCompleted = YES;

              }];

              [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                return requestCompleted;
              }];

              [err shouldNotBeNil];

            }) ;
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
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {

          }];

          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[result shouldNot] beEmpty];
          [[result should] haveCountOf:4];

        });
        context(@"and there is an error",^{
          beforeEach(^{
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
              if ([request.URL.absoluteString hasSuffix:@"/servers"]) {
                NSString *basename = @"nothere";
                NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:500 responseTime:0.001 headers:nil];
                return stubResponse;
              } else {
                return nil; // Don't stub
              }
            }];
          });
          afterEach(^{
            [OHHTTPStubs removeLastRequestHandler];
          });
          it(@"returns an NSError", ^{
            NSError __block *err;
            [client servers:nil
                    failure:^(NSHTTPURLResponse *response, NSError *error) {
              err = error;
            }];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [err shouldNotBeNil];

          }) ;
        }) ;
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
              requestCompleted  = YES;
            } failure:^(NSHTTPURLResponse *response, NSError *error) {

            }];
            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [[result shouldNot] beEmpty];

          });

          context(@"and there is an error",^{
            beforeEach(^{
              [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                if ([request.URL.absoluteString hasSuffix:@"/servers/1"]) {
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
            it(@"returns an NSError", ^{
              NSError __block *err;
              NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];

              [client serverDetailsFor:attribs
                               success:nil
                               failure:^(NSHTTPURLResponse *response, NSError *error) {
                                 err = error;
                                 requestCompleted = YES;
                               }];


                [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                  return requestCompleted;
                }];

                [err shouldNotBeNil];

              }) ;
          }) ;

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
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error){

          } ];
          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[theValue(success.statusCode) should] equal:theValue(204)];

        });

        context(@"and there is an error",^{
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
          it(@"returns an NSError", ^{
            NSError __block *err;
            NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];
            [client terminateServer:attribs
                            success:nil
                            failure:^(NSHTTPURLResponse *response, NSError *error){
                              requestCompleted = YES;
                              err = error;

            } ];

            [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
              return requestCompleted;
            }];

            [err shouldNotBeNil];

          }) ;
        }) ;

      });
    });
    SPEC_END