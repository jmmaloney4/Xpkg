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
        rv = YES;
    }
    return rv;
}

+(NSData*)executeCommand:(NSString*)command WithArguments:(NSArray*) args {
    NSTask* task = [[NSTask alloc] init];
    NSPipe* pipe = [NSPipe pipe];
    NSFileHandle* file = [pipe fileHandleForReading];
    NSData* data = [file readDataToEndOfFile];
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setStandardOutput:data];
    [task launch];
    return data;
    
}

+(NSString*) parseArg1:(NSString *)arg {
    if ([UPDATE isEqualToString:arg]) {
        [xpkg print:@"Updating xpkg"];
        [xpkg executeCommand:@"" WithArguments:@[@""]];
        return UPDATE;
    } else if ([INSTALL isEqualToString:arg]) {
        return INSTALL;
    } else {
        [xpkg printError:@"Arguments are invalid"];
        return nil;
    }
}

@end
