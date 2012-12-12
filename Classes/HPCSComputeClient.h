//
//  HPCSComputeClient.h
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@class HPCSIdentityClient;

extern NSString * const HPCSNovaServersListDidFailNotification;
extern NSString * const HPCSNovaServersDeleteDidFailNotification;
extern NSString * const HPCSNovaServersShowDidFailNotification;
extern NSString * const HPCSNovaFlavorsDidFailNotification;
extern NSString * const HPCSNovaFlavorDetailsDidFailNotification;
extern NSString * const HPCSNovaImagesDidFailNotification;
extern NSString * const HPCSNovaImageDetailsDidFailNotification;

/** The interface to HP's Nova System (Compute) */
@interface HPCSComputeClient : AFHTTPClient

/** the interface to the identity system */
@property (retain) HPCSIdentityClient *identityClient;

/** Creates a compute client 
    
This is designated initializer. Typically its called in the following fashion (implicitly):

    HPCSIdentityClient *client = [HPCSIdentityClient sharedClient];
    //this calls initWithIdentityClient
    HPCSComputeClient *computeClient = [client computeClient];


  
 @param client the HPCSIdentityClient to use as the Identity Service Client
 
 */
- (id)initWithIdentityClient:(HPCSIdentityClient *)client;

/** Retrieves the list of servers running
    
    Gives you the servers assigned to your account
 
    @param block returns an NSArray of servers, or an empty NSArray if it fails
    @param failure block called for a failed call
    @discussion emits notification HPCSNovaServersListDidFailNotification if servers list fails  with userInfo["NSError"]
    for error details.  Question: support changes-since param?
*/
-(void)servers: (void (^)(NSArray *records))block failure:(void (^)(NSHTTPURLResponse *response,NSError *error))failure;

/** Retrieves the list of flavors available to launch
 
 Gives you the flavors visible to your account
 
 @param block returns an NSArray of flavors, or an empty NSArray if it fails
 @param failure block called for a failed call
 @discussion emits event HPCSNovaServersListDidFailNotification with userInfo["NSError"] for error details
 */
-(void)flavors:(void (^)(NSArray *records))block failure:(void (^)(NSHTTPURLResponse *response,NSError *error))failure;

/** Retrieves the list of images available to launch
 
 Gives you the images visible to your account (this is Glance)
 
 @param block returns an NSArray of Glance images, or an empty NSArray if it fails
 @param failure block called for a failed call
 @discussion emits HPCSNovaFlavorsDidFailNotification with userInfo["NSError"] for error details
 */
-(void)images:(void (^)(NSArray *records))block failure:(void (^)(NSHTTPURLResponse *response,NSError *error))failure;

/** Retrieve details on a Nova server
 
    Detailed version of server details
 
    @param serverInfo object that must respond to serverId
    @param block block that returns an NSDictionary of information about the server
    @param failure block called for a failed call
    @discussion emits HPCSNovaImagesDidFailNotification with userInfo["NSError"] for error details
 
 */
-(void) serverDetailsFor:(id) serverInfo success:(void (^)(id serverInfo))block failure:(void (^)(NSHTTPURLResponse *response,NSError *error))failure;

/** Retrieve details on a Nova flavor
    Detailed version of flavor details
   
    @param flavorInfo object that must respond to flavorId
    @param block block that returns an NSDictionary of information about the flavor
    @param failure block called for a failed call
    @discussion emits HPCSNovaServersShowDidFailNotification with userInfo["NSError"] for error details
 */
-(void) flavorDetailsFor:(id) flavorInfo success:(void (^)(id flavorInfo))block failure:(void (^)(NSHTTPURLResponse *response,NSError *error))failure;

/** Retrieve details on a Glance image
    Detailed version of image details
 
    @param imageInfo object that must respond to imageId
    @param block block that returns an NSDictionary of information about the image
    @param failure block called for a failed call
    @discussion emits HPCSNovaFlavorDetailsDidFailNotification with userInfo["NSError"] for error details
 */
-(void) imageDetailsFor:(id) imageInfo success:(void (^)(id imageInfo))block failure:(void (^)(NSHTTPURLResponse *response,NSError *error))failure;

/** Terminate the specified server.
    
    Shutdown a server
 
    @param serverInfo object that must respond to serverId
    @param success block which returns the NSHTTPURLResponse
    @param failure block which is called in case of a failure
    @discussion emits event HPCSNovaServersDeleteDidFailNotification with userInfo["NSError"] with error details
 
 */
- (void)terminateServer:(id)serverInfo
             success:(void (^)(NSHTTPURLResponse *response))success
             failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

@end
