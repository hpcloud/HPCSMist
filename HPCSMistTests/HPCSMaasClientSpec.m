//
//  HPCSSwiftClientSpec.m
//  HPCSIOSSampler
//
//  Created by Mike Hagedorn on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "HPCSIdentityClient.h"
#import "Environment.h"
#import "OHHTTPStubs.h"
#import "KWSpec+WaitFor.h"
#import "KeychainWrapper.h"
#import "HPCSMaasClient.h"


//static NSMutableArray *notifications;

SPEC_BEGIN(MaasClientSpec)

    describe(@"HPCSMaasClient", ^{
        __block HPCSMaasClient *client = nil;
        __block HPCSIdentityClient *identityClient = nil;
        __block BOOL requestCompleted = NO;

        //Stub out the call to CS
        beforeEach(^{
            [OHHTTPStubs setEnabled:YES];
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                if ([request.URL.absoluteString hasSuffix:@"/v2.0/tokens"]) {
                    NSString *basename = @"tokens2";
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

        context(@"when resolving maas service",^{

            it(@"should authenticate and provide a service client", ^{
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
                client = [identityClient monitoringClient];
                [[client shouldNot] beNil];

            });

        });
        context(@"when you want to see the endpoints available", ^{
            beforeEach(^{
                [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                    if ([request.URL.absoluteString hasSuffix:@"/endpoints"]) {
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
                [client endpoints:^(NSArray *records) {
                    result = records;
                    requestCompleted = YES;
                }
                          failure:nil];


                [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
                    return requestCompleted;
                }];

                [[result shouldNot] beEmpty];

            });

            context(@"and there is an error",^{
                beforeEach(^{
                    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                        if ([request.URL.absoluteString hasSuffix:@"/endpoints"]) {
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
                    [client endpoints:nil
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
            context(@"and you want to see details about an endpoint", ^{
                beforeEach(^{
                    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
                        if ([request.URL.absoluteString hasSuffix:@"/endpoints/1"]) {
                            NSString *basename = @"endpoint_details";
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
                    NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"endpointId", nil];
                    [client endpointDetailsFor:attribs success:^(id endpointInfo) {
                        result = endpointInfo;
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
                            if ([request.URL.absoluteString hasSuffix:@"/endpoints/1"]) {
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
                        NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"endpointId", nil];
                        [client endpointDetailsFor:attribs success:^(id imageInfo) {

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
    });





SPEC_END


