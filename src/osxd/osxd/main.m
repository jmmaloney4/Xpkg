//
//  main.m
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "share.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc < 2) {
            [share printUsage];
            exit(1);
        }
        
        if ([INSTALL isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            if (argc < 3) {
                printf("%s\n", [@"install command requires at least one argument" UTF8String]);
                exit(1);
            } else {
                NSString* confstr = [share getConfigFileString];
            }
        } else if ([ADD isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            
            
            
        } else if ([REINSTALL isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            
        } else if ([REMOVE isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            
        } else if ([BUILD isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            
        } else if ([@"-h" isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            //TODO print help
        } else {
            [share printUsage];
        }
    }
    exit(0);
    return 0;
}
