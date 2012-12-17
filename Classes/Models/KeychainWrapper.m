//
//  KeychainWrapper.m
//  ChristmasKeeper
//
//  Created by Ray Wenderlich on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KeychainWrapper.h"
#import "HPCSSecurityConstants.h"
#import "HPCSCommonMacros.h"

@implementation KeychainWrapper
// *** NOTE *** This class is ARC compliant - any references to CF classes must be paired with a "__bridge" statement to
// cast between Objective-C and Core Foundation Classes.  WWDC 2011 Video "Introduction to Automatic Reference Counting" explains this.
// *** END NOTE ***
+ (NSMutableDictionary *) setupSearchDirectoryForIdentifier:(NSString *)identifier
{
  // Setup dictionary to access keychain.
  NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
  // Specify we are using a password (rather than a certificate, internet password, etc).
  [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  // Uniquely identify this keychain accessor.
  [searchDictionary setObject:APP_NAME forKey:(__bridge id)kSecAttrService];

  // Uniquely identify the account who will be accessing the keychain.
  NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
  [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
  [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];

  return searchDictionary;
}


+ (NSData *) searchKeychainCopyMatchingIdentifier:(NSString *)identifier
{
  NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
  // Limit search results to one.
  [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

  // Specify we want NSData/CFData returned.
  [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

  // Search.
  NSData *result = nil;
  CFTypeRef foundDict = NULL;
  OSStatus status = SecItemCopyMatching( (__bridge CFDictionaryRef)searchDictionary, &foundDict );

  if (status == noErr)
  {
    result = (__bridge_transfer NSData *)foundDict;
  }
  else
  {
    result = nil;
  }

  return result;
}


+ (NSString *) keychainStringFromMatchingIdentifier:(NSString *)identifier
{
  NSData *valueData = [self searchKeychainCopyMatchingIdentifier:identifier];
  if (valueData)
  {
    NSString *value = [[NSString alloc] initWithData:valueData
                                            encoding:NSUTF8StringEncoding];
    return value;
  }
  else
  {
    return nil;
  }
}


+ (BOOL) createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier withDescription:(NSString *)description
{
  NSMutableDictionary *dictionary = [self setupSearchDirectoryForIdentifier:identifier];
  NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
  [dictionary setObject:valueData forKey:(__bridge id)kSecValueData];
  if ( !IsEmpty(description) )
  {
    [dictionary setValue:[description dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrDescription];
  }

  // Protect the keychain entry so it's only valid when the device is unlocked.
  [dictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];

  // Add.
  OSStatus status = SecItemAdd( (__bridge CFDictionaryRef)dictionary, NULL );

  // If the addition was successful, return. Otherwise, attempt to update existing key or quit (return NO).
  if (status == errSecSuccess)
  {
    return YES;
  }
  else if (status == errSecDuplicateItem)
  {
    return [self updateKeychainValue:value forIdentifier:identifier];
  }
  else
  {
    return NO;
  }
}


+ (BOOL) createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier
{
  return [self createKeychainValue:value forIdentifier:identifier withDescription:nil];
}


+ (BOOL) updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier
{
  NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
  NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
  NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
  [updateDictionary setObject:valueData forKey:(__bridge id)kSecValueData];

  // Update.
  OSStatus status = SecItemUpdate( (__bridge CFDictionaryRef)searchDictionary,
                                   (__bridge CFDictionaryRef)updateDictionary );

  if (status == errSecSuccess)
  {
    return YES;
  }
  else
  {
    return NO;
  }
}


+ (void) deleteItemFromKeychainWithIdentifier:(NSString *)identifier
{
  NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
  CFDictionaryRef dictionary = (__bridge CFDictionaryRef)searchDictionary;

  //Delete.
  SecItemDelete(dictionary);
}


@end
