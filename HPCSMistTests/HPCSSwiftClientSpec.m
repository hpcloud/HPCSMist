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

        void (^stubEmptyResponseWithStatusCode)(NSString *suffix, NSString *method, NSInteger code) = ^(NSString *suffix, NSString *method, NSInteger code) {
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:suffix] && [request.HTTPMethod isEqualToString:method]) {
              NSString *basename = @"nonexistant";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:code responseTime:0.001 headers:nil];
              return stubResponse;
            } else {
              return nil; // Don't stub
            }
          }];
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
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
              if ([request.URL.absoluteString hasSuffix:@"/v2.0/tokens"]) {
                NSString *basename = @"tokens";
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
            }                    failure:^(NSHTTPURLResponse *responseObject, NSError *error) {

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

          afterEach(^{
            [OHHTTPStubs removeLastRequestHandler];
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
                  [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                    if ([request.URL.absoluteString hasSuffix:@"72020596871800/"]) {
                      NSString *basename = @"containers";
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
                    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                      if ([request.URL.absoluteString hasSuffix:@"72020596871800/"] && [request.HTTPMethod isEqualToString:@"GET"]) {
                        NSString *basename = @"nonexistant";
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
                afterEach(^{
                  [OHHTTPStubs removeLastRequestHandler];
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
              });
              context(@"and you want to delete a container", ^{
                NSDictionary __block *attribs;
                NSHTTPURLResponse __block *op;
                beforeEach(^{
                  attribs = stubObjectWithName(@"test");

                });
                afterEach(^{
                  [OHHTTPStubs removeLastRequestHandler];
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
                  [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                    if ([request.URL.absoluteString hasSuffix:@"parent"] && [request.HTTPMethod isEqualToString:@"HEAD"]) {
                      NSString *basename = @"nonexistant";
                      NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                      NSDictionary *headers = @{@"Content-Type" : @"text/json", @"X-Container-Object-Count" : @"7", @"X-Container-Bytes-Used" : @"12345"};
                      id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:200 responseTime:0.1 headers:headers];
                      return stubResponse;
                    } else {
                      return nil; // Don't stub
                    }
                  }];
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
              context(@"and you want to get only the metadata", ^{
                beforeEach(^{
                  [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                    if ([request.URL.absoluteString hasSuffix:@"parent/created"] && [request.HTTPMethod isEqualToString:@"HEAD"]) {
                      NSString *basename = @"nonexistant";
                      NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
                      NSDictionary *headers = @{@"Content-Type" : @"text/json", @"Content-Length" : @"12345", @"X-Object-Meta-Test" : @"Test"};
                      id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName statusCode:200 responseTime:0.1 headers:headers];
                      return stubResponse;
                    } else {
                      return nil; // Don't stub
                    }
                  }];
                });
                it(@"allows you to get metadata via HEAD", ^{
                  NSDictionary __block *headers;
                  [client headObject:subject success:^(NSHTTPURLResponse *responseObject) {
                    requestCompleted = YES;
                    headers = responseObject.allHeaderFields;

                  }          failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                    requestCompleted = YES;
                  }];

                  [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                  }];

                  [[headers objectForKey:@"X-Object-Meta-Test"] shouldNotBeNil];
                  [[client defaultValueForHeader:@"Accept"] shouldNotBeNil];
                });
                context(@"and it fails", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"child", @"HEAD", 500);
                  });
                  afterEach(^{
                    [OHHTTPStubs removeLastRequestHandler];
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
                  [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                    if ([request.URL.absoluteString hasSuffix:@"created"]) {
                      NSString *basename = @"objects";
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
                afterEach(^{
                  [OHHTTPStubs removeLastRequestHandler];
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
              context(@"#delete", ^{
                context(@"for objects that exist", ^{
                  beforeEach(^{
                    stubEmptyResponseWithStatusCode(@"created", @"DELETE", 204);
                  });
                  afterEach(^{
                    [OHHTTPStubs removeLastRequestHandler];
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
                  afterEach(^{
                    [OHHTTPStubs removeLastRequestHandler];
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
                  afterEach(^{
                    [OHHTTPStubs removeLastRequestHandler];
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
                    afterEach(^{
                      [OHHTTPStubs removeLastRequestHandler];
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
                    afterEach(^{
                      [OHHTTPStubs removeLastRequestHandler];
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
                    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                      if ([request.URL.absoluteString hasSuffix:@"parent/created"] && [request.HTTPMethod isEqualToString:@"GET"]) {
                        NSData *remoteData = createDummyNSDataObject(430);
                        NSDictionary *headers = @{@"Content-Type" : @"image/jpeg", @"Content-Length" : @"12345"};
                        id stubResponse = [OHHTTPStubsResponse responseWithData:remoteData statusCode:200 responseTime:0.001 headers:headers];
                        return stubResponse;
                      } else {
                        return nil; // Don't stub
                      }

                    }];

                  });

                  afterEach(^{
                    [OHHTTPStubs removeLastRequestHandler];
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
                    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                      if ([request.URL.absoluteString hasSuffix:@"parent/created"] && [request.HTTPMethod isEqualToString:@"GET"]) {
                        NSDictionary *headers = @{@"Content-Type" : @"image/jpeg", @"Content-Length" : @"12345"};
                        id stubResponse = [OHHTTPStubsResponse responseWithData:nil statusCode:500 responseTime:0.001 headers:headers];
                        return stubResponse;
                      } else {
                        return nil; // Don't stub
                      }
                    }];
                  });

                  afterEach(^{
                    [OHHTTPStubs removeLastRequestHandler];
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
        });


        SPEC_END


