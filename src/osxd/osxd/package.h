//
//  package.h
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface package : NSObject
@property NSURL* URL;
@property NSString* path;
-(NSInteger)install;
-(id) initWithURL:(NSURL*)URL;
@end
