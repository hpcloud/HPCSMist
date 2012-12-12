//
//  SwiftObjectSpec.m
//  HPCSIOSSampler
//
//  Created by Mike Hagedorn on 8/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "HPCSSwiftObject.h"


SPEC_BEGIN(SwiftObjectSpec)
describe (@"SwiftObject",^{
    context(@"after creation", ^{
        it(@"should have an empty filelocation", ^{
            id object = [[HPCSSwiftObject alloc] init];
            [[object url] shouldBeNil];
        });
        it(@"should have an empty image", ^{
            id object = [[HPCSSwiftObject alloc] init];
            [[object image] shouldBeNil];
        });
        context(@"and you have set the url",^{
            it(@"sets the right mime type", ^{
               HPCSSwiftObject *object = [[HPCSSwiftObject alloc ]init];
               object.url = [NSURL URLWithString:@"test/abc.gif"];
               [[[object.url pathExtension] should] equal:@"gif"];
               [[[object mimeTypeForFile] should] equal:@"image/gif"];
            });

        });

    });

});

SPEC_END


