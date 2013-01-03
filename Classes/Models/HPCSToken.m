//
//  Token.m
//  HPCSMist
//
//  Created by Mike Hagedorn on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HPCSToken.h"

@implementation HPCSToken
@synthesize expires;
@synthesize tokenId;
@synthesize tenant;

- (id) init {
  self = [super init];
  if (!self)
  {
    return nil;
  }
  self.toDictionary = @{};
  return self;
}

- (id) initWithAttributes:(NSDictionary *)attributes
{
  self = [self init];
  if (!self)
  {
    return nil;
  }

  self.toDictionary = attributes;
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

  self.expires = [dateFormatter dateFromString:[attributes valueForKeyPath:@"expires"]];
  self.tokenId = [attributes valueForKeyPath:@"id"];
  self.tenant = [[HPCSTenant alloc] initWithAttributes:[attributes valueForKeyPath:@"tenant"]];

  return self;
}


- (BOOL) isExpired
{
  if ([self.expires timeIntervalSinceNow] > 0)
  {
    return NO;
  }
  else
  {
    return YES;
  }
}


- (NSString *) description
{
  return [NSString stringWithFormat:@"%@ expires:%@ tenant:%@",self.tokenId, self.expires, self.tenant.tenantId];
}


@end
