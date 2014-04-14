//
//  XPManager.m
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import "XPManager.h"
#import "xpkg.h"

@implementation XPManager
-(instancetype) init {
    self = [super init];
    NSFileManager* fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:[xpkg getPathWithPrefix:@"/core/info/xpkgs.db"]]) {

    }

    self.db = [FMDatabase databaseWithPath:[xpkg getPathWithPrefix:@"/core/info/xpkgs.db"]];
    if (![self.db open]) {
        return nil;
    } else {
        return self;
    }
}

@end
