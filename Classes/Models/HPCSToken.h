//
//  Token.h
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPCSTenant.h"

/** Object which represents the credentials */
@interface HPCSToken : NSObject
/** When the token expires **/
@property (readwrite,retain) NSDate *expires;

/** The token id which will be included in each authenticated call */
@property (readwrite,retain) NSString *tokenId;

/** The tenant */
@property (retain) HPCSTenant *tenant;

/** an NSDictionary representation of the token */
@property (retain) NSDictionary *toDictionary;
/** Create the tenant
    designated intializer
    @param attributes stuff to create the tenant
 */
- (id) initWithAttributes:(NSDictionary *)attributes;
/** is the token expired */
- (BOOL) isExpired;

@end
