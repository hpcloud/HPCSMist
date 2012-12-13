//
//  KeychainWrapper.h
//  ChristmasKeeper
//
//  Created by Ray Wenderlich on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>

/***
*  KeychainWrapper simple wrapper around the secure keychain
*
*  @discussion requires the security framework
*/

@interface KeychainWrapper : NSObject

/**
 Generic exposed method to search the keychain for a given value. Limit one result per search.
 @param identifier key for the stored item
 */
+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier;

/**
 Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.
 
 @param identifier key for the stored item
 
 */
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;

/** Default initializer to store a value in the keychain.
Associated properties are handled for you - setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
 @param value value to set
 @param identifier key for the stored item
 */
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/** Stores a value and a description to the keychain
 @param value value to set
 @param identifier key for the stored item
 @param description a text description of the parameter
 @discussion descriptions are really only useful in OSX, since under IOS there is no way to browse the keychain like there is under OSX.  You can set it but there is no way to see it afterwards.
 
*/

+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier withDescription:(NSString *)description;

/** Updates a value in the keychain. 
 If you try to set the value with createKeychainValue: and it already exists,
 this method is called instead to update the value in place.
 @param value value to set
 @param identifier key for the stored item
*/
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/**Delete a value in the keychain. 
 @param identifier key for the stored item
 */
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;



@end
