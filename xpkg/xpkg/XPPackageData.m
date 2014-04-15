//
//  XPPackageData.m
//  xpkg
//
//  Created by Jack Maloney on 4/14/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import "XPPackageData.h"

@implementation XPPackageData

-(instancetype) initWithManager:(XPManager*) manager {
    self = [super init];

    if (!manager) {
        self = nil;
        return self;
    }

    self.manager = manager;

    return self;
}

@end
