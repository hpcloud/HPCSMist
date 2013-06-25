


#import "HPCSCDNClient.h"
#import "AFJSONRequestOperation.h"


@implementation HPCSCDNClient {

}

// COV_NF_START
+ (id) sharedClient: (HPCSIdentityClient *)identityClient
{
    static HPCSComputeClient * _sharedClient = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        //or use the access key id stuff and secret key
        _sharedClient = [[self alloc] initWithIdentityClient:identityClient];
    }
    );

    return _sharedClient;
}

// COV_NF_END

- (id)initWithIdentityClient:(HPCSIdentityClient *)client {
  self = [super initWithBaseURL:[NSURL URLWithString:[client publicUrlForCDN]]];
  self.identityClient = client;
  if (!self) {
    return nil;
  }

  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

  // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
  [self setDefaultHeader:@"Accept" value:@"application/json"];
  [self setParameterEncoding:AFJSONParameterEncoding];
  if (self.identityClient) {
    [self setDefaultHeader:@"X-Auth-Token" value:self.identityClient.token.tokenId];
  }

  return self;
}

- (void)cdnContainers:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
              failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure {

  [self getPath:@""
     parameters:nil
        success:^(AFHTTPRequestOperation *operation, id JSON) {
          NSMutableArray *mutableRecords = [NSMutableArray array];
          for (id entry in JSON) {
            [mutableRecords addObject:entry];
          }
          if (success) {
            success(operation.response, [NSArray arrayWithArray:mutableRecords]);
          }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
            failure(operation.response, error);
          }
        }
  ];

}

- (void)enableCDNForContainer:(id)container
                      success :(void ( ^)(NSHTTPURLResponse *responseObject))success
                      failure :(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure{
    NSString *path = [NSString stringWithFormat:@"%@", [self URLEncodedString:[container valueForKeyPath:@"name"] ]];

    [self putPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.response);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.response, error);
        }

    }];
}


- (void)getCDNContainerMetadata:(id)container
        success:(void (^)(NSHTTPURLResponse *, NSDictionary *))success
        failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
  [self headContainer:container
              success:^(NSHTTPURLResponse *responseObject) {
                if (success) {
                  success(responseObject, responseObject.allHeaderFields);
                }
              }
              failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                if (failure) {
                  failure(responseObject, error);
                }

              }];

}

- (void)setCDNContainer:(id)container metadata:(NSDictionary *)metadata
                success:(void (^)(NSHTTPURLResponse *, NSDictionary *))success
                failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
  [self setDefaultHeader:@"Accept" value:nil];
  NSString *path = [NSString stringWithFormat:@"%@", [(HPCSSwiftClient *) self URLEncodedString:[container valueForKeyPath:@"name"]]];
  NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:nil];
  [self setDefaultHeader:@"Accept" value:@"application/json"];
  [metadata enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [request addValue:obj forHTTPHeaderField:key];
  }];
  AFHTTPRequestOperation *operation =
          [self HTTPRequestOperationWithRequest:request
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          [self setDefaultHeader:@"Accept" value:@"application/json"];
                                          if (success) {
                                            success(operation.response, responseObject);
                                          }
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self setDefaultHeader:@"Accept" value:@"application/json"];
                                          if (failure) {
                                            failure(operation.response, error);
                                          }
                                        }];
  [self enqueueHTTPRequestOperation:operation];

}

- (void)deleteCDNContainer:(id)container
                   success:(void (^)(NSHTTPURLResponse *))success
                   failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
  [self setDefaultHeader:@"Accept" value:nil];
  NSString *path = [NSString stringWithFormat:@"%@", [self URLEncodedString:[container valueForKeyPath:@"name"]]];
  [self deletePath:path
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id JSON) {
             if (success) {
               [self setDefaultHeader:@"Accept" value:@"application/json"];
               success(operation.response);
             }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftContainerDeleteDidFailNotification object:self];
             if (failure) {
               [self setDefaultHeader:@"Accept" value:@"application/json"];
               failure(operation.response, error);
             }
           }
  ];

}

@end