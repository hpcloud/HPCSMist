//
//  HPCSComputeClient.m
//  HPCSMist
//
//  Created by Mike Hagedorn on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HPCSIdentityClient.h"
#import "AFJSONRequestOperation.h"
#import "Environment.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "HPCSCommonMacros.h"
#import "HPCSSecurityConstants.h"
#import "KeychainWrapper.h"

NSString *const HPCSNetworkingErrorDomain = @"com.hp.cloud.networking.error";

NSString *const kHPCSAuthUsernameKey = @"username";
NSString *const kHPCSAuthPasswordKey = @"password";
NSString *const kHPCSAuthKey = @"auth";
NSString *const kHPCSAuthPasswordCredentialsKey = @"passwordCredentials";
NSString *const kHPCSAuthTenantIdKey = @"tenantId";
NSString *const kHPCSAuthAccessKeyCredentialsKey = @"apiAccessKeyCredentials";
NSString *const kHPCSAuthAccessKey = @"accessKey";
NSString *const kHPCSAuthSecretKey = @"secretKey";

NSString *const HPCSAuthenticationDidFailNotification = @"com.hp.cloud.authentication.fail";
NSString *const HPCSKeystoneNovaCatalogIsEmptyNotification = @"com.hp.cloud.keystone.nova.catalog.empty";
NSString *const HPCSKeystoneSwiftCatalogIsEmptyNotification = @"com.hp.cloud.keystone.swift.catalog.empty";
NSString *const HPCSKeystoneCredentialsDidChangeNotification = @"com.hp.cloud.keystone.credentials.changed";

@interface HPCSIdentityClient ()
@property (nonatomic, retain) NSMutableDictionary *authInfo;
@end

@implementation HPCSIdentityClient {
  @private
  NSArray *_serviceCatalog;
}

@synthesize token = _token;
@synthesize serviceCatalog = _serviceCatalog;
// COV_NF_START
+ (HPCSIdentityClient *) sharedClient
{
  static HPCSIdentityClient *_sharedClient = nil;
  static dispatch_once_t oncePredicate;

  dispatch_once(&oncePredicate, ^{

                  NSString *userName = [KeychainWrapper keychainStringFromMatchingIdentifier:kHPCSAuthUsernameKey];
                  NSString *password = [KeychainWrapper keychainStringFromMatchingIdentifier:kHPCSAuthPasswordKey];
                  NSString *tenantId = [KeychainWrapper keychainStringFromMatchingIdentifier:kHPCSAuthTenantIdKey];

                  //or use the access key id stuff and secret key
                  _sharedClient = [[self alloc] initWithUsername:userName
                                                     andPassword:password
                                                     andTenantId:tenantId];
                }
                );

  [[NSNotificationCenter defaultCenter] addObserver: _sharedClient
                                           selector:@selector(credentialsChanged:)
                                               name:HPCSKeystoneCredentialsDidChangeNotification
                                             object:nil];

  return _sharedClient;

}
// COV_NF_END

- (id) initWithUsername:(NSString *)userName andPassword:(NSString *)password andTenantId:(NSString *)tenantId
{
  self = [self initWithIdentityURL];
  if (!self)
  {
    return nil; // COV_NF_LINE
  }

  [[self.authInfo valueForKey:kHPCSAuthKey] setValue:[NSMutableDictionary dictionaryWithCapacity:2] forKey:kHPCSAuthPasswordCredentialsKey];
  [self.authInfo setValue:userName
               forKeyPath:[NSString stringWithFormat:@"%@.%@.%@",kHPCSAuthKey,kHPCSAuthPasswordCredentialsKey,kHPCSAuthUsernameKey]];
  [self.authInfo setValue:password
               forKeyPath:[NSString stringWithFormat:@"%@.%@.%@",kHPCSAuthKey,kHPCSAuthPasswordCredentialsKey,kHPCSAuthPasswordKey]];
  [self.authInfo setValue:tenantId
               forKeyPath:[NSString stringWithFormat:@"%@.%@",kHPCSAuthKey,kHPCSAuthTenantIdKey]];

  return self;
}


- (id) initWithAccessKeyId:(NSString *)accessKey andSecretKey:(NSString *)aSecretKey andTenantId:(NSString *)tenantId
{
  self = [self initWithIdentityURL];
  if (!self)
  {
    return nil; // COV_NF_LINE
  }

  [[self.authInfo valueForKey:kHPCSAuthKey] setValue:[NSMutableDictionary dictionaryWithCapacity:2] forKey:kHPCSAuthPasswordCredentialsKey];
  [self.authInfo setValue:accessKey
               forKeyPath:[NSString stringWithFormat:@"%@.%@.%@",kHPCSAuthKey,kHPCSAuthAccessKeyCredentialsKey,kHPCSAuthAccessKey]];
  [self.authInfo setValue:aSecretKey
               forKeyPath:[NSString stringWithFormat:@"%@.%@.%@",kHPCSAuthKey,kHPCSAuthAccessKeyCredentialsKey,kHPCSAuthSecretKey]];
  [self.authInfo setValue:tenantId
               forKeyPath:[NSString stringWithFormat:@"%@.%@",kHPCSAuthKey,kHPCSAuthTenantIdKey]];

  return self;
}


