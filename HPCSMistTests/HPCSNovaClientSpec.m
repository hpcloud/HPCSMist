#import "Kiwi.h"
#import "HPCSIdentityClient.h"
#import "OHHTTPStubs.h"
#import "AFNetworking.h"
#import "KWSpec+WaitFor.h"
#import "HPCSCDNClient.h"

//TODO failures should have userInfo["NSError"] == the error

SPEC_BEGIN(ComputeClientSpec)


     void  (^stubPath) (NSString *, NSString *, NSNumber * ) = ^void (NSString *pathName, NSString *filename, NSNumber *statusCode) {
       [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
         if ([request.URL.absoluteString hasSuffix:pathName]) {
           return YES;
         } else  {
           return NO;
         }
       } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
         NSString *basename = filename;
         if(!basename){
           basename = [request.URL.absoluteString lastPathComponent];
         }
         NSString* fullName = [NSString stringWithFormat:@"%@.json",basename];
         NSNumber *_statusCode = statusCode;
         if(!_statusCode){
           _statusCode = [NSNumber numberWithInteger:200];
         }
         id stubResponse;

         if(!OHPathForFileInBundle(fullName, nil)){

           stubResponse = [OHHTTPStubsResponse responseWithData:nil
                                                      statusCode:[_statusCode integerValue]
                                                         headers:@{@"Content-Type" : @"text/json"}];

         }else{
           stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName,nil)
                                                           statusCode:[_statusCode integerValue]
                                                              headers:@{@"Content-Type":@"text/json"}];

         }
         [stubResponse setResponseTime:0.2];
         return stubResponse;
       }];
    };




    void  (^stubDeletePath) (NSString *, NSString *, NSNumber * ) = ^void (NSString *pathName, NSString *filename, NSNumber *statusCode) {
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if ([request.URL.absoluteString hasSuffix:pathName] && [request.HTTPMethod isEqualToString:@"DELETE"]) {
          return YES;
        } else  {
          return NO;
        }
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)  {
        NSString *basename = filename;
        if(!basename){
          basename = [request.URL.absoluteString lastPathComponent];
        }
        NSString* fullName = [NSString stringWithFormat:@"%@.json",basename];
        NSNumber *_statusCode = statusCode;
        if(!_statusCode){
          _statusCode = [NSNumber numberWithInteger:200];
        }
        id stubResponse;
        if(!OHPathForFileInBundle(fullName, nil)){
          stubResponse = [OHHTTPStubsResponse responseWithData:nil
                                                    statusCode:[_statusCode integerValue]
                                                       headers:@{@"Content-Type" : @"text/json"}];
        }else{
          stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName,nil)
                                                             statusCode:[_statusCode integerValue]
                                                                headers:@{@"Content-Type":@"text/json"}];

        }

        return stubResponse;
      }];
    };

    describe(@"HPCSNovaClient", ^{
      __block HPCSComputeClient *client = nil;
      __block HPCSIdentityClient *identityClient = nil;
      __block BOOL requestCompleted = NO;

      beforeEach(^{
        [OHHTTPStubs setEnabled:YES];
        stubPath(@"/v2.0/tokens",NULL,NULL);
      });

      afterEach(^{
        [OHHTTPStubs removeLastStub];
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
          stubPath(@"/images",NULL,NULL);
          requestCompleted = NO;
        });

        afterEach(^{
          [OHHTTPStubs removeLastStub];
        });

        it(@"allows you to get the list", ^{
          [client shouldNotBeNil];
          NSArray __block *result;
          [client images:^(NSArray *records) {
            result = records;
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {
            requestCompleted = YES;
          }];

          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[result shouldNot] beEmpty];

        });

        context(@"and there is an error",^{
          beforeEach(^{
            stubPath(@"/images",@"nonexistant", [NSNumber numberWithInteger:500]);
          });

          afterEach(^{
            [OHHTTPStubs removeLastStub];
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
            stubPath(@"/images/1",@"image_details",NULL);
          });

          afterEach(^{
            [OHHTTPStubs removeLastStub];
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
              stubPath(@"/images/1",@"nonexistant", [NSNumber numberWithInteger:500]);
              requestCompleted = NO;
            });

            afterEach(^{
              [OHHTTPStubs removeLastStub];
            });

            it(@"returns an NSError", ^{
              NSError __block *err;
              NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"imageId", nil];
              [client imageDetailsFor:attribs success:^(id imageInfo) {
                NSLog(@"should not be here");
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
          stubPath(@"/flavors",NULL,NULL);
          requestCompleted = NO;
        });

        afterEach(^{
          [OHHTTPStubs removeLastStub];

        });

        it(@"has a valid client",^{
            [client shouldNotBeNil];
        });

        it(@"should return a result", ^{

          NSArray __block *result = nil;

          [client flavors:^(NSArray *records) {
            result = records;
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {
              NSLog(@'got there.. oopps');
          }];

          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[result shouldNot] beEmpty];


        });

        it(@"should return 6 things", ^{

          NSArray __block *result = nil;

          [client flavors:^(NSArray *records) {
            result = records;
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error) {

          }];

          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[result should] haveCountOf:6];

        });


        context(@"and there is an error",^{
          beforeEach(^{
            [OHHTTPStubs removeLastStub];
            stubPath(@"/flavors",@"nonexistant",[NSNumber numberWithInteger:500]);
            requestCompleted = NO;
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
            stubPath(@"/flavors/1",@"flavor_details",NULL);
            requestCompleted = NO;
          });
          afterEach(^{
            [OHHTTPStubs removeLastStub];
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
              stubPath(@"/flavors/1",@"nonexistant",[NSNumber numberWithInteger:500]);
            });

            afterEach(^{
              [OHHTTPStubs removeLastStub];
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
         stubPath(@"/servers",NULL, NULL);
         requestCompleted = NO;
        });

        afterEach(^{
          [OHHTTPStubs removeLastStub];
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
            stubPath(@"/servers",@"nonexistant", [NSNumber numberWithInteger:500]);
          });

          afterEach(^{
            [OHHTTPStubs removeLastStub];
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
            stubPath(@"/servers/1",@"server_details",NULL);
            requestCompleted = NO;
          });

          afterEach(^{
            [OHHTTPStubs removeLastStub];
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
              [OHHTTPStubs removeLastStub];
              stubPath(@"/servers/1",@"nonexistant", [NSNumber numberWithInteger:500]);
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
          stubDeletePath(@"/servers/1",@"nonexistant",[NSNumber numberWithInteger:204]);
          requestCompleted = NO;
        });

        afterEach(^{
          [OHHTTPStubs removeLastStub];
        });

        it(@"sends a 204 with no body",^{
          NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"serverId", nil];
          NSHTTPURLResponse * __block success;
          [client terminateServer:attribs success:^(NSHTTPURLResponse *response){
            success = response;
            requestCompleted = YES;
          } failure:^(NSHTTPURLResponse *response, NSError *error){
            NSLog(@"should not get here");
          } ];
          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
            return requestCompleted;
          }];

          [[theValue(success.statusCode) should] equal:theValue(204)];

        });

        context(@"and there is an error",^{
          beforeEach(^{
            [OHHTTPStubs removeLastStub];
            stubDeletePath(@"/servers/1",@"nonexistant",[NSNumber numberWithInteger:500]);
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