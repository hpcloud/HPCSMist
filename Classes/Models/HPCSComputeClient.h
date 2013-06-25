//
//  HPCSComputeClient.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 3/13/12.
//  © Copyright 2013 Hewlett-Packard Development Company, L.P.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@class HPCSIdentityClient;

extern NSString *const HPCSNovaServersListDidFailNotification;
extern NSString *const HPCSNovaServersDeleteDidFailNotification;
extern NSString *const HPCSNovaServersShowDidFailNotification;
extern NSString *const HPCSNovaFlavorsDidFailNotification;
extern NSString *const HPCSNovaFlavorDetailsDidFailNotification;
extern NSString *const HPCSNovaImagesDidFailNotification;
extern NSString *const HPCSNovaImageDetailsDidFailNotification;

/** The interface to HP's Nova System (Compute) */
@interface HPCSComputeClient : AFHTTPClient

/** the interface to the identity system */
@property (retain) HPCSIdentityClient *identityClient;

///-----------------------------------------------------
/// @name Creating and Initializing HPCSCompute Clients
///-----------------------------------------------------

+(id) sharedClient:(HPCSIdentityClient *)identityClient;

/**
   Creates a compute client
   @param client the HPCSIdentityClient to use as the Identity Service Client
   @discussion This is designated initializer. Typically its called in the following fashion (implicitly) from a singleton instance of HPCSIdentityClient:

    HPCSIdentityClient *client = [HPCSIdentityClient sharedClient];
    //this calls initWithIdentityClient
    HPCSComputeClient *computeClient = [client computeClient];

 */
- (id) initWithIdentityClient:(HPCSIdentityClient *)client;

///-----------------------------------------------------
/// @name List Running Nova Instances
///-----------------------------------------------------

/**
   Retrieves the list of servers running

   @param block returns an NSArray of servers, or an empty NSArray if it fails
   @param failure block called for a failed call
   @discussion emits notification **HPCSNovaServersListDidFailNotification** if servers list fails  with userInfo["NSError"]
   for error details.  Question: support changes-since param?
 */
- (void) servers:( void ( ^)(NSArray * records) )block failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name List available server flavors
///-----------------------------------------------------

/**
   Retrieves the list of flavors available to launch

   @param block returns an NSArray of flavors, or an empty NSArray if it fails
   @param failure block called for a failed call
   @discussion emits event **HPCSNovaFlavorsDidFailNotification** on failure with userInfo["NSError"] for error details
 */
- (void) flavors:( void ( ^)(NSArray * records) )block failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name List available server images
///-----------------------------------------------------

/**
   Retrieves the list of images available to launch (from Glance)
   @param block returns an NSArray of Glance images, or an empty NSArray if it fails
   @param failure block called for a failed call
   @discussion emits **HPCSNovaImagesDidFailNotification** on failure with userInfo["NSError"] for error details
 */
- (void) images:( void ( ^)(NSArray * records) )block failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name Get detailed information about a server
///-----------------------------------------------------
/**
   Retrieve verbose details on a Nova server
   @param serverInfo object that must respond to serverId
   @param block block that returns an NSDictionary of information about the server
   @param failure block called for a failed call
   @discussion emits **HPCSNovaServersShowDidFailNotification** on failure with userInfo["NSError"] for error details

 */
- (void) serverDetailsFor:(id)serverInfo success:( void ( ^)(id serverInfo) )block failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name Get detailed information about a server flavor
///-----------------------------------------------------
/**
   Retrieve verbose details on a Nova flavor

   @param flavorInfo object that must respond to flavorId
   @param block block that returns an NSDictionary of information about the flavor
   @param failure block called for a failed call
   @discussion emits **HPCSNovaFlavorDetailsDidFailNotification** on failure with userInfo["NSError"] for error details
 */
- (void) flavorDetailsFor:(id)flavorInfo success:( void ( ^)(id flavorInfo) )block failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;
///-----------------------------------------------------
/// @name Get detailed information about a server (Glance) image
///-----------------------------------------------------

/** Retrieve verbose details on a Glance image
   @param imageInfo object that must respond to imageId
   @param block block that returns an NSDictionary of information about the image
   @param failure block called for a failed call
   @discussion emits **HPCSNovaImageDetailsDidFailNotification** on failure with userInfo["NSError"] for error details
 */
- (void) imageDetailsFor:(id)imageInfo success:( void ( ^)(id imageInfo) )block failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name Terminate a server
///-----------------------------------------------------

/** Terminate the specified server.
    @param serverInfo object that must respond to serverId
    @param success block which returns the NSHTTPURLResponse
    @param failure block which is called in case of a failure
    @discussion emits event **HPCSNovaServersDeleteDidFailNotification** on failure with userInfo["NSError"] with error details

 */
- (void) terminateServer:(id)serverInfo
 success                :( void ( ^)(NSHTTPURLResponse * response) )success
 failure                :( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure;

@end
