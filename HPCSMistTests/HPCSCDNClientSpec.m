//
// Created by mhagedorn on 3/26/13.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "Kiwi.h"
#import "HPCSCDNClient.h"
#import "OHHTTPStubs.h"
#import "HPCSIdentityClient.h"
#import "KWSpec+WaitFor.h"


SPEC_BEGIN(CDNClientSpec)

  describe(@"HPCSCDNClientSpec", ^{
//    beforeEach(^{
//    __block HPCSCDNClient *client = nil;
//    __block HPCSIdentityClient *identityClient = nil;
//    __block BOOL requestCompleted = NO;
//
//     beforeAll(^{
//      [OHHTTPStubs setEnabled:YES];
//      [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
//        if ([request.URL.absoluteString hasSuffix:@"/v2.0/tokens"]) {
//          NSString *basename = @"tokens";
//          NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
//          id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
//          return stubResponse;
//        } else {
//          return nil; // Don't stub
//        }
//      }];
//
//      NSString *userName = @"abc";
//      NSString *password = @"password";
//      NSString *tenantId = @"12345";
//
//      identityClient = [[HPCSIdentityClient alloc] initWithUsername:userName andPassword:password andTenantId:tenantId];
//
//      NSArray __block *authResult;
//      [identityClient authenticate:^(NSArray *serviceCatalog) {
//        authResult = serviceCatalog;
//        requestCompleted = YES;
//
//      } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
//        requestCompleted = YES;
//      }];
//
//
//      [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
//        return requestCompleted;
//      }];
//
//      [[authResult shouldNot] beEmpty];
//      client = [identityClient cdnClient];
//      [[client shouldNot] beEmpty];
//
//
//    });
//
//    afterAll(^{
//      [OHHTTPStubs removeLastRequestHandler];
//      requestCompleted = NO;
//    });
    context(@"after authenticating", ^{

      context(@"list CDN enabled containers", ^{
//        beforeEach(^{
//          [OHHTTPStubs setEnabled:YES];
//          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
//            if ([request.URL.absoluteString hasSuffix:@"72020596871800/"]) {
//              NSString *basename = @"cdnContainerList";
//              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
//              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
//              return stubResponse;
//            }else if([request.URL.absoluteString hasSuffix:@"enabled_only=true/"]){
//              NSString *basename = @"cdnOnlyContainerList";
//              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
//              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
//              return stubResponse;
//            } else {
//              return nil; // Don't stub
//            }
//          }];
//        });
//        afterEach(^{
//          [OHHTTPStubs removeLastRequestHandler];
//        });
//
//        it(@"gives you the list", ^{
//          NSArray __block *result;
//          [client cdnContainers:^(NSHTTPURLResponse *responseObject, NSArray *records) {
//            requestCompleted = YES;
//            result = records;
//          } failure:nil];
//
//
//          [KWSpec waitWithTimeout:3.0 forCondition:^BOOL() {
//            return requestCompleted;
//          }];
//
//          [[result should] haveCountOf:10];
//
//        });
//
//        context(@"enabled_only=true", ^{
//          it(@"gives you only cdn containers", ^{
//              NSString *result = @"5";
//              [[result should] equal:@"6"];
//          });
//        });
//
//      });
//
//
//      });
//
      it(@"Get CDN Enabled Container Metadata", ^{

      });

      it(@"Update CDN Enabled Container Metadata", ^{


      });

      it(@"Delete CDN Enabled Container", ^{

      });
//
    });
  });
});

SPEC_END