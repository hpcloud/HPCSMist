//
// Created by Mike Hagedorn on 11/20/12.
//
//   © Copyright 2013 Hewlett-Packard Development Company, L.P.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@class HPCSIdentityClient;

/** HTTPClient which adds the appropriate token to the request */
@interface HPCSAuthorizedHTTPClient : AFHTTPClient

/** The HPCSIdentityClient object used to get access to the HPCSToken. */
@property(retain) HPCSIdentityClient *identityClient;

///-----------------------------------------------------
/// @name Creating and Initializing HPCSAuthorizedHTTPClient Clients
///-----------------------------------------------------

/**
 Creates a  client
 @param client the HPCSIdentityClient to use as the Identity Service Client
 @discussion This is designated initializer. Typically its called in the following fashion (implicitly) from a singleton instance of HPCSIdentityClient
 
 */
- (id) initWithIdentityClient:(HPCSIdentityClient *)client;


+ (id) sharedClient: (HPCSIdentityClient *)identityClient;

//Abstract method
- (NSString *)serviceURL:(HPCSIdentityClient *)identity;

@end
