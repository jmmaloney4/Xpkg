//
//  XPManager.h
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "XPRepository.h"
#import "XPPackage.h"

@interface XPManager : NSObject
@property FMDatabase* db;

-(void) addPackageInfoToDatabase:(XPPackage*)pkg;
-(BOOL) repoExistsAtPath:(NSString*) url;
-(void) addRepoToDatabase:(XPRepository*) repo;
@end
