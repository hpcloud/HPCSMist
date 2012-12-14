//
//  HPCSSwiftClient.m
//  HPCSIOSSampler
//
//  Created by Mike Hagedorn on 8/20/12.
//
//

#import "HPCSSwiftClient.h"
#import "AFJSONRequestOperation.h"
#import "HPCSIdentityClient.h"


NSString * const HPCSSwiftContainersListDidFailNotification = @"com.hp.cloud.swift.containers.fail";
NSString * const HPCSSwiftContainerSaveDidFailNotification = @"com.hp.cloud.swift.container.save.fail";
NSString * const HPCSSwiftContainerDeleteDidFailNotification = @"com.hp.cloud.swift.container.delete.fail";
NSString * const HPCSSwiftContainerShowDidFailNotification = @"com.hp.cloud.swift.container.show.fail";
NSString * const HPCSSwiftObjectSaveDidFailNotification = @"com.hp.cloud.swift.object.save.fail";
NSString * const HPCSSwiftObjectShowDidFailNotification = @"com.hp.cloud.swift.object.show.fail";
NSString * const HPCSSwiftObjectDeleteDidFailNotification  = @"com.hp.cloud.swift.object.delete.fail";

NSString * const HPCSSwiftContainerObjectCountHeaderKey = @"X-Container-Object-Count";
NSString * const HPCSSwiftContainerBytesUsedHeaderKey = @"X-Container-Bytes-Used";
NSString * const HPCSSwiftAccountObjectCountHeaderKey = @"X-Account-Object-Count";
NSString * const HPCSSwiftAccountBytesUsedHeaderKey = @"X-Account-Bytes-Used";
NSString * const HPCSSwiftAccountContainerCountHeaderKey = @"X-Account-Container-Count";

@implementation HPCSSwiftClient
@synthesize identityClient;

- (id)initWithIdentityClient:(HPCSIdentityClient *)identity {
  self = [super initWithBaseURL:[NSURL URLWithString:[identity publicUrlForObjectStorage]]];
  self.identityClient = identity;
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


- (void)containers:(void (^)(NSHTTPURLResponse *responseObject,NSArray *records))success
           failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        for (id entry in JSON) {
          [mutableRecords addObject:entry];
        }
        if (success) {
          success(operation.response, [NSArray arrayWithArray:mutableRecords]);
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftContainersListDidFailNotification object:self];
        if (failure) {
            failure(operation.response, error);
        }
    }];
}


- (void)saveContainer:(id)container success:(void (^)(NSHTTPURLResponse *response))success
              failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {

    //cant use json for this... there is no body response anyway
    [self setDefaultHeader:@"Accept" value:nil];

    [self putPath:[NSString stringWithFormat:@"%@",[self URLEncodedString:[container valueForKeyPath:@"name"] ]]
       parameters:[NSDictionary dictionaryWithObject:@"json" forKey:@"format"]
            success:^(AFHTTPRequestOperation *operation, id JSON) {
              [self setDefaultHeader:@"Accept" value:@"application/json"];
                if (success) {
                  success(operation.response);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftContainerSaveDidFailNotification object:self];
              [self setDefaultHeader:@"Accept" value:@"application/json"];
              if (failure) {
                failure(operation.response, error);
              }
            }
    ];
}

- (void)deleteContainer:(id)container success:(void (^)(NSHTTPURLResponse *responseObject))success
                failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
   [self setDefaultHeader:@"Accept" value:nil];
    NSString *path = [NSString stringWithFormat:@"%@",[self URLEncodedString:[container valueForKeyPath:@"name"] ]];
    [self deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        if (success) {
          [self setDefaultHeader:@"Accept" value:@"application/json"];
          success(operation.response);
        }
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftContainerDeleteDidFailNotification object:self];
        if (failure) {
          [self setDefaultHeader:@"Accept" value:@"application/json"];
          failure(operation.response, error);
        }
    }];

}

