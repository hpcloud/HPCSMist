//
//  Enviroment.m
//  HPCSStatus
//
//  Created by Mike Hagedorn on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "Environment.h"
#import "HPCSCommonMacros.h"



NSString * const kHPCSIdentityBaseURLString = @"https://region-a.geo-1.identity.hpcloudsvc.com:35357";

@implementation Environment

@synthesize HPCSIdentityURL;

-(void)initializeSharedInstance{
    NSString* configuration = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *envsPListPath = [bundle pathForResource:@"Environments" ofType:@"plist"];
    NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfFile:envsPListPath];
    NSDictionary *environment = [environments objectForKey:configuration];
    self.HPCSIdentityURL = [environment objectForKey:@"HPCSIdentityURL"];
    if(IsEmpty(self.HPCSIdentityURL)){
        self.HPCSIdentityURL = kHPCSIdentityBaseURLString;
    }

}

+ (Environment *)sharedInstance {
    static Environment *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
        [_sharedClient initializeSharedInstance];
    });
    
    return _sharedClient;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@",self.HPCSIdentityURL];
}

@end
