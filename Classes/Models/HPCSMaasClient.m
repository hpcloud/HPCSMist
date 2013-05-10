//
//  HPCSMaasClient.m
//  HPCSMist
//
//  Created by Mike Hagedorn on 5/9/13.
//  Copyright (c) 2013 Mike Hagedorn. All rights reserved.
//

#import <AFNetworking/AFJSONRequestOperation.h>
#import "HPCSMaasClient.h"
#import "HPCSIdentityClient.h"

NSString *const HPCSMaasOperationDidFailNotification = @"com.hp.cloud.maas.operation.fail";

@implementation HPCSMaasClient

- (id)initWithIdentityClient:(HPCSIdentityClient *)identity {
    self = [super initWithBaseURL:[NSURL URLWithString:[identity publicUrlForMonitoring]]];
    self.identityClient = identity;
    if (!self)
    {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    if (self.identityClient)
    {
        [self setDefaultHeader:@"X-Auth-Token" value:self.identityClient.token.tokenId];
    }

    return self;
}

- (void)endpoints:(void (^)(NSArray *))block
          failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    [self getPath:@"endpoints" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        NSArray *serverArr = [JSON valueForKeyPath:@"endpoints"];
        for (NSDictionary * sdata in serverArr)
        {
            [mutableRecords addObject:sdata];
        }

        if (block)
        {
            block ([NSArray arrayWithArray:mutableRecords]);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[error, MaasObjectEndpoint, MaasObjectOperationList] forKeys:@[NSErrorKey, MaasObjectKey, MaasOperationKey]];

              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSMaasOperationDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              if (failure)
              {
                  failure (operation.response,error);
              }
          }
    ];

}

- (void)saveEndpoint:(id)endpoint
             success:(void (^)(NSHTTPURLResponse *, NSData *))saved
             failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)endpointDetailsFor:(id)endpoint
                   success:(void (^)(id endpointData))block
                   failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    NSString *detailsPath = [NSString stringWithFormat:@"endpoints/%@", [endpoint valueForKeyPath:@"endpointId"]];
    [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSDictionary *endpointData = [JSON valueForKeyPath:@"endpoint"];
        if (block)
        {
            block (endpointData);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaServersShowDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              failure (operation.response,error);
          }
    ];

}

- (void)deleteEndpoint:(id)endpoint
               success:(void (^)(NSHTTPURLResponse *))deleted
               failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)resetPasswordForEndpoint:(id)endpoint
                         success:(void (^)(NSHTTPURLResponse *, NSData *))deleted
                         failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)subscriptions:(void (^)(NSArray *))block
              failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

    [self getPath:@"subscriptions" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        NSArray *serverArr = [JSON valueForKeyPath:@"subscriptions"];
        for (NSDictionary * sdata in serverArr)
        {
            [mutableRecords addObject:sdata];
        }

        if (block)
        {
            block ([NSArray arrayWithArray:mutableRecords]);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[error, MaasObjectSubscription, MaasObjectOperationList] forKeys:@[NSErrorKey, MaasObjectKey, MaasOperationKey]];

              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSMaasOperationDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              if (failure)
              {
                  failure (operation.response,error);
              }
          }
    ];

}

- (void)saveSubscription:(id)subscription
                 success:(void (^)(NSHTTPURLResponse *, NSData *))saved
                 failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)subscriptionDetailsFor:(id)endpoint
                       success:(void (^)(id subscriptionDetails))saved
                       failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    NSString *detailsPath = [NSString stringWithFormat:@"subscriptions/%@", [endpoint valueForKeyPath:@"subscriptionId"]];
    [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSDictionary *subscriptionData = [JSON valueForKeyPath:@"subscription"];
        if (saved)
        {
            saved (subscriptionData);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[error, MaasObjectSubscription, MaasObjectOperationGet] forKeys:@[NSErrorKey, MaasObjectKey, MaasOperationKey]];

              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSMaasOperationDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              failure (operation.response,error);
          }
    ];


}

- (void)deleteSubscription:(id)subscription
                   success:(void (^)(NSHTTPURLResponse *))deleted
                   failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)alarms:(void (^)(NSArray *))block
       failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    [self getPath:@"alarms" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        NSArray *serverArr = [JSON valueForKeyPath:@"alarms"];
        for (NSDictionary * sdata in serverArr)
        {
            [mutableRecords addObject:sdata];
        }

        if (block)
        {
            block ([NSArray arrayWithArray:mutableRecords]);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[error, MaasObjectAlarm, MaasObjectOperationList] forKeys:@[NSErrorKey, MaasObjectKey, MaasOperationKey]];

              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSMaasOperationDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              if (failure)
              {
                  failure (operation.response,error);
              }
          }
    ];


}

- (void)saveAlarm:(id)alarm1
          success:(void (^)(NSHTTPURLResponse *, NSData *))saved
          failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    [self postPath:<#(NSString *)path#> parameters:<#(NSDictionary *)parameters#> success:<#(void (^)(AFHTTPRequestOperation *, id))success#> failure:<#(void (^)(AFHTTPRequestOperation *, NSError *))failure#>];


}

- (void)alarmDetailsFor:(id)alarm1
                success:(void (^)(id alarmDetails))saved
                failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    NSString *detailsPath = [NSString stringWithFormat:@"alarms/%@", [alarm1 valueForKeyPath:@"alarmId"]];
    [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSDictionary *alarmData = [JSON valueForKeyPath:@"alarm"];
        if (saved)
        {
            saved (alarmData);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[error, MaasObjectAlarm, MaasObjectOperationGet] forKeys:@[NSErrorKey, MaasObjectKey, MaasOperationKey]];

              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSMaasOperationDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              failure (operation.response,error);
          }
    ];

}

- (void)deleteAlarm:(id)alarm1
            success:(void (^)(NSHTTPURLResponse *))deleted
            failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)notificationMethods:(void (^)(NSArray *))block
                    failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {
    [self getPath:@"notification-methods" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
        NSMutableArray *mutableRecords = [NSMutableArray array];
        NSArray *serverArr = [JSON valueForKeyPath:@"notification_methods"];
        for (NSDictionary * sdata in serverArr)
        {
            [mutableRecords addObject:sdata];
        }

        if (block)
        {
            block ([NSArray arrayWithArray:mutableRecords]);
        }
    }
          failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[error, MaasObjectNotificationMethod, MaasObjectOperationList] forKeys:@[NSErrorKey, MaasObjectKey, MaasOperationKey]];

              [[NSNotificationCenter defaultCenter] postNotificationName:HPCSMaasOperationDidFailNotification
                                                                  object:self
                                                                userInfo:userInfo];
              if (failure)
              {
                  failure (operation.response,error);
              }
          }
    ];

}

- (void)saveNotificationMethod:(id)notificationMethod
                       success:(void (^)(NSHTTPURLResponse *, NSData *))saved
                       failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)notificationMethodDetailsFor:(id)notificationMethod
                             success:(void (^)(id notificationDetails))saved
                             failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (void)deleteNotificationMethod:(id)alarm1
                         success:(void (^)(NSHTTPURLResponse *))deleted
                         failure:(void (^)(NSHTTPURLResponse *, NSError *))failure {

}

- (NSDictionary *)dictionaryToCreateAlarm:(id) alarmInfo{
   return @{
           @"alarm": @{
                @"name" : [alarmInfo valueForKey:@"name"],
                @"expression" : [alarmInfo valueForKey:@"expression"],
                @"alarm_actions" : [alarmInfo valueForKey:@"alarm_actions"],
           }
    };
}


@end
