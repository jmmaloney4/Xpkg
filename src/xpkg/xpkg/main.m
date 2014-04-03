//
//  main.m
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "xpkg.h"

int argc;
const char * argv[];

int main(int argc, const char * argv[])
{

    @autoreleasepool {
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
            } else {
                [xpkg print:@"no args"];
            }
        } else if ([VERSION_ARG isEqualToString:arg]) {
            [xpkg print:VERSION];
        } else if ([@"-h" isEqualToString:arg] || [@"" isEqualToString:arg]) {
            [xpkg print:USAGE];
            [xpkg print:HELP_TEXT];
        } else {
            [xpkg printError:@"Arguments are invalid"];
            [xpkg print:USAGE];
        }
    }
    return 0;
}

NSString* getArg(int index) {
    if (index > argc) {
        return nil;
    }
    return [NSString stringWithUTF8String:argv[index]];
}
