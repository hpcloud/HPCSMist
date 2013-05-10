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
    });





SPEC_END


