//
//  xpkg.m
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import "xpkg.h"

@implementation xpkg

+(void) printError:(NSString *)x {
    printf("%sError:%s%s", [BOLDRED UTF8String], [RESET UTF8String], [x UTF8String]);
}

+(BOOL) checkForArgs:(int)argc {
    BOOL rv = NO;
    if (argc < 2) {
        rv = YES;
    }
    return rv;
}

@end
