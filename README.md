HPCSMist
========

a delightful interface to HP Cloud Services for IOS and OSX.  It's built on top of
[AFNetworking](https://github.com/AFNetworking/AFNetworking)
and other familiar Foundation technologies. 

## How To Get Started


### Get The Source
- [Download HPCSMist](https://git.hpcloud.net/hagedorm/HPCSMist)

### Add HPCSMist To Your Project

Instead of adding the source files directly to your project, you may
want to consider using [CocoaPods](http://cocoapods.org/) to manage your dependencies. Follow the
instructions on the CocoaPods site to install the gem, and specify
HPCSMist as a dependency in your Podfile with pod 'HPCSMist',
'0.0.1'.


- Check out the [complete documentation](http://15.184.93.121/) for a
comprehensive look at the APIs available in HPCSMist

## Overview

### Authentication To Control Services


  HPCSIdentityClient identity = [HPCSIdentityClient sharedClient];
  [identity setUsername:@"myuser"];
  [identity setPassword:@"mypassword"];
  [identity setTenantId:@"12345"];

  //on success caches the auth token, assuming success, ignoring failures
  [identity authenticate:nil failure:nil]; 


### Get A Compute Instance


  HPCSComputeClient *nova = [identity computeClient];

  //list active servers
  [nova servers:^(NSArray * records){
    NSLog(@"got an array of servers");
  }
  failure:^(NSHTTPURLResponse * response, NSError * error){
    NSLog(@"couldnt get server list");
  }


### Get An Object Storage Instance


  HPCSSwiftClient *swift = [identity swiftClient];

  //list containers
  [swift containers:^(NSArray * records){
    NSLog(@"got an array of containers");
  }
  failure:^(NSHTTPURLResponse * response, NSError * error){
    NSLog(@"couldnt get container list");
  }





