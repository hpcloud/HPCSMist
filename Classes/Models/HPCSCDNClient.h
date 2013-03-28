//
// Created by Mike Hagedorn on 3/25/13.
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
#import "HPCSIdentityClient.h"


@interface HPCSCDNClient : HPCSSwiftClient

/** the interface to the identity system */
@property (retain) HPCSIdentityClient *identityClient;

///-----------------------------------------------------
/// @name Creating and Initializing HPCSCDN Clients
///-----------------------------------------------------

/**
   Creates a cdn client
   @param client the HPCSIdentityClient to use as the Identity Service Client
   @discussion This is designated initializer. Typically its called in the following fashion (implicitly) from a singleton instance of HPCSIdentityClient:

    HPCSIdentityClient *client = [HPCSIdentityClient sharedClient];
    //this calls initWithIdentityClient
    HPCSCDNClient *cdnClient = [client cdnClient];

 */
- (id) initWithIdentityClient:(HPCSIdentityClient *)client;

///-----------------------------------------------------
/// @name List CDN Enabled Containers
///-----------------------------------------------------

- (void)cdnContainers:(void ( ^)(NSHTTPURLResponse *responseObject, NSArray *records))success
              failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

///-----------------------------------------------------
/// @name Enable CDN for Container
///-----------------------------------------------------

- (void)enableCDNForContainer:(id)object
          success :(void ( ^)(NSHTTPURLResponse *responseObject))success
          failure :(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;


///-----------------------------------------------------
/// @name Get CDN Enabled Container Metadata
///-----------------------------------------------------

- (void) getCDNContainerMetadata:(id)container
               success:(void ( ^)(NSHTTPURLResponse *responseObject, NSDictionary *metadata))success
               failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name Update CDN Enabled Container Metadata
///-----------------------------------------------------

- (void) setCDNContainer:(id)container
             metadata:(NSDictionary *)metadata
              success:(void ( ^)(NSHTTPURLResponse *responseObject, NSDictionary *metadata))success
              failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

///-----------------------------------------------------
/// @name Delete CDN Enabled Container
///-----------------------------------------------------

-(void) deleteCDNContainer:(id)container
                success:(void ( ^)(NSHTTPURLResponse *responseObject))success
                failure:(void ( ^)(NSHTTPURLResponse *responseObject, NSError *error))failure;





@end