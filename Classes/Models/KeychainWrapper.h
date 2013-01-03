//
//  KeychainWrapper.h
//  ChristmasKeeper
//
//  Created by Ray Wenderlich on 12/6/11.
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
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>

/***
 *  KeychainWrapper simple wrapper around the secure keychain
 *
 *  @discussion requires the security framework
 */

@interface KeychainWrapper : NSObject

///--------------------
/// @name Searching for values in Keychain
///--------------------

/**
   Generic exposed method to search the keychain for a given value. Limit one result per search.
   @param identifier key for the stored item
 */
+ (NSData *) searchKeychainCopyMatchingIdentifier:(NSString *)identifier;

/**
   Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.

   @param identifier key for the stored item

 */
+ (NSString *) keychainStringFromMatchingIdentifier:(NSString *)identifier;

///--------------------
/// @name Create, update or Delete Keychain items
///--------------------

/** Default initializer to store a value in the keychain.
   Associated properties are handled for you - setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
   @param value value to set
   @param identifier key for the stored item
 */
+ (BOOL) createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/** Stores a value and a description to the keychain
   @param value value to set
   @param identifier key for the stored item
   @param description a text description of the parameter
   @discussion descriptions are really only useful in OSX, since under IOS there is no way to browse the keychain like there is under OSX.  You can set it but there is no way to see it afterwards.

 */

+ (BOOL) createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier withDescription:(NSString *)description;

/** Updates a value in the keychain.
   If you try to set the value with createKeychainValue: and it already exists,
   this method is called instead to update the value in place.
   @param value value to set
   @param identifier key for the stored item
 */
+ (BOOL) updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/**Delete a value in the keychain.
   @param identifier key for the stored item
 */
+ (void) deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

@end
