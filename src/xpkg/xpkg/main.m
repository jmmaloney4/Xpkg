//
//  main.m
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "xpkg.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        NSString* init_log = @"\n\n\n==========Started Logging Session ";
        init_log = [init_log stringByAppendingString:[xpkg getTimestamp]];
        init_log = [init_log stringByAppendingString:@"==========\n\n"];

        [xpkg log:init_log];

        [xpkg checkForArgs:argc];
        NSString* arg = [NSString stringWithUTF8String:argv[1]];

        if ([UPDATE isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            [xpkg updateProgram];
        } else if ([ADD isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
        } else if ([INSTALL isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            if (argc > 2) {
                [xpkg installPackage:[NSString stringWithUTF8String:argv[2]]];
            }
        } else if ([VERSION_ARG isEqualToString:arg]) {
            [xpkg print:VERSION];
        } else if ([@"-h" isEqualToString:arg] || [@"" isEqualToString:arg]) {
            [xpkg print:USAGE];
            [xpkg print:HELP_TEXT];
        } else if ([CLEAR_LOG isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            [xpkg clearLog];
        } else {
            [xpkg printError:@"Arguments are invalid"];
            [xpkg print:USAGE];
        }
    }
    return 0;
}