- (id) initWithIdentityURL
{
  Environment *myEnv = [Environment sharedInstance];
  self = [self initWithBaseURL:[NSURL URLWithString:myEnv.HPCSIdentityURL]];

  if (!self)
  {
    return nil; // COV_NF_LINE
  }

  _authInfo = [NSMutableDictionary dictionaryWithCapacity:2];
  [_authInfo setValue:[NSMutableDictionary dictionaryWithCapacity:2] forKey:kHPCSAuthKey];

  return self;
}


- (id) initWithBaseURL:(NSURL *)url
{
  self = [super initWithBaseURL:url];
  if (!self)
  {
    return nil; // COV_NF_LINE
  }

  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

  // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
  [self setDefaultHeader:@"Accept" value:@"application/json"];
  [self setParameterEncoding:AFJSONParameterEncoding];

  #if TARGET_OS_IPHONE
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
  #endif

  return self;
}


- (void) credentialsChanged:(NSNotification *)note
{
  self.token = nil;
}


- (NSDictionary *) authorizationInfo
{
  return [self.authInfo copy];
}


- (void) authenticate:( void ( ^)(NSArray * records) )block failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  //{ "auth":{"passwordCredentials":{"username":"theuser", "password":"thepassword"}, "tenantId":"12345"}
  //creds

  [self postPath:@"/v2.0/tokens"
      parameters:[self authorizationInfo]
         success: ^(__unused AFHTTPRequestOperation * operation, id JSON) {
     NSMutableArray *mutableRecords = [NSMutableArray array];
     NSDictionary *tokenAtt = [JSON valueForKeyPath:@"access.token"];
     self.token = [[HPCSToken alloc] initWithAttributes:tokenAtt];

     //TODO - serialize the service catalog on
     NSArray *serviceItems = [JSON valueForKeyPath:@"access.serviceCatalog"];

     for (NSDictionary * attributes in serviceItems)
     {
       //hash with name, type, endpoints[]
       [mutableRecords addObject:[NSMutableDictionary dictionaryWithDictionary:attributes]];
     }

     self.serviceCatalog = [NSArray arrayWithArray:mutableRecords];

     if (block)
     {
       block (self.serviceCatalog);
     }

     self.isTokenValid = YES;
   }
   failure: ^(__unused AFHTTPRequestOperation * operation, NSError * error) {
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSAuthenticationDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     if (failure)
     {
       failure (operation.response,error);
     }
   }
  ];
}

- (BOOL) isTokenExpired
{
  return (self.token ? ([self.token isExpired] ? YES : NO) : YES);
}


- (BOOL) isAuthenticated
{
  return (![self isTokenExpired] && self.serviceCatalog);
}


- (void) tokenInvalidate:( void ( ^)(NSHTTPURLResponse * response) )successBlock failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failureBlock
{
  [self setDefaultHeader:@"X-Auth-Token" value:self.token.tokenId];
  //TODO this needs to set the expected content type to nothing, as the body return is empty
  [self setDefaultHeader:@"Accept" value:nil];
  [self deletePath:[NSString stringWithFormat:@"/v2.0/tokens/%@",self.token.tokenId] parameters:nil success: ^(AFHTTPRequestOperation * operation, id responseObject) {
     [self setDefaultHeader:@"Accept" value:@"application/json"];
     if (successBlock)
     {
       successBlock (operation.response);
     }

     self.isTokenValid = NO;
     [self setToken:nil];
   }
   failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
     [self setDefaultHeader:@"Accept" value:@"application/json"];
     if (failureBlock)
     {
       failureBlock (operation.response,error);
     }
   }
  ];
}

- (HPCSComputeClient *) computeClient
{
  NSString *computeURL = [self publicUrlForCompute];
  if ( IsEmpty(computeURL) )
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:HPCSKeystoneNovaCatalogIsEmptyNotification object:self];
    return nil;
  }

  return [[HPCSComputeClient alloc] initWithIdentityClient:self];
}


