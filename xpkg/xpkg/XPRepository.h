//
//  Repository.h
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPRepository : NSObject

@property NSString* url;
@property NSString* name;
@property NSString* maintainer;
@property NSString* path;
@property NSArray* packages;
@property NSInteger* uid;

-(instancetype) initWithPath:(NSString*)path;
-(instancetype) initWithURL:(NSString*)url;
-(void) add;
-(void) remove;

+(int) getRepoIDForName:(NSString*) name;

@end
