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

-(XPPackage*) addPackageInfoToDatabase:(XPPackage*)pkg;
-(XPPackage*) removePackage:(XPPackage*) pkg;
-(BOOL) repoExistsAtPath:(NSString*) url;
-(XPRepository*) addRepoToDatabase:(XPRepository*) repo;
-(XPRepository*) removeRepoFromDatabase:(XPRepository*) repo;
@end
