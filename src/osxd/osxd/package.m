//
//  package.m
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import "package.h"
#import <Foundation/Foundation.h>

@implementation package
-(NSInteger)install {
    NSInteger* rv = 0;
    
    return *rv;
}

-(void)download {
    if (!self.URL) {
        
    }
}

-(id) initWithURL:(NSURL*)URL {
    self = [super init];
    self.URL = URL;
    return self;
}
@end
