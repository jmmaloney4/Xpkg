//
//  xpkg.m
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import "xpkg.h"

@implementation xpkg

+(void) print:(NSString*) x {
    printf("%s", [x UTF8String]);
}

+(void) printError:(NSString *)x {
    printf("%sError:%s%s", [BOLDRED UTF8String], [RESET UTF8String], [x UTF8String]);
}

+(BOOL) checkForArgs:(int)argc {
    BOOL rv = NO;
    if (argc < 2) {
        [xpkg print:USAGE];
        exit(1);
        rv = NO;
    } else {
        rv = YES;
        return rv;
    }
    return rv;
}

+(int)executeCommand:(NSString*)command {
    int rv = system([command UTF8String]);
    return rv;
    
}

+(NSString*) parseArg1:(NSString *)arg {
    if ([UPDATE isEqualToString:arg]) {
        return UPDATE;
    } else if ([ADD isEqualToString:arg]) {
        [xpkg commandAdd];
        return ADD;
    } else if ([INSTALL isEqualToString:arg]) {
        return INSTALL;
    } else {
        [xpkg printError:@"Arguments are invalid"];
        return nil;
    }
}

+(void) commandAdd {
    [xpkg print:@"ADDING"];
    [xpkg executeCommand:@"cd /opt/xpkg"];
    [xpkg executeCommand:@"ls"];
}

@end
