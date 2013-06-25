

#import "HPCSAuthorizedHTTPClient.h"

@implementation HPCSAuthorizedHTTPClient {
}

- (void) setAuthorizationHeaderWithToken:(NSString *)token
{
  [self setDefaultHeader:@"X-Auth-Token" value:token];
}


- (void) clearAuthorizationHeader
{
  [self setDefaultHeader:@"X-Auth-Token" value:nil];
}


@end
