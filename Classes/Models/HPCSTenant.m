//
//  Tenant.m
//  HPCSMist
//
//

#import "HPCSTenant.h"

@implementation HPCSTenant
@synthesize name;
@synthesize tenantId;

- (id) initWithAttributes:(NSDictionary *)attributes
{
  self = [super init];
  if (!self)
  {
    return nil;
  }

  self.name = [attributes valueForKeyPath:@"name"];
  self.tenantId = [attributes valueForKeyPath:@"id"];

  return self;
}


@end
