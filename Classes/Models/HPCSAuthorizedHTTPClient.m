

#import "HPCSAuthorizedHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "HPCSIdentityClient.h"


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


// COV_NF_START
+ (id) sharedClient: (HPCSIdentityClient *)identityClient
{
    NSAssert(NO, @" You should always override this to provide the singleton constructor for your service class");
    return nil;
//    static id _sharedClient = nil;

//    static dispatch_once_t oncePredicate;
//
//    dispatch_once(&oncePredicate, ^{
//        //or use the access key id stuff and secret key
//        _sharedClient = [[self alloc] initWithIdentityClient:identityClient];
//    }
//    );
//
//    return _sharedClient;
}
// COV_NF_END

- (NSString *)serviceURL:(HPCSIdentityClient *)identity {
    NSAssert(NO, @" You should always override this to provide the appropriate publicURL endpoint for the specific service");
    return nil;
}



- (id) initWithIdentityClient:(id)identity
{
    self = [super initWithBaseURL:[NSURL URLWithString:[self serviceURL:identity]]];
    self.identityClient = identity;
    if (!self)
    {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    if (self.identityClient)
    {
        HPCSToken *token = (HPCSToken *)[identity token];
        [self setAuthorizationHeaderWithToken:token.tokenId];
    }

    return self;
}

@end

