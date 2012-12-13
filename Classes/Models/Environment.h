//
//  Enviroment.h
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kHPCSIdentityBaseURLString;

/** Describes a operating environment in the HPCS system.
*  @discussion HP has several environments, but this code
*  knows about two
*
*  - RNDD
*  - Production
 */
@interface Environment : NSObject

/** the URL endpoint for the Enviroment in question, HP has several */
@property (retain) NSString *HPCSIdentityURL;

/** The singleton loaded from Environments.plist.  Picks the environment to set from Info.plist **Configuration** key 
 @discussion if there is no Info.plist **Configuration** key, or there is no Environment defined for the **Configuration** key then it just returns the production identity URL value
 */
+ (Environment *)sharedInstance;

@end
