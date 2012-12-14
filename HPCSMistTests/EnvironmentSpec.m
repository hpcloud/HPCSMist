//
//  HPCSSwiftClientSpec.m
//  HPCSIOSSampler
//
//  Created by Mike Hagedorn on 8/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "Environment.h"


SPEC_BEGIN(EnvironmentSpec)

  describe(@"Environment", ^{
      context(@"when newly created", ^{
          context(@"and there is no configuration specified in the main bundle", ^{
            it(@"should have the correct identity URL", ^{
                Environment *e = [Environment sharedInstance];
                [[e.HPCSIdentityURL should] equal:@"https://region-a.geo-1.identity.hpcloudsvc.com:35357"];
            });
            it(@"should print the appropriate URL in its description", ^{
              Environment *e = [Environment sharedInstance];
              [[[e description] should] equal:@"https://region-a.geo-1.identity.hpcloudsvc.com:35357"];
            });

          });
      });
  });


SPEC_END


