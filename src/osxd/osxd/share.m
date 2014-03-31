//
//  share.m
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "share.h"

@implementation share
+(NSFileHandle*) getConfigFile {
    NSFileHandle * config = [NSFileHandle fileHandleForReadingAtPath:CONFIG_FILE];
    if (!config) {
        NSTask *mkconf = [[NSTask alloc] init];
        [mkconf setLaunchPath:@"/bin/mkdir"];
        [mkconf setArguments:[NSArray arrayWithObjects: @"/opt/",CONFIG_PATH, nil]];
        [mkconf launch];
        NSTask *mkcnf = [[NSTask alloc] init];
        [mkcnf setLaunchPath:@"/usr/bin/touch"];
        [mkcnf setArguments:[NSArray arrayWithObjects: CONFIG_FILE, nil]];
        [mkcnf launch];
    }
    config = [NSFileHandle fileHandleForReadingAtPath:CONFIG_FILE];
    return config;
}

+(NSString*) getConfigFileString {
    NSData *data = [[share getConfigFile] readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return string;
}

+(BOOL) exitIfNotRoot {
    if (getuid() == 0) {
        return YES;
    } else {
        [share print:@"Must Be Root\n"];
        exit(1);
        return NO;
    }
}

+(void) printUsage {
    [share print:USAGE];
}

+(void) print:(NSString*) x {
    printf("%s", [x UTF8String]);
}

+(void) createPackage:(NSString*)path withFromat:(NSInteger*)type {
    NSTask* tar = [[NSTask alloc]init];
    [tar setLaunchPath:@"/usr/bin/tar"];
    NSMutableString* out = [[NSMutableString alloc] initWithUTF8String:[path UTF8String]];
    if (type == 0) {
        [out appendString:@".xbp"];
    } else {
        [out appendString:@".xsp"];
    }
    [tar setArguments:@[@"-cj", @"--format", @"ustar", path, @">", out]];
}

@end
