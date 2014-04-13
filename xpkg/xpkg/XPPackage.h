//
//  package.h
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPPackage : NSObject

@property NSString* url;
@property NSString* package;
@property NSString* description;
@property NSString* version;
@property NSString* path;
@property NSString* name;
@property NSString* homepage;
@property NSString* sha256;
@property NSString* rmd160;
@property NSArray* depends;
@property NSArray* dependers;
@property NSArray* recomended;

-(instancetype) initWithpath:(NSString*)path;
-(BOOL) install;
-(BOOL) remove;
@end
