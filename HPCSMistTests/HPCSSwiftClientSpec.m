//
//  SwiftClientSpec.m
//  HPCSIOSSampler
//
//  Created by Mike Hagedorn on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "HPCSSwiftClient.h"
#import "OHHTTPStubs.h"
#import "HPCSIdentityClient.h"
#import "KWSpec+WaitFor.h"


SPEC_BEGIN(SwiftClientSpec)

      void  (^stubPath) (NSString *pathName, NSString *method,NSString *filename, NSNumber *code ) = ^void (NSString *pathName,NSString *method, NSString *filename, NSNumber *statusCode) {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
          if ([request.URL.absoluteString hasSuffix:pathName] && [request.HTTPMethod isEqualToString:method]) {
            return YES;
          } else {
            return NO;
          }
        }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
          NSString *basename = filename;
          if (!basename) {
            basename = [request.URL.absoluteString lastPathComponent];
          }
          NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
          NSNumber *_statusCode = statusCode;
          if (!_statusCode) {
            _statusCode = [NSNumber numberWithInteger:200];
          }
          id stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName, nil)
                                                             statusCode:[_statusCode integerValue]
                                                                headers:@{@"Content-Type" : @"text/json"}];
          return stubResponse;
        }];
      };


    void  (^stubHeadRequest) (NSString *pathName, NSString *filename, NSNumber *code ) = ^void (NSString *pathName, NSString *filename, NSNumber *statusCode) {
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if ([request.URL.absoluteString hasSuffix:pathName] && [request.HTTPMethod isEqualToString:@"HEAD"]) {
          return YES;
        } else {
          return NO;
        }
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *basename = filename;
        if (!basename) {
          basename = [request.URL.absoluteString lastPathComponent];
        }
        NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
        NSNumber *_statusCode = statusCode;
        if (!_statusCode) {
          _statusCode = [NSNumber numberWithInteger:200];
        }
        id stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName, nil)
                                                           statusCode:[_statusCode integerValue]
                                                              headers:@{@"Content-Type" : @"text/json", @"X-Container-Object-Count" : @"7", @"X-Container-Bytes-Used" : @"12345"}];
        return stubResponse;
      }];
    };



      void (^stubAuthenticate)(void) = ^() {
        stubPath(@"/v2.0/tokens",@"POST", NULL,NULL);
      };

        void (^stubEmptyResponseWithStatusCode)(NSString *suffix, NSString *method, NSInteger code) = ^(NSString *suffix, NSString *method, NSInteger code) {
          stubPath(suffix,method, @"nonexistant",[NSNumber numberWithInteger:code]);
        };

        NSDictionary *(^stubObjectWithName)(NSString *name) = ^NSDictionary *(NSString *name) {
          NSDictionary *attribs = [NSMutableDictionary dictionary];
          [attribs setValue:name forKey:@"name"];
          NSDictionary *parent = [NSMutableDictionary dictionary];
          [parent setValue:@"parent" forKey:@"name"];
          [attribs setValue:parent forKey:@"parent"];
          return attribs;
        };

        NSData *(^createDummyNSDataObject)(int size) = ^NSData *(int size) {
          NSMutableData *theData = [NSMutableData dataWithCapacity:(NSUInteger) size];
          for (unsigned int i = 0; i < size / 4; ++i) {
            u_int32_t randomBits = arc4random();
            [theData appendBytes:(void *) &randomBits length:4];
          }
          return theData;
        };

        describe(@"HPCSSwiftClient", ^{
          __block HPCSSwiftClient *client = nil;
          __block HPCSIdentityClient *identityClient = nil;
          beforeEach(^{
            [OHHTTPStubs setEnabled:YES];
            stubAuthenticate();

            NSString *userName = @"abc";
            NSString *password = @"password";
            NSString *tenantId = @"12345";

            identityClient = [[HPCSIdentityClient alloc] initWithUsername:userName andPassword:password andTenantId:tenantId];

            NSArray __block *authResult;

            [identityClient authenticate:^(NSArray *serviceCatalog) {
              authResult = serviceCatalog;
            }  failure:^(NSHTTPURLResponse *responseObject, NSError *error) {

            }];

            while (authResult == nil) {
              // run runloop so that async dispatch can be handled on main thread AFTER the operation has
              // been marked as finished (even though the call backs haven't finished yet).
              [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                       beforeDate:[NSDate date]];
            }

            [[authResult shouldNot] beEmpty];
            client = [identityClient swiftClient];

          });


          context(@"after creation",^{
            it(@"should be a HPCSSwiftClient",^{
                [[client should] beKindOfClass:[HPCSSwiftClient class]];
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
            context(@"and you are working with containers", ^{
              __block BOOL requestCompleted = NO;
              afterEach(^{
                requestCompleted = NO;
              });
              context(@"and you want to get the top level containers", ^{
                beforeEach(^{
                  [OHHTTPStubs setEnabled:YES];
                  stubPath(@"72020596871800/",@"GET",@"containers",NULL);
                });
                it(@"retrieves the containers", ^{
                  NSArray __block *result;
                  [client containers:^(NSURLResponse *response, NSArray *containersInfo) {
                    requestCompleted = YES;
                    result = containersInfo;
                  }          failure:nil];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[result should] haveCountOf:4];
                });
                context(@"and there is an error", ^{
                  beforeEach(^{
                    stubPath(@"72020596871800/",@"GET",@"nonexistant",[NSNumber numberWithInteger:500]);

                  });

                  it(@"returns an error", ^{
                    NSError __block *listErr;


                    [client containers:^(NSHTTPURLResponse *responseObject, NSArray *records) {
                      requestCompleted = YES;
                    } failure:^(NSHTTPURLResponse *responseObject, NSError *error){
                      requestCompleted = YES;
                      listErr = error;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [listErr shouldNotBeNil];

                  });
                });
              });
              context(@"and you want to save a container", ^{
                beforeEach(^{
                  stubEmptyResponseWithStatusCode(@"test", @"PUT", 201);
                });
                it(@"returns a 201", ^{
                  NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithDictionary:stubObjectWithName(@"test")];

                  NSHTTPURLResponse __block *saveResponse;
                  [client saveContainer:attribs success:^(NSHTTPURLResponse *response) {
                    requestCompleted = YES;
                    saveResponse = response;
                  }             failure:nil];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[theValue(saveResponse.statusCode) should] equal:theValue(201)];

                });
                context(@"and the name already exists", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"test", @"PUT", 202);
                  });
                  it(@"returns a 202", ^{
                    NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithDictionary:stubObjectWithName(@"test")];
                    NSHTTPURLResponse __block *saveResponse;
                    [client saveContainer:attribs success:^(NSHTTPURLResponse *response) {
                      requestCompleted = YES;
                      saveResponse = response;
                    }             failure:nil];
                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [[theValue(saveResponse.statusCode) should] equal:theValue(202)];

                  });
                });
                context(@"and there is an error",^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"test", @"PUT", 500);
                  });
                  it(@"returns an NSError", ^{
                    NSError __block * err;
                    NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithDictionary:stubObjectWithName(@"test")];
                    [client saveContainer:attribs success:^(NSHTTPURLResponse *response) {
                      requestCompleted = YES;
                    }
                     failure:^(NSHTTPURLResponse *operation, NSError *error) {
                       requestCompleted = YES;
                       err = error;
                     }];
                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [err shouldNotBeNil];
                  });
                });
              });
              context(@"and you want to delete a container", ^{
                NSDictionary __block *attribs;
                NSHTTPURLResponse __block *op;
                beforeEach(^{
                  attribs = stubObjectWithName(@"test");

                });
                afterEach(^{
                  op = nil;
                });
                context(@"and the container is not empty", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"test", @"DELETE", 409);
                  });
                  it(@"returns a 409", ^{
                    [client deleteContainer:attribs success:nil failure:^(NSHTTPURLResponse *operation, NSError *error) {
                      requestCompleted = YES;
                      op = operation;
                    }];
                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [[theValue(op.statusCode) should] equal:theValue(409)];


                  });
                });
                context(@"and the container is not found", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"test", @"DELETE", 404);
                  });
                  it(@"returns a 404", ^{
                    [client deleteContainer:attribs success:nil failure:^(NSHTTPURLResponse *operation, NSError *error) {
                      requestCompleted = YES;
                      op = operation;
                    }];
                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [[theValue(op.statusCode) should] equal:theValue(404)];

                  });
                });
                context(@"and its successful", ^{
                  __block BOOL requestCompleted = NO;
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"test", @"DELETE", 204);
                  });
                  afterEach(^{
                    requestCompleted = NO;
                  });
                  it(@"returns a 204", ^{
                    [client deleteContainer:attribs success:^(NSHTTPURLResponse *operation) {
                      requestCompleted = YES;
                      op = operation;

                    }               failure:nil];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [[theValue(op.statusCode) should] equal:theValue(204)];

                  });
                });

              });

              context(@"and you want to get only the metadata of a container", ^{
                beforeEach(^{
                  stubHeadRequest(@"parent",@"nonexistant",[NSNumber numberWithInteger:200]);
                });

                it(@"allows you to get metadata via HEAD", ^{
                  NSDictionary *subject = @{@"name" : @"parent"};
                  NSDictionary __block *headers;
                  [client headContainer:subject success:^(NSHTTPURLResponse *responseObject) {
                    requestCompleted = YES;
                    headers = responseObject.allHeaderFields;

                  }             failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                    requestCompleted = YES;
                  }];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[headers objectForKey:@"X-Container-Bytes-Used"] shouldNotBeNil];
                  [[headers objectForKey:@"X-Container-Object-Count"] shouldNotBeNil];
                  [[client defaultValueForHeader:@"Accept"] shouldNotBeNil];
                });

                context(@"and there is an error",^{
                  beforeEach(^{
                    stubHeadRequest(@"parent",@"nonexistant",[NSNumber numberWithInteger:500]);
                  });
                  it(@"returns an NSError", ^{
                    NSError __block * err;
                    NSDictionary *subject = @{@"name" : @"parent"};
                    [client headContainer:subject success:^(NSHTTPURLResponse *responseObject) {
                      requestCompleted = YES;
                    } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted = YES;
                      err = error;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [err shouldNotBeNil];
                  });
                });
              });

                it(@"allows you to get basic container info via helper method", ^{
                  NSDictionary *subject = @{@"name" : @"parent"};
                  NSDictionary __block *meta;
                  [client headContainer:subject success:^(NSHTTPURLResponse *responseObject) {
                    requestCompleted = YES;
                    meta = [client metaDataFromResponse:responseObject];

                  }             failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                    requestCompleted = YES;
                  }];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[meta objectForKey:@"X-Container-Bytes-Used"] shouldNotBeNil];
                  [[client defaultValueForHeader:@"Accept"] shouldNotBeNil];
                });
              });
            });

            context(@"and you are working with objects", ^{
              __block BOOL requestCompleted = NO;
              NSDictionary __block *subject;
              beforeEach(^{
                subject = stubObjectWithName(@"created");
              });
              afterEach(^{
                subject = nil;
                requestCompleted = NO;
              });
              context((@"and you want the URL of an object"), ^{
                it(@"returns the URL", ^{
                  [[[client urlForObject:subject] should] equal:@"https://az1-region-a.geo-1.objects.hpcloudsvc.com/v1.0/72020596871800/parent/created"];
                });
              });
              context(@"and you want to set metadata on an object", ^{
                beforeEach(^{

                  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    if ([request.URL.absoluteString hasSuffix:@"created"] &&
                        [request.HTTPMethod isEqualToString:@"POST"] &&
                        [[request.allHTTPHeaderFields objectForKey:@"X-Object-Meta-Reviewed"] isEqualToString: @"true"]) {
                      return YES;
                    } else {
                      return NO;
                    }
                  }  withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSString *basename = @'nonexistant';
                    NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                    id stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName, nil)
                                                                       statusCode:202
                                                                          headers:NULL];
                    return stubResponse;
                  }];
                });

                it(@"sends a post request to set it", ^{
                  NSHTTPURLResponse __block  *response;
                  NSDictionary *meta = @{ @"X-Object-Meta-Reviewed": @"true"};
                  [client setObject:subject metadata:meta success:^(NSHTTPURLResponse *responseObject) {
                    response = responseObject;
                    requestCompleted = YES;
                  } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                    requestCompleted= YES;

                  }];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];
                  [response shouldNotBeNil];

                });
                context(@"failure", ^{
                  beforeEach(^{

                    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                      if ([request.URL.absoluteString hasSuffix:@"created"] &&
                          [request.HTTPMethod isEqualToString:@"POST"] &&
                          [[request.allHTTPHeaderFields objectForKey:@"X-Object-Meta-Reviewed"] isEqualToString: @"true"]) {
                        return YES;
                      } else {
                        return NO;
                      }
                    }  withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                      NSString *basename = @'nonexistant';
                      NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                      id stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName, nil)
                                                                         statusCode:404
                                                                            headers:NULL];
                      return stubResponse;
                    }];
                  });


                  it(@"returns an error", ^{
                    NSError __block *localErr;
                    NSDictionary *meta = @{ @"X-Object-Meta-Reviewed": @"true"};
                    [client setObject:subject metadata:meta success:^(NSHTTPURLResponse *responseObject) {
                      requestCompleted = YES;
                    } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted= YES;
                      localErr = error;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [localErr shouldNotBeNil];
                  });

                });

              });
              context(@"and you want to get only the metadata", ^{
                beforeEach(^{

                  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    if ([request.URL.absoluteString hasSuffix:@"parent/created"] && [request.HTTPMethod isEqualToString:@"HEAD"]) {
                      return YES;
                    } else {
                      return NO;
                    }
                  }                   withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSString *basename = @'nonexistant';
                    NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                    id stubResponse = [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fullName, nil)
                                                                       statusCode:200
                                                                          headers: @{@"Content-Type" : @"text/json", @"Content-Length" : @"12345", @"X-Object-Meta-Test" : @"Test"}];
                    return stubResponse;
                  }];
                });
                it(@"allows you to get metadata via HEAD", ^{
                  NSDictionary __block *headers;
                  [client headObject:subject success:^(NSHTTPURLResponse *responseObject) {
                    requestCompleted = YES;
                    headers = responseObject.allHeaderFields;
                  }
                  failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                    requestCompleted = YES;
                  }];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[headers objectForKey:@"X-Object-Meta-Test"] shouldNotBeNil];
                  [[client defaultValueForHeader:@"Accept"] shouldNotBeNil];
                });
                context(@"via the helper method", ^{
                  it(@"returns an error", ^{
                    NSDictionary __block *headers;
                    [client getObjectMetadata:subject success:^(NSHTTPURLResponse *responseObject, NSDictionary *meta) {
                      requestCompleted = YES;
                      headers = meta;
                    }
                    failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted = YES;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [[headers objectForKey:@"X-Object-Meta-Test"] shouldNotBeNil];
                    [[client defaultValueForHeader:@"Accept"] shouldNotBeNil];
                  });
                });
                context(@"and metadata get fails", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"child", @"HEAD", 500);
                  });


                  it(@"returns an error", ^{
                    NSError __block *saveErr;
                    NSMutableDictionary *parentObject = [NSMutableDictionary dictionary];
                    [parentObject setValue:@"parent" forKey:@"name"];
                    NSMutableDictionary *objectToSave = [NSMutableDictionary dictionary];
                    [objectToSave setValue:parentObject forKey:@"parent"];
                    [objectToSave setValue:@"child" forKey:@"name"];
                    [objectToSave setValue:@"image/jpeg" forKey:@"mimeTypeForFile"];
                    [objectToSave setValue:createDummyNSDataObject(430) forKey:@"data"];

                    [client headObject:objectToSave success:^(NSHTTPURLResponse *responseObject) {
                      requestCompleted = YES;
                    }          failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted = YES;
                      saveErr = error;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [saveErr shouldNotBeNil];

                  });
                });
              });
              context(@"for a given container", ^{
                beforeEach(^{
                  [OHHTTPStubs setEnabled:YES];
                  stubPath(@"created",@"GET",@"objects",NULL);
                });

                it(@"list should work", ^{
                  NSArray __block *contents;
                  [client objectsForContainer:subject success:^(NSHTTPURLResponse *response, NSArray *objects) {
                    requestCompleted = YES;
                    contents = objects;
                  }                   failure:nil];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[contents should] haveCountOf:2];
                });

              });
              context(@"for a nonexistent container", ^{
                NSDictionary __block *badSubject;
                beforeEach(^{
                  stubEmptyResponseWithStatusCode(@"nothere", @"GET", 204);
                });

                it(@"list should return nothing", ^{
                  NSArray __block *objectList;
                  badSubject = stubObjectWithName(@"nothere");
                  [client objectsForContainer:badSubject success:^(NSHTTPURLResponse *response, NSArray *objects) {
                    requestCompleted = YES;
                    objectList = objects;
                  }                   failure:nil];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[objectList should] beEmpty];

                });


              });

              context(@"and there is an error", ^{
                NSDictionary __block *badSubject;
                beforeEach(^{
                  stubEmptyResponseWithStatusCode(@"nothere", @"GET", 500);
                });

                it(@"should return an NSError", ^{
                  NSError __block *err;
                  badSubject = stubObjectWithName(@"nothere");
                  [client objectsForContainer:badSubject success:^(NSHTTPURLResponse *response, NSArray *objects) {
                    requestCompleted = YES;
                  }
                  failure:^(NSHTTPURLResponse *resp, NSError *error){
                    requestCompleted = YES;
                    err = error;
                  }];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [err shouldNotBeNil];

                });


              });


              context(@"#delete", ^{
                context(@"for objects that exist", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"created", @"DELETE", 204);
                  });

                  it(@"returns a 204", ^{
                    NSHTTPURLResponse __block *deleteOp;
                    [client deleteObject:subject success:^(NSHTTPURLResponse *response) {
                      requestCompleted = YES;
                      deleteOp = response;
                    }            failure:nil];
                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [[theValue(deleteOp.statusCode) should] equal:theValue(204)];
                  });
                });
                context(@"for objects that dont exist", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"created", @"DELETE", 404);
                  });

                  it(@"returns a 404", ^{
                    NSHTTPURLResponse __block *deleteOp;
                    [client deleteObject:subject success:nil failure:^(NSHTTPURLResponse *response, NSError *error) {
                      requestCompleted = YES;
                      deleteOp = response;
                    }];
                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [[theValue(deleteOp.statusCode) should] equal:theValue(404)];

                  });
                });
              });
              context(@"#save", ^{
                context(@"and it is successful", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"child", @"PUT", 201);
                  });

                  it(@"returns a 201", ^{
                    NSHTTPURLResponse __block *saveOp;
                    NSMutableDictionary *parentObject = [NSMutableDictionary dictionary];
                    [parentObject setValue:@"parent" forKey:@"name"];
                    NSMutableDictionary *objectToSave = [NSMutableDictionary dictionary];
                    [objectToSave setValue:parentObject forKey:@"parent"];
                    [objectToSave setValue:@"child" forKey:@"name"];
                    [objectToSave setValue:@"image/jpeg" forKey:@"mimeTypeForFile"];
                    [objectToSave setValue:createDummyNSDataObject(430) forKey:@"data"];

                    [client saveObject:objectToSave success:^(NSHTTPURLResponse *responseObject) {
                      requestCompleted = YES;
                      saveOp = responseObject;
                    }         progress:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite) {

                    }          failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted = YES;
                      saveOp = responseObject;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];
                    [[theValue(saveOp.statusCode) should] equal:theValue(201)];

                  });
                  context(@"and it fails", ^{
                    beforeEach(^{
                      stubEmptyResponseWithStatusCode(@"child", @"PUT", 500);
                    });

                    it(@"returns an error", ^{
                      NSError __block *saveErr;
                      NSMutableDictionary *parentObject = [NSMutableDictionary dictionary];
                      [parentObject setValue:@"parent" forKey:@"name"];
                      NSMutableDictionary *objectToSave = [NSMutableDictionary dictionary];
                      [objectToSave setValue:parentObject forKey:@"parent"];
                      [objectToSave setValue:@"child" forKey:@"name"];
                      [objectToSave setValue:@"image/jpeg" forKey:@"mimeTypeForFile"];
                      [objectToSave setValue:createDummyNSDataObject(430) forKey:@"data"];

                      [client saveObject:objectToSave success:^(NSHTTPURLResponse *responseObject) {
                        requestCompleted = YES;
                      }         progress:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite) {

                      }          failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                        requestCompleted = YES;
                        saveErr = error;
                      }];

                      [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                        return requestCompleted;
                      }];
                      [saveErr shouldNotBeNil];

                    });
                  });

                  context(@"and you use special chars in object it", ^{
                    beforeEach(^{
                      stubEmptyResponseWithStatusCode(@"created%20object", @"PUT", 201);
                    });

                    it(@"url encodes the name for you", ^{
                      NSHTTPURLResponse __block *saveOp;
                      NSMutableDictionary *parentObject = [NSMutableDictionary dictionary];
                      [parentObject setValue:@"parent" forKey:@"name"];
                      NSMutableDictionary *objectToSave = [NSMutableDictionary dictionary];
                      [objectToSave setValue:parentObject forKey:@"parent"];
                      [objectToSave setValue:@"created object" forKey:@"name"];
                      [objectToSave setValue:@"image/jpeg" forKey:@"mimeTypeForFile"];
                      [objectToSave setValue:createDummyNSDataObject(430) forKey:@"data"];

                      [client saveObject:objectToSave success:^(NSHTTPURLResponse *responseObject) {
                        requestCompleted = YES;
                        saveOp = responseObject;
                      }         progress:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite) {

                      }          failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                        requestCompleted = YES;
                        saveOp = responseObject;
                      }];

                      [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                        return requestCompleted;
                      }];
                      [[theValue(saveOp.statusCode) should] equal:theValue(201)];

                    });
                  });
                });
              });
              context(@"#get", ^{

                context(@"success", ^{

                  NSData __block *remoteData;
                  beforeEach(^{

                    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                      if ([request.URL.absoluteString hasSuffix:@"parent/created"] && [request.HTTPMethod isEqualToString:@"GET"]) {
                        return YES;
                      } else {
                        return NO;
                      }
                    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {

                      id stubResponse = [OHHTTPStubsResponse responseWithData:createDummyNSDataObject(430)
                                                                         statusCode:200
                                                                            headers:@{@"Content-Type" : @"image/jpeg", @"Content-Length" : @"12345"}];
                      return stubResponse;
                    }];

                  });

                  it(@"returns the bytes", ^{
                    [client getObject:subject success:^(NSHTTPURLResponse *responseObject, NSData *data) {
                      requestCompleted = YES;
                      remoteData = data;

                    }         failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted = YES;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [remoteData shouldNotBeNil];

                  });

                });
                context(@"failure", ^{
                  beforeEach(^{
                    stubPath(@"parent/created",@"GET",@"nonexistant",[NSNumber numberWithInteger:500]);
                  });


                  it(@"returns the error", ^{
                    NSError __block *err;
                    [client getObject:subject success:^(NSHTTPURLResponse *responseObject, NSData *data) {
                      requestCompleted = YES;

                    }         failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      requestCompleted = YES;
                      err = error;
                    }];

                    [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                      return requestCompleted;
                    }];

                    [err shouldNotBeNil];

                  });
                });
              });
            });
          });


        SPEC_END


