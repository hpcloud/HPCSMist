//
//  HPCSGlanceClient.m
//  HPCSMist
//
//  Created by Mike Hagedorn on 10/18/13.
//  Copyright (c) 2013 Mike Hagedorn. All rights reserved.
//

#import "HPCSGlanceClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

@implementation HPCSGlanceClient
+ (id)sharedClient:(HPCSIdentityClient *)identityClient {
    static id _sharedClient = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        //or use the access key id stuff and secret key
        _sharedClient = [[self alloc] initWithIdentityClient:identityClient];
    }
    );

    return _sharedClient;
}

- (NSString *)serviceURL:(id) identity {
    return [identity performSelector:@selector(publicUrlForGlance)];
}

- (void)images:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
       failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self getPath:@"" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        for (id entry in JSON)
        {
            [mutableRecords addObject:entry];
        }

        if (success)
        {
            success (operation.response, [NSArray arrayWithArray:mutableRecords]);
        }
    }
    failure: ^(AFHTTPRequestOperation * operation, NSError * error) {

              if (failure)
              {
                  failure (operation.response, error);
              }
     }
    ];

}

- (void)imageDetailsFor:(id)imageInfo success:(void ( ^)(id serverInfo))block failure:(void ( ^)(NSHTTPURLResponse *response, NSError *error))failure {
    NSString *detailsPath = [NSString stringWithFormat:@"images/%@", [imageInfo valueForKeyPath:@"imageId"]];
    [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSDictionary *serverData = [JSON valueForKeyPath:@"image"];
        if (block)
        {
            block (serverData);
        }
    }
    failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              failure (operation.response,error);
     }
    ];
}

- (void)headImage:(id)image
          success:(void ( ^)(NSHTTPURLResponse *responseObject))success
          failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    [self setDefaultHeader:@"Accept" value:nil];
    NSString *path = [NSString stringWithFormat:@"images/%@", [self URLEncodedString:[image valueForKeyPath:@"imageId"] ]];

    [self headPath:path parameters:nil success: ^(AFHTTPRequestOperation * operation, id data) {
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        if (success)
        {
            success (operation.response);
        }
    }
    failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
               [self setDefaultHeader:@"Accept" value:@"application/json"];
               if (failure)
               {
                   failure (operation.response, error);
               }
    }
    ];
}

- (void)getImageMetadata:(id)object
                  success:(void (^)(NSHTTPURLResponse *, NSDictionary *))success
                  failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    [self headImage:object success:^(NSHTTPURLResponse *responseObject) {
        if (success){
            success(responseObject, responseObject.allHeaderFields);
        }
    } failure:^(NSHTTPURLResponse *responseObject, NSError *error) {
        if (failure){
            failure(responseObject,error);
        }

    }];
}

- (void)setImage:(id)image
        metadata:(NSDictionary *)metadata
        success :(void ( ^)(NSHTTPURLResponse *responseObject))success
        failure :(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure{
    
    [self setDefaultHeader:@"Accept" value:nil];
    NSString *path = [NSString stringWithFormat:@"images/%@", [self URLEncodedString:[image valueForKeyPath:@"imageId"]]];
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:nil];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [metadata enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        if (success) {
            success(operation.response);
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


- (void)getImage:(id)image
         success:(void ( ^)(NSHTTPURLResponse *responseObject, NSData *data))success
         failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure {
    //because you want the raw bytes here, i.e NSData
    [self unregisterHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:nil];
    NSString *path = [NSString stringWithFormat:@"images/%@", [image valueForKeyPath:@"imageId"]];
    [self getPath:path parameters:nil success: ^(AFHTTPRequestOperation * operation, id data) {
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        if (success)
        {
            success (operation.response,data);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              [self setDefaultHeader:@"Accept" value:@"application/json"];
              [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

              if (failure)
              {
                  failure (operation.response, error);
              }
          }
    ];

}

- (void)createImageWithData:(NSData *)data
                       name:(NSString *)name
                 diskFormat:(NSString *)diskFormat
            containerFormat:(NSString *)containerFormat
                 parameters:(NSDictionary *)parameters
                   progress:(void ( ^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
                    success:(void ( ^)(NSHTTPURLResponse *responseObject))success
                    failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure {

    [self setImageWithMethod:@"POST"
                        data:data
                        name:name
                  diskFormat:diskFormat
             containerFormat:containerFormat
                  parameters:parameters
                    progress:progress
                     success:success
                     failure:failure];



}

- (void) setImageWithMethod:(NSString *)method
                        data:(NSData *)data
                        name:(NSString *)name
                  diskFormat:(NSString *)diskFormat
            containerFormat:(NSString *)containerFormat
                  parameters:(NSDictionary *)parameters
                    progress:( void ( ^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) )progressBlock
                     success:( void ( ^)(NSHTTPURLResponse * operation) )success
                     failure:( void ( ^)(NSHTTPURLResponse * responseObject, NSError * error) )failure
{
    //x-image-meta-name, x-image-meta-disk_format,x-image-meta-container_format
    //[self setDefaultHeader:@"Content-Type" value:mimeType];
    NSURLRequest *request = [self requestWithMethod:method path:@"/images" parameters:parameters data:data];

    [self setDefaultHeader:@"x-image-meta-name" value:name];
    [self setDefaultHeader:@"x-image-meta-disk_format" value:diskFormat];
    [self setDefaultHeader:@"x-image-meta-container_format" value:containerFormat];
    AFHTTPRequestOperation *localOperation = [self HTTPRequestOperationWithRequest:request
                                                                           success: ^(AFHTTPRequestOperation * op, id responseObject) {
                                                                               if (success)
                                                                               {
                                                                                   success (op.response);
                                                                                   [self setDefaultHeader:@"x-image-meta-name" value:nil];
                                                                                   [self setDefaultHeader:@"x-image-meta-disk_format" value:nil];
                                                                                   [self setDefaultHeader:@"x-image-meta-container_format" value:nil];
                                                                               }
                                                                           }
                                                                           failure: ^(AFHTTPRequestOperation *op,  NSError *error) {

                                                                               if (failure)
                                                                               {
                                                                                   failure (op.response,error);
                                                                                   [self setDefaultHeader:@"x-image-meta-name" value:nil];
                                                                                   [self setDefaultHeader:@"x-image-meta-disk_format" value:nil];
                                                                                   [self setDefaultHeader:@"x-image-meta-container_format" value:nil];
                                                                               }
                                                                           }
    ];

    [localOperation setUploadProgressBlock:progressBlock];
    [self enqueueHTTPRequestOperation:localOperation];
}

- (NSMutableURLRequest *) requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                       data:(NSData *)data
{
    NSMutableURLRequest *request = [super requestWithMethod:method
                                                       path:path
                                                 parameters:parameters];

    [request setHTTPBody:data];

    return request;
}

- (void)sharedImages:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure {

}

- (void) headPath:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:( void ( ^)(AFHTTPRequestOperation * operation, id responseObject) )success
          failure:( void ( ^)(AFHTTPRequestOperation * operation, NSError * error) )failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"HEAD" path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [operation setCacheResponseBlock: ^NSCachedURLResponse * (NSURLConnection * connection, NSCachedURLResponse * cachedResponse) {
        //DO not cache a HEAD request
        return nil;
    }
    ];
    [self enqueueHTTPRequestOperation:operation];
}

- (NSString *) URLEncodedString:(NSString *)source
{
    return [source stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}



@end
