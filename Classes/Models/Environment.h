//
//  Enviroment.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 3/12/12.
//  Copyright (C) 2012 HP Cloud Services, Mike Hagedorn All rights reserved.
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

extern NSString *const kHPCSIdentityBaseURLString;

/** Describes a operating environment in the HPCS system.
 *  @discussion HP has several environments, but this code
 *  knows about two
 *
 *  - RNDD
 *  - Production
 */
@interface Environment : NSObject

/** the URL endpoint for the Enviroment in question, HP has several */
@property (retain) NSString *HPCSIdentityURL;

/** The singleton loaded from Environments.plist.  Picks the environment to set from Info.plist **Configuration** key
   @discussion if there is no Info.plist **Configuration** key, or there is no Environment defined for the **Configuration** key then it just returns the production identity URL value
 */
+ (Environment *) sharedInstance;

@end
