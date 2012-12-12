//
// Created by mhagedorn on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HPCSAuthorizedHTTPClient.h"


@implementation HPCSAuthorizedHTTPClient {

}

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
  [self setDefaultHeader:@"X-Auth-Token" value:token];
}

- (void)clearAuthorizationHeader {
  [self setDefaultHeader:@"X-Auth-Token" value:nil];
}


@end