- (NSDictionary *)metaDataFromResponse:(NSHTTPURLResponse *)response {
  NSDictionary *headers = response.allHeaderFields;
  NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
  NSArray *keys =
      [NSArray arrayWithObjects:
          HPCSSwiftAccountBytesUsedHeaderKey,
          HPCSSwiftAccountContainerCountHeaderKey,
          HPCSSwiftAccountObjectCountHeaderKey,
          HPCSSwiftContainerBytesUsedHeaderKey,
          HPCSSwiftContainerObjectCountHeaderKey,nil];

  for (NSString *key in keys){
    if ([headers valueForKey:key]){
      [metadata setObject:[NSNumber numberWithInt:[[headers valueForKey:key] intValue]] forKey:key];
    }
  }

 return metadata;
}

- (void)headContainer:(id)container
              success:(void (^)(NSHTTPURLResponse *))success
              failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
  [self setDefaultHeader:@"Accept" value:nil];
  NSString *path = [NSString stringWithFormat:@"%@", [self URLEncodedString:[container valueForKeyPath:@"name"] ]];

  [self headPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id data) {
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    if (success) {
      success(operation.response);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self setDefaultHeader:@"Accept" value:@"application/json"];
          if (failure) {
            failure(operation.response, error);
          }
     }
  ];
}

- (void)objectsForContainer:(id)container
                    success:(void (^)(NSHTTPURLResponse *responseObject,NSArray *records))success
                    failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"%@", [self URLEncodedString:[container valueForKeyPath:@"name"] ]];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        for (id entry in JSON) {
          NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:entry];
          [attributes setValue:container forKey:@"parent"];
          NSString *objectPath = [path stringByAppendingFormat:@"/%@", [attributes valueForKey:@"name"]];
          NSURL *url = [NSURL URLWithString:objectPath relativeToURL:self.baseURL];
          [attributes setValue:url forKey:@"url"];
          [mutableRecords addObject:attributes];
        }
        if (success) {
          success(operation.response,[NSArray arrayWithArray:mutableRecords]);
        }
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftContainerShowDidFailNotification object:self];
        if (failure) {
          failure(operation.response, error);
        }
       }
    ];

}

- (void)deleteObject:(id)object
             success:(void (^)(NSHTTPURLResponse *responseObject))success
             failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {

  [self setDefaultHeader:@"Accept" value:nil];

    [self deletePath:[NSString stringWithFormat:@"%@/%@",[self URLEncodedString:[object valueForKeyPath:@"parent.name"] ], [self URLEncodedString:[object valueForKeyPath:@"name"] ] ]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id JSON) {
                if (success) {
                  [self setDefaultHeader:@"Accept" value:@"application/json"];
                  success(operation.response);
                }
              }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self setDefaultHeader:@"Accept" value:@"application/json"];
                [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftObjectDeleteDidFailNotification object:self];
                if (failure) {
                  failure(operation.response, error);
                }
              }
    ];

}

- (void)saveObject:(id) object
      success:(void (^)(NSHTTPURLResponse *responseObject))success
          progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
      failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self setDefaultHeader:@"Accept" value:nil];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self URLEncodedString:[object valueForKeyPath:@"parent.name"] ], [self URLEncodedString:[object valueForKeyPath:@"name"] ]];

    [self putObjectWithData:[object valueForKeyPath:@"data"]
                   mimeType:[object valueForKeyPath:@"mimeTypeForFile"]
            destinationPath:path
                 parameters:nil
                   progress:progress
                    success:^(NSHTTPURLResponse *responseObject) {
                      [self setDefaultHeader:@"Accept" value:@"application/json"];
                      if(success){
                        success(responseObject);
                      }

                    }  failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
                      [self setDefaultHeader:@"Accept" value:@"application/json"];
                      if (failure){
                        failure(responseObject, error);
                      }
                    }
    ];

}

- (void)getObject:(id) object
          success:(void (^)(NSHTTPURLResponse *responseObject, NSData *data))success
          failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self setDefaultHeader:@"Accept" value:nil];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self URLEncodedString:[object valueForKeyPath:@"parent.name"] ], [self URLEncodedString:[object valueForKeyPath:@"name"] ]];
  [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id data) {
      [self setDefaultHeader:@"Accept" value:@"application/json"];
      if (success) {
        success(operation.response,data);
      }
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [self setDefaultHeader:@"Accept" value:@"application/json"];
        [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftObjectShowDidFailNotification object:self];
        if(failure) {
          failure(operation.response, error);
        }
      }
  ];


}

- (void)headPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
  NSMutableURLRequest *request = [self requestWithMethod:@"HEAD" path:path parameters:parameters];
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];


  AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
  [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
    //DO not cache a HEAD request
    return nil;
  }];
  [self enqueueHTTPRequestOperation:operation];
}






- (void)headObject:(id) object
                   success:(void (^)(NSHTTPURLResponse *response))success
                   failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
  [self setDefaultHeader:@"Accept" value:nil];
  NSString *path = [NSString stringWithFormat:@"%@", [self URLEncodedString:[object valueForKeyPath:@"name"] ]];

  [self headPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id data) {
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    if (success) {
      success(operation.response);
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    if (failure) {
      failure(operation.response, error);
    }
  }
  ];

}



- (void)postObjectWithData:(NSData *)data
                  mimeType:(NSString *)mimeType
           destinationPath:(NSString *)destinationPath
                parameters:(NSDictionary *)parameters
                  progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
                   success:(void (^)(NSHTTPURLResponse *responseObject))success
                    failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self setObjectWithMethod:@"POST"
                         data:data
                     mimeType:mimeType
              destinationPath:destinationPath
                   parameters:parameters
                     progress:progress
                      success:success
                      failure:failure];
}

- (void)putObjectWithData:(NSData *)data
                 mimeType:(NSString *)mimeType
          destinationPath:(NSString *)destinationPath
               parameters:(NSDictionary *)parameters
                 progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
                  success:(void (^)(NSHTTPURLResponse *responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self setObjectWithMethod:@"PUT"
                         data:data
                     mimeType:mimeType
              destinationPath:destinationPath
                   parameters:parameters
                     progress:progress
                      success:success
                      failure:failure];
}

- (NSString *)urlForObject:(id)object {
  NSString *path = [NSString stringWithFormat:@"%@/%@", [self URLEncodedString:[object valueForKeyPath:@"parent.name"] ],[self URLEncodedString:[object valueForKeyPath:@"name"]]];
  NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
  return [url absoluteString];
}


- (void)setObjectWithMethod:(NSString *)method
                       data:(NSData *)data
                   mimeType:(NSString *)mimeType
            destinationPath:(NSString *)destinationPath
                 parameters:(NSDictionary *)parameters
                   progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
                    success:(void (^)(NSHTTPURLResponse *operation))success
                     failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self setDefaultHeader:@"Content-Type" value:mimeType];
    NSURLRequest *request = [self requestWithMethod:method path:destinationPath parameters:parameters data:data];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                         if (success){
                                                                             success(operation.response) ;
                                                                         }
                                                                      }
                                                                      failure:^(AFHTTPRequestOperation *operation,  NSError *error) {

                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:HPCSSwiftObjectSaveDidFailNotification object:self];

                                                                        if (failure){
                                                                              failure(operation.response,error);
                                                                          }

                                                                      }];


    [operation setUploadProgressBlock: progressBlock];
    [self enqueueHTTPRequestOperation:operation];

}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                      data:(NSData *)data {

    NSMutableURLRequest *request = [super requestWithMethod:method
                                                       path:path
                                                 parameters:parameters];

    [request setHTTPBody:data];

    return request;
}
-(NSString *)URLEncodedString:(NSString *)source{
  return   [source stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}




@end
