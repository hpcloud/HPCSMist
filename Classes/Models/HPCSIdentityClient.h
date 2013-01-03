
//
//  HPCSComputeClient.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 3/12/12.
//  Copyright (C) 2012 HP Cloud Services, Mike Hagedorn All rights reserved.
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
#import "HPCSComputeClient.h"
#import "HPCSSwiftClient.h"
#import "HPCSToken.h"
#import "HPCSTenant.h"

extern NSString *const HPCSNetworkingErrorDomain;

extern NSString *const HPCSAuthenticationDidFailNotification;

extern NSString *const HPCSKeystoneNovaCatalogIsEmptyNotification;
extern NSString *const HPCSKeystoneSwiftCatalogIsEmptyNotification;

extern NSString *const HPCSKeystoneCredentialsDidChangeNotification;

extern NSString *const kHPCSAuthUsernameKey;
extern NSString *const kHPCSAuthPasswordKey;
extern NSString *const kHPCSAuthKey;
extern NSString *const kHPCSAuthPasswordCredentialsKey;
extern NSString *const kHPCSAuthTenantIdKey;
extern NSString *const kHPCSAuthAccessKeyCredentialsKey;
extern NSString *const kHPCSAuthAccessKey;
extern NSString *const kHPCSAuthSecretKey;

/**Allows Access to the HP Cloud Services authorization system (Control Services).

   @discussion this classes listens for the notification HPCSKeystoneCredentialsDidChangeNotification so that it can dump the current cached token.  Use this to force the token to be dumped
 * */

@interface HPCSIdentityClient : AFHTTPClient

/** The HPCSToken object representing the user's credentials. */
@property (retain) HPCSToken *token;

/** The HPCSTenant object representing the the current user's tenant. */
@property (retain) HPCSTenant *tenant;

/** The NSArray of NSDictionary objects which represent services the current user can see. */
@property (retain) NSArray *serviceCatalog;

/** Whether or not the current token is valid */
@property (assign) BOOL isTokenValid;

/** The access key for this user
   @discussion will be nil if sharedClient is utilized for intitialization
 */
@property (retain) NSString *accessKeyId;

/** The access key for this user

   @discussion will be nil if sharedClient is utilized for intitialization
 */
@property (retain) NSString *secretKey;

///-----------------------------------------------------
/// @name Creating and Initializing HPCSIdentity Clients
///-----------------------------------------------------

/** Convenience method to get the HPCSIdentityClient

   @discussion This is the designated initializer. Returns a singleton. If you use this method, then you are using the initWithUsername:andPassword:andTenantId: method to constuct the identity client instance, as opposed to the initWithAccessKeyId:andSecretKey:andTenantId: method.
 */
+ (HPCSIdentityClient *) sharedClient;

/** Initialize using username and password

   @param userName  The name that you use to login to the Management Console with
   @param password The password that you use to login to the Management Console with
   @param tenantId Your tenantId for your account
   @discussion HP Cloud Services allows either AccessKey and SecretKey based login or username and password based login.  sharedClient calls this one.
 */
- (id) initWithUsername:(NSString *)userName andPassword:(NSString *)password andTenantId:(NSString *)tenantId;

/** Initialize using accessKey and secret key

   @param accessKey  Your access key
   @param secretKey  Your secret key
   @param tenantId Your tenantId for your account
   @discussion HP Cloud Services allows either AccessKey and SecretKey based login or username and password based login.


 */

- (id) initWithAccessKeyId:(NSString *)accessKey andSecretKey:(NSString *)secretKey andTenantId:(NSString *)tenantId;

/** NSDictionary which holds either username/password type information or accessKey/secretKey type of information */
- (NSDictionary *) authorizationInfo;

///------------------------------------------------------
/// @name Authenticating with Control Services (Keystone)
///------------------------------------------------------

/** Authenticate to HP Cloud Services Identity Services and return security token

    @param block  a block which returns an NSArray of NSDictionary objects representing services available to you such as Compute, or Object Storage

    @param failure the block called if the authenticate method failed

    @discussion if the service catalog is empty, then your credentials where not valid. You can subscribe to HPCSAuthenticationDidFailNotification to take appropriate action if the credentials are bad


 */

//TODO need to send a message about network not available
- (void) authenticate:( void ( ^)(NSArray * serviceCatalog) )block failure:( void ( ^)(NSHTTPURLResponse * responseObject, NSError * error) )failure;

///------------------------------------------------------
/// @name Checking Your Authorization Status
///------------------------------------------------------

/** Whether or not your HPCSToken is expired */
- (BOOL) isTokenExpired;

/** Whether or not you are logged in */
- (BOOL) isAuthenticated;

///----------------------------
/// @name Ending Your Session
///----------------------------

/** Invalidate your current token

   @param success block called if this operation succeeds
   @param failure block called if this operation fails
   @discussion  allows you to manually invalidate your current token/session on the Control Services server, this does not delete the local cached token, and that token will be invalid after the success of this method.
 */
- (void) tokenInvalidate:( void ( ^)(NSHTTPURLResponse * response) )success failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure;

///-----------------------------------------------
/// @name Getting Access To Authenticated Services
///-----------------------------------------------

/** Retrieve an instance of the Compute Client,designated way to get an instance of the Compute (Nova) client

   @returns nil if no compute resource is in the service catalog
   @discussion if the service catalog does not contain a compute service for this user the HPCSKeystoneNovaCatalogIsEmptyNotification is sent

   Normal Response Code(s): 204

   Error Response Code(s): unauthorized (401), forbidden (403), badRequest (400))

 */

- (HPCSComputeClient *) computeClient;

/** the URL for the compute endpoint as listed in the Service Catalog */
- (NSString *) publicUrlForCompute;

/** Retrieve an instance of the Object Storage Client, designated way to get an instance of the object storage (Swift) client

   @discussion if the service catalog does not contain a compute service for this user the HPCSKeystoneSwiftCatalogIsEmptyNotification is sent.

 */
- (HPCSSwiftClient *) swiftClient;

/** the URL for the object storage endpoint as listed in the Service Catalog */
- (NSString *) publicUrlForObjectStorage;

///-----------------------------------------------
/// @name Secure Management of Your Credentials
///-----------------------------------------------

/** Stores the user name in the secure Keychain
   @param userName your username
 */
- (void) setUsername:(NSString *)userName;

/** Get the stored username */
- (NSString *) username;

/**  Storage password in the secure Keychain

   @param password the password to set
   @discussion pass in nil to delete from Keychain
 */
- (void) setPassword:(NSString *)password;

/** Get the password from the secure Keychain */
- (NSString *) password;

/** Store the tenantId in the secure Keychain
   @param tenantId the tenantId to store
 */
- (void) setTenantId:(NSString *)tenantId;

/** Get the tenantId from storage */
- (NSString *) tenantId;

/** Get the token from the Keychain */
- (HPCSToken *) token;

/** Store the token in the secure Keychain

   @param token the token object to store in the Keychain
   @discussion pass in nil to delete token from Keychain, this will cause a relogin to occur the next time an authenticated service is called.  This essentially deletes the local cache of the token.
 */
- (void) setToken:(HPCSToken *)token;

@end
