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

+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path {
    NSString* rv;
    NSTask* task = [[NSTask alloc] init];
    
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setCurrentDirectoryPath:path];
    
    NSPipe* pipe =[NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    
    NSData* data = [file readDataToEndOfFile];
    
    rv= [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return rv;
}

+(NSString*) parseArg1:(NSString *)arg {
    if ([UPDATE isEqualToString:arg]) {
        
        return UPDATE;
    } else if ([ADD isEqualToString:arg]) {
        return ADD;
    } else if ([INSTALL isEqualToString:arg]) {
        return INSTALL;
    } else {
        [xpkg printError:@"Arguments are invalid"];
        return nil;
    }
}

+(NSString*) getPathWithPrefix:(NSString*)path {
    NSMutableString* rv;
    
    return rv;
}


@end
