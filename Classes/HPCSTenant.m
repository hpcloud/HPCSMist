//
//  Tenant.m
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HPCSTenant.h"

@implementation HPCSTenant
@synthesize name;
@synthesize tenantId;

- (id)initWithAttributes:(NSDictionary *)attributes{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [attributes valueForKeyPath:@"name"];
    self.tenantId = [attributes valueForKeyPath:@"id"];
    
    
    return self;
    
}

@end
