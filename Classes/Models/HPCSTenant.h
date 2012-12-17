//
//  Tenant.h
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
/** The tenant in the HPCS identity system */
@interface HPCSTenant : NSObject

/** the name of the tenant */
@property (retain) NSString *name;

/** the unique indentifier of the tenant */
@property (retain) NSString *tenantId;

/** Initializes the category with the given attributes.

   This is the designated initializer.

   @param attributes The NSDictionary of attributes.

   @discusssion The passed in NSDictionary must support the following keys:  **name** and **id**

 */

- (id) initWithAttributes:(NSDictionary *)attributes;

@end
