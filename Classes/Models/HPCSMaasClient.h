//
//  HPCSMaasClient.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 5/9/13.
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
//
//  Monitoring As A Service Client (beta)

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "HPCSIdentityClient.h"

@class HPCSIdentityClient;

extern NSString *const HPCSMaasOperationDidFailNotification;

@interface HPCSMaasClient : AFHTTPClient
/** the interface to the identity system */
@property (retain) HPCSIdentityClient *identityClient;


///-----------------------------------------------------
/// @name Creating and Initializing HPCSMaas Clients
///-----------------------------------------------------

/**
   Creates a maas client
   @param client the HPCSIdentityClient to use as the Identity Service Client
   @discussion This is designated initializer. Typically its called in the following fashion (implicitly) from a singleton instance of HPCSIdentityClient:

    HPCSIdentityClient *client = [HPCSIdentityClient sharedClient];
    //this calls initWithIdentityClient
    HPCSMaasClient *massClient = [client maasClient];

 */
- (id) initWithIdentityClient:(HPCSIdentityClient *)client;

///-----------------------------------------------------
/// @name Endpoint Operations
///-----------------------------------------------------

- (void) endpoints:( void ( ^)(NSArray * records) )block
           failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

- (void) saveEndpoint:(id)endpoint
              success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
              failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) endpointDetailsFor:(id)endpoint
                    success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
                    failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) deleteEndpoint:(id)endpoint
              success:(void ( ^)(NSHTTPURLResponse *))deleted
              failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) resetPasswordForEndpoint:(id)endpoint
                success:(void ( ^)(NSHTTPURLResponse *, NSData *))deleted
                failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;


///-----------------------------------------------------
/// @name Subscription Operations
///-----------------------------------------------------

- (void) subscriptions:( void ( ^)(NSArray * records) )block
               failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

- (void) saveSubscription:(id)subscription
              success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
              failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) subscriptionDetailsFor:(id)endpoint
                    success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
                    failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) deleteSubscription:(id)subscription
                success:(void ( ^)(NSHTTPURLResponse *))deleted
                failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;
///-----------------------------------------------------
/// @name Alarm Operations
///-----------------------------------------------------

- (void) alarms:( void ( ^)(NSArray * records) )block
               failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

- (void) saveAlarm:(id)alarm
                  success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
                  failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) alarmDetailsFor:(id)alarm
                        success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
                        failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) deleteAlarm:(id)alarm
                    success:(void ( ^)(NSHTTPURLResponse *))deleted
                    failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

///-----------------------------------------------------
/// @name NotificationMethod Operations
///-----------------------------------------------------
- (void) notificationMethods:( void ( ^)(NSArray * records) )block
        failure:( void ( ^)(NSHTTPURLResponse * response,NSError * error) )failure;

- (void) saveNotificationMethod:(id)notificationMethod
                        success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
                        failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) notificationMethodDetailsFor:(id)notificationMethod
                              success:(void ( ^)(NSHTTPURLResponse *, NSData *))saved
                              failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;

- (void) deleteNotificationMethod:(id)alarm
                          success:(void ( ^)(NSHTTPURLResponse *))deleted
                          failure:(void ( ^)(NSHTTPURLResponse *, NSError *))failure;



@end
