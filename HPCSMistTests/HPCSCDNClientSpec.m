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
    __block HPCSCDNClient *client = nil;
    __block HPCSIdentityClient *identityClient = nil;
    __block BOOL requestCompleted = NO;

     beforeAll(^{
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
        requestCompleted = YES;

      } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
        requestCompleted = YES;
      }];



     while (authResult == nil) {
         // run runloop so that async dispatch can be handled on main thread AFTER the operation has
         // been marked as finished (even though the call backs haven't finished yet).
         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                  beforeDate:[NSDate date]];
     }


      [[authResult shouldNot] beEmpty];
      client = [identityClient cdnClient];
      [[client shouldNot] beNil];


    });

    afterAll(^{
      [OHHTTPStubs removeLastRequestHandler];
      requestCompleted = NO;
    });
    context(@"after authenticating", ^{

      context(@"list CDN enabled containers", ^{
        beforeEach(^{
          [OHHTTPStubs setEnabled:YES];
          [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
            if ([request.URL.absoluteString hasSuffix:@"72020596871800/"]) {
              NSString *basename = @"cdnContainerList";
              NSString *fullName = [NSString stringWithFormat:@"%@.json", basename];
              id stubResponse = [OHHTTPStubsResponse responseWithFile:fullName contentType:@"text/json" responseTime:0.01];
              return stubResponse;
            }else if([request.URL.absoluteString hasSuffix:@"enabled_only=true/"]){
              NSString *basename = @"cdnOnlyContainerList";
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

        it(@"gives you the list", ^{
          requestCompleted = NO;
          NSArray __block *result;

           [client cdnContainers:^(NSHTTPURLResponse *responseObject, NSArray *records) {
               requestCompleted = YES;
               result = records;

           } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
              NSLog(@"boom");
           }];

            while (result == nil) {
                // run runloop so that async dispatch can be handled on main thread AFTER the operation has
                // been marked as finished (even though the call backs haven't finished yet).
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate date]];
            }


          [[theValue([result count]) should] equal:theValue(3)];

        });

      });
//

      pending(@"Get CDN Enabled Container Metadata");

      xit(@"Update CDN Enabled Container Metadata");

      xit(@"Delete CDN Enabled Container");
//
    });
 });

SPEC_END