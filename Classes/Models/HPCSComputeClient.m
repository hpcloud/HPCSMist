//
//  HPCSComputeClient.m
//  HPCSMist



#import "HPCSIdentityClient.h"
#import "HPCSAuthorizedHTTPClient.h"
#import "HPCSComputeClient.h"
#import "AFJSONRequestOperation.h"

NSString *const HPCSNovaServersListDidFailNotification = @"com.hp.cloud.nova.servers.fail";
NSString *const HPCSNovaServersDeleteDidFailNotification = @"com.hp.cloud.nova.servers.delete.fail";
NSString *const HPCSNovaServersShowDidFailNotification = @"com.hp.cloud.nova.servers.show.fail";
NSString *const HPCSNovaFlavorsDidFailNotification = @"com.hp.cloud.nova.flavors.fail";
NSString *const HPCSNovaFlavorDetailsDidFailNotification = @"com.hp.cloud.nova.flavors.detail.fail";
NSString *const HPCSNovaImagesDidFailNotification = @"com.hp.cloud.nova.images.fail";
NSString *const HPCSNovaImageDetailsDidFailNotification = @"com.hp.cloud.nova.images.detail.fail";

@implementation HPCSComputeClient


// COV_NF_START
+ (id) sharedClient: (HPCSIdentityClient *)identityClient
{
    static id _sharedClient = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        //or use the access key id stuff and secret key
        _sharedClient = [[self alloc] initWithIdentityClient:identityClient];
    }
    );

    return _sharedClient;
}
// COV_NF_END

- (NSString *)serviceURL:(id)identity {
    return [identity performSelector:@selector(publicUrlForCompute)];
}


- (void) servers:( void ( ^)(NSArray * records) )block
         failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  [self getPath:@"servers" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
     NSMutableArray *mutableRecords = [NSMutableArray array];
     NSArray *serverArr = [JSON valueForKeyPath:@"servers"];
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
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaServersListDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     if (failure)
     {
       failure (operation.response,error);
     }
   }
  ];
}

- (void) terminateServer:(id)server
                 success:( void ( ^)(NSHTTPURLResponse * response) )success
                 failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  NSString *serverPath = [NSString stringWithFormat:@"servers/%@", [server valueForKeyPath:@"serverId"]];
  [self deletePath:serverPath parameters:nil success: ^(AFHTTPRequestOperation * operation, NSError * error) {
     if (success)
     {
       success (operation.response);
     }
   }
   failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaServersDeleteDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     failure (operation.response,error);
   }
  ];
}

- (void) serverDetailsFor:(id)server success:( void ( ^)(id serverInfo) )block
                  failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  NSString *detailsPath = [NSString stringWithFormat:@"servers/%@", [server valueForKeyPath:@"serverId"]];
  [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
     NSDictionary *serverData = [JSON valueForKeyPath:@"server"];
     if (block)
     {
       block (serverData);
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

- (void) flavors:( void ( ^)(NSArray * records) )block
         failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  [self getPath:@"/flavors" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
     NSMutableArray *mutableRecords = [NSMutableArray array];
     NSArray *flavArray = [JSON valueForKeyPath:@"flavors"];
     for (NSDictionary * fData in flavArray)
     {
       [mutableRecords addObject:fData];
     }

     if (block)
     {
       block ([NSArray arrayWithArray:mutableRecords]);
     }
   }
   failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaFlavorsDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     if (failure)
     {
       failure (operation.response,error);
     }
   }
  ];
}

- (void) flavorDetailsFor:(id)flavor success:( void ( ^)(id flavorInfo) )block
                  failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  NSString *detailsPath = [NSString stringWithFormat:@"flavors/%@", [flavor valueForKeyPath:@"flavorId"]];
  [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
     NSDictionary *flavorData = [JSON valueForKeyPath:@"flavor"];
     if (block)
     {
       block (flavorData);
     }
   }
   failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaFlavorDetailsDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     if (failure)
     {
       failure (operation.response,error);
     }
   }
  ];
}

- (void) images:( void ( ^)(NSArray * records) )block
        failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  [self getPath:@"images" parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
     NSMutableArray *mutableRecords = [NSMutableArray array];
     NSArray *imgArray = [JSON valueForKeyPath:@"images"];
     for (NSDictionary * iData in imgArray)
     {
       [mutableRecords addObject:iData];
     }

     if (block)
     {
       block ([NSArray arrayWithArray:mutableRecords]);
     }
   }
   failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaImagesDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     if (failure)
     {
       failure (operation.response,error);
     }
   }
  ];
}

- (void) imageDetailsFor:(id)image success:( void ( ^)(id imageInfo) )block
                 failure:( void ( ^)(NSHTTPURLResponse * response, NSError * error) )failure
{
  NSString *detailsPath = [NSString stringWithFormat:@"images/%@", [image valueForKeyPath:@"imageId"]];
  [self getPath:detailsPath parameters:nil success: ^(AFHTTPRequestOperation * operation, id JSON) {
     NSDictionary *imageData = [JSON valueForKeyPath:@"image"];
     if (block)
     {
       block (imageData);
     }
   }
   failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
     //
     NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"NSError"];
     [[NSNotificationCenter defaultCenter] postNotificationName:HPCSNovaImageDetailsDidFailNotification
                                                         object:self
                                                       userInfo:userInfo];
     if (failure)
     {
       failure (operation.response,error);
     }
   }
  ];
}

@end
