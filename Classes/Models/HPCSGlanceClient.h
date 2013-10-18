//
//  HPCSGlanceClient.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 10/18/13.
//  Copyright (c) 2013 Mike Hagedorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPCSIdentityClient.h"


@interface HPCSGlanceClient : HPCSAuthorizedHTTPClient

+ (id) sharedClient: (HPCSIdentityClient *)identityClient;


- (void)images:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
       failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

- (void) imageDetailsFor:(id)imageInfo
                  success:( void ( ^)(id serverInfo) )block
                  failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

- (void)headImage:(id)image
          success:(void ( ^)(NSHTTPURLResponse *responseObject))success
          failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

- (void)getImageMetadata:(id)image
                 success:(void (^)(NSHTTPURLResponse *, NSDictionary *))success
                 failure:(void (^)(NSHTTPURLResponse *, NSError *))failure;


- (void)setImage:(id)image
         metadata:(NSDictionary *)metadata
         success :(void ( ^)(NSHTTPURLResponse *responseObject))success
         failure :(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


- (void)getImage:(id)image
         success:(void ( ^)(NSHTTPURLResponse *responseObject, NSData *data))success
         failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

- (void)createImageWithData:(NSData *)data
                       name:(NSString *)name
                 diskFormat: (NSString *)diskFormat
            containerFormat:(NSString *)containerFormat
               parameters:(NSDictionary *)parameters
                 progress:(void ( ^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
                  success:(void ( ^)(NSHTTPURLResponse *responseObject))success
                  failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

- (void)sharedImages:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
             failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


@end