- (HPCSSwiftClient *) swiftClient
{
  NSString *swiftURL = [self publicUrlForObjectStorage];
  if ( IsEmpty(swiftURL) )
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:HPCSKeystoneSwiftCatalogIsEmptyNotification object:self];
    return nil;
  }

  return [[HPCSSwiftClient  alloc] initWithIdentityClient:self];
}


- (NSString *) publicUrlForCompute
{
  if ( IsEmpty(self.serviceCatalog) )
  {
    return nil;
  }

  for (id item in self.serviceCatalog)
  {
    if ([[item valueForKey:@"type"] isEqualToString:@"compute"])
    {
      NSDictionary *ep = [[item valueForKey:@"endpoints"] objectAtIndex:0];
      return [ep valueForKey:@"publicURL"];
    }
  }

  return nil;
}


- (NSString *) publicUrlForObjectStorage
{
  if ( IsEmpty(self.serviceCatalog) )
  {
    return nil;
  }

  for (id item in self.serviceCatalog)
  {
    if ([[item valueForKey:@"type"] isEqualToString:@"object-store"])
    {
      NSDictionary *ep = [[item valueForKey:@"endpoints"] objectAtIndex:0];
      return [ep valueForKey:@"publicURL"];
    }
  }

  return nil;
}


- (void) setUsername:(NSString *)userName
{
  if ( IsEmpty(userName) )
  {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:kHPCSAuthUsernameKey];
  }
  else
  {
    [KeychainWrapper createKeychainValue:userName forIdentifier:kHPCSAuthUsernameKey withDescription:@"HPCS username"];
    [self.authInfo setValue:userName
                 forKeyPath:[NSString stringWithFormat:@"%@.%@.%@",kHPCSAuthKey,kHPCSAuthPasswordCredentialsKey,kHPCSAuthUsernameKey]];
  }
}


- (NSString *) username
{
  return [KeychainWrapper keychainStringFromMatchingIdentifier:kHPCSAuthUsernameKey];
}


- (void) setPassword:(NSString *)password1
{
  if ( IsEmpty(password1) )
  {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:kHPCSAuthPasswordKey];
  }
  else
  {
    [KeychainWrapper createKeychainValue:password1 forIdentifier:kHPCSAuthPasswordKey withDescription:@"HPCS password"];
    [self.authInfo setValue:password1
                 forKeyPath:[NSString stringWithFormat:@"%@.%@.%@",kHPCSAuthKey,kHPCSAuthPasswordCredentialsKey,kHPCSAuthPasswordKey]];
  }
}


- (NSString *) password
{
  return [KeychainWrapper keychainStringFromMatchingIdentifier:kHPCSAuthPasswordKey];
}


- (void) setTenantId:(NSString *)tenantId1
{
  if ( IsEmpty(tenantId1) )
  {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:kHPCSAuthTenantIdKey];
  }
  else
  {
    [KeychainWrapper createKeychainValue:tenantId1 forIdentifier:kHPCSAuthTenantIdKey withDescription:@"HPCS tenant id"];
    [self.authInfo setValue:tenantId1
                 forKeyPath:[NSString stringWithFormat:@"%@.%@",kHPCSAuthKey,kHPCSAuthTenantIdKey]];
  }
}


- (NSString *) tenantId
{
  return [KeychainWrapper keychainStringFromMatchingIdentifier:kHPCSAuthTenantIdKey];
}


- (HPCSToken *) token
{
  if (_token)
  {
    return _token;
  }

  id tokenInfo = [[KeychainWrapper keychainStringFromMatchingIdentifier:TOKEN] propertyList];
  if (tokenInfo)
  {
    _token = [[HPCSToken alloc] initWithAttributes:tokenInfo];
    return _token;
  }

  return nil;
}


- (void) setToken:(HPCSToken *)token1
{
  _token = token1;
  if ( IsEmpty(token1) )
  {
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:TOKEN];
  }
  else
  {
    [KeychainWrapper createKeychainValue:[token1.toDictionary description] forIdentifier:TOKEN withDescription:@"HPCS access token"];
  }
}


- (NSArray *) serviceCatalog
{
  if (_serviceCatalog)
  {
    return _serviceCatalog;
  }

  id catalogInfo = [[NSUserDefaults standardUserDefaults] objectForKey:SERVICE_CATALOG];
  if (catalogInfo)
  {
    NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:catalogInfo];
    if (oldSavedArray != nil)
    {
      _serviceCatalog = [[NSMutableArray alloc] initWithArray:oldSavedArray];
      return _serviceCatalog;
    }

    return nil;
  }

  return nil;
}


- (void) setServiceCatalog:(NSArray *)serviceCatalog
{
  _serviceCatalog = serviceCatalog;

  [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:serviceCatalog] forKey:SERVICE_CATALOG];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
