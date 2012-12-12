
//
//  HPCSComputeClient.h
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "HPCSComputeClient.h"
#import "HPCSSwiftClient.h"
#import "HPCSToken.h"
#import "HPCSTenant.h"



/**
 Indicates an error occured in AFNetworking.

 @discussion Error codes for HPCSNetworkingErrorDomain correspond to codes in NSURLErrorDomain.
 */
extern NSString * const HPCSNetworkingErrorDomain;

/**
 Posted when an authentication fails.
 */
extern NSString * const HPCSAuthenticationDidFailNotification;

extern NSString * const HPCSKeystoneNovaCatalogIsEmptyNotification;
extern NSString * const HPCSKeystoneSwiftCatalogIsEmptyNotification;

/** Posted when the username or password or tenantId are changed
* this needs to get done so that the IdentityClient knows to dump its cached token
*/
extern NSString * const HPCSKeystoneCredentialsDidChangeNotification;

extern NSString * const kHPCSAuthUsernameKey;
extern NSString * const kHPCSAuthPasswordKey;
extern NSString * const kHPCSAuthKey;
extern NSString * const kHPCSAuthPasswordCredentialsKey;
extern NSString * const kHPCSAuthTenantIdKey;
extern NSString * const kHPCSAuthAccessKeyCredentialsKey;
extern NSString * const kHPCSAuthAccessKey;
extern NSString * const kHPCSAuthSecretKey;


@interface HPCSIdentityClient : AFHTTPClient

/** The HPCSToken object representing the user's credentials. */
@property (retain) HPCSToken *token;

/** The HPCSTenant object representing the the current user's tenant. */
@property (retain) HPCSTenant *tenant;

/** The NSArray of NSDictionary objects which represent services the current user can see. */
@property (retain) NSArray* serviceCatalog;

/** Whether or not the current token is valid */
@property (assign) BOOL isTokenValid;

/** The access key for this user */
@property (retain) NSString *accessKeyId;

/** The access key for this user */
@property (retain) NSString *secretKey;



/** Convenience method to get the HPCSIdentityClient 
    
    returns a singleton
 
    @discussion if you use this method, then you are using the initWithUsername:andPassword:andTenantId method to constuct the identity client instance.  
 */
+(HPCSIdentityClient *)sharedClient;

/** Initialize using username and password
 
 HP Cloud Services allows either token and id based login or username and password based login
 
 @discussion this violates the notion of a designated initializer...
 @param userName  The name that you use to login to the Management Console with
 @param password The password that you use to login to the Management Console with
 @param tenantId Your tenantId for your account
 
 
 */
-(id) initWithUsername:(NSString *)userName andPassword:(NSString *)password andTenantId:(NSString *)tenantId;

/** Initialize using accessKey and secret key
 
 HP Cloud Services allows either token and id based login or username and password based login
 
 @discussion this violates the notion of a designated initializer...
 @param accessKey  Your access key
 @param secretKey  Your secret key
 @param tenantId Your tenantId for your account
 
 
 */

-(id) initWithAccessKeyId:(NSString *)accessKey andSecretKey:(NSString *)secretKey andTenantId:(NSString *)tenantId;

/** NSDictionary which holds either username/password type information or accessKey/secretKey type of information */
-(NSDictionary *)authorizationInfo;

/** Authenticate to HP Cloud Services Identity Services
    
    initiates the login to the HPCS IS system and returns HPCSToken
  
    @param block  a block which returns an NSArray of NSDictionary objects representing services available to you such as Compute, or Object Storage
 
    @param failure the block called if the authenticate method failed
 
    @discussion if the service catalog is empty, then your credentials where not valid. You can subscribe to HPCSAuthenticationDidFailNotification to take appropriate action if the credentials are bad
 
 
 */
//TODO need to send a message about network not available
-(void) authenticate:(void (^)(NSArray *serviceCatalog))block failure:(void (^)(NSHTTPURLResponse *responseObject, NSError *error))failure;

/** Whether or not your HPCSToken is expired */
-(BOOL) isTokenExpired;

/** Whether or not you are logged in */
-(BOOL) isAuthenticated;

/** Invalidate your current token 
    
    allows you to manually invalidate your current token
    
    @param success block called if this operation succeeds
    @param failure block called if this operation fails
 
 
*/
-(void) tokenInvalidate:(void (^)(NSHTTPURLResponse *response)) success failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

/** Retrieve an instance of the Compute Client 
    
    designated way to get and instance of the compute client
    
@returns nil if no compute resource is in the service catalog
@discussion if the service catalog does not contain a compute service for this user the HPCSKeystoneNovaCatalogIsEmptyNotification is sent

Normal Response Code(s): 204

Error Response Code(s): unauthorized (401), forbidden (403), badRequest (400))
 
 */
-(HPCSComputeClient *)computeClient;

/** the URL for the compute endpoint as listed in the Service Catalog */
-(NSString *)publicUrlForCompute;

/** Retrieve an instance of the Object Storage  Client
 
 designated way to get and instance of the object storage (Swift) client
 
 @discussion if the service catalog does not contain a compute service for this user the HPCSKeystoneSwiftCatalogIsEmptyNotification is sent.
 
 */


-(HPCSSwiftClient *)swiftClient;


/** the URL for the object storage endpoint as listed in the Service Catalog */
-(NSString *)publicUrlForObjectStorage;

/** Stores the user name in the UserDefaults storage object 
 @param userName your username
 */
-(void) setUsername:(NSString*)userName;

/** Get the stored username */
-(NSString *)username;

/**  Storage password in the secure Keychain
 
@param password the password to set 
@discussion pass in nil to delete from Keychain
*/
-(void) setPassword:(NSString *)password;

/** Get the password from the secure keychain */
-(NSString *)password;

/** Store the tenantId in UserDefaults
 @param tenantId the tenantId to store
 */
-(void)setTenantId:(NSString *)tenantId;

/** Get the tenantId from userDefaults */
-(NSString *)tenantId;

/** Get the token from the Keychain */
-(HPCSToken *)token;

/** Store the token in the keychain 
* @discussion pass in nil to delete token from Keychain
  @param token the token object to store in the Keychain
*/
-(void) setToken:(HPCSToken *)token;


@end
