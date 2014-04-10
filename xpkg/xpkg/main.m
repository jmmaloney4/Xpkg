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

        NSString* init_log = @"\n\n\n========== Started Logging Session ";
        init_log = [init_log stringByAppendingString:[xpkg getTimestamp]];
        init_log = [init_log stringByAppendingString:@" ==========\n\n"];

        [xpkg log:init_log];
        [xpkg printXpkg];
        [xpkg print:RESET];

        [xpkg checkForArgs:argc];
        NSString* arg = [NSString stringWithUTF8String:argv[1]];

        if ([UPDATE isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            [xpkg updateProgram];
        } else if ([ADD isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            [xpkg addRepository:[NSString stringWithUTF8String:argv[2]]];
        } else if ([INSTALL isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            if (argc > 2) {
                [xpkg installPackage:[NSString stringWithUTF8String:argv[2]]];
            }
        } else if ([VERSION_ARG isEqualToString:arg]) {
            [xpkg print:VERSION];
        } else if ([@"-v" isEqualToString:arg] || [@"--version" isEqualToString:arg]) {
            [xpkg print:[NSString stringWithFormat:@"Xpkg Advanced Packaging System \nVersion: %@", VERSION]];
        } else if ([@"-h" isEqualToString:arg] || [@"" isEqualToString:arg]) {
            [xpkg print:USAGE];
            [xpkg print:[NSString stringWithFormat:@"Xpkg Advanced Packaging System \nVersion: %@", VERSION]];
            [xpkg print:HELP_TEXT];
        } else if ([CLEAR_LOG isEqualToString:arg]) {
            [xpkg exitIfNotRoot];
            [xpkg clearLog];
        } else if ([@"log" isEqualToString:arg]) {
            system([[NSString stringWithFormat:@"less %@", [xpkg getPathWithPrefix:@"/log/xpkg.log"]] UTF8String]);
        } else if ([VIEW isEqualToString:arg]) {
            //VIEW COMMAND
        } else if ([@"-l" isEqualToString:arg] || [@"--license" isEqualToString:arg]) {
            system([[NSString stringWithFormat:@"less %@", [xpkg getPathWithPrefix:@"/LICENSE"]] UTF8String]);
        } else {
            [xpkg printError:@"Arguments are invalid"];
            [xpkg print:USAGE];
        }
    }
}
