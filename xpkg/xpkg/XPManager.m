//
//  XPManager.m
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import "XPManager.h"
#import "XPPackage.h"
#import "XPRepository.h"
#import "xpkg.h"

@implementation XPManager
-(instancetype) init {
    self = [super init];
    NSFileManager* fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:[xpkg getPathWithPrefix:@"/core/info/xpkg.db"]]) {
        // INIT DATABASE
        [self.db executeUpdate:@"create table pkgs(pkgid integer primary key autoincrement, package varchar(50), version varchar(20), name varchar(50), description varchar(200), path varchar(75), url varchar(125), mirror1 varchar(125), mirror2 varchar(125), mirror3 varchar(125), mirror4 varchar(125), mirror5 varchar(125), sha varchar(64), rmd varchar(40), maintanier varchar(75), repo integer)"];
        [self.db executeUpdate:@"create table repos(uid integer primary key autoincrement, name varchar(50), path varhcar(75), url varchar(125))"];
        [self.db executeUpdate:@"create table deps(pkgid integer primary key, depid integer)"];
    }
    self.db = [FMDatabase databaseWithPath:[xpkg getPathWithPrefix:@"/core/info/xpkg.db"]];
    if (![self.db open]) {
        return nil;
    } else {
        return self;
    }
}

-(void) addPackageInfoToDatabase:(XPPackage*) pkg {
    [self.db executeUpdateWithFormat:@"insert into pkgs(package, version, name, description, path, url, mirror1, mirror2, mirror3, mirror4, mirror5, sha, rmd, maintainer) values('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", pkg.package, pkg.version, pkg.name, pkg.description, pkg.path, pkg.url, pkg.mirrors[1], pkg.mirrors[2], pkg.mirrors[3], pkg.mirrors[4], pkg.mirrors[5], pkg.sha256, pkg.rmd160, pkg.maintainer];

    FMResultSet* x = [self.db executeQueryWithFormat:@"select pkgid from pkgs where \"package\" = \"%@\"", pkg.package];
    if ([x next]) {
        pkg.pkgid = [NSNumber numberWithInt:[x intForColumn:@"pkgid"]];
    }

    for (int a = 0; a < pkg.depends.count; a++) {
        x = [self.db executeQueryWithFormat:@"select pkgid from pkgs where \"package\" = \"%@\"", pkg.depends[a]];
        if ([x next]) {
            [self.db executeUpdateWithFormat:@"insert into deps(pkgid, depid) values('%@', '%@')", pkg.pkgid, [x stringForColumn:@"pkgid"]];
        } else {
            [xpkg printError:[NSString stringWithFormat:@"Dependancy of %@, %@ does not exist", pkg.package, pkg.depends[a]]];
        }
    }
}

-(void) addRepoToDatabase:(XPRepository*) repo {
    
}

-(BOOL) repoExistsAtPath:(NSString*) url {
    FMResultSet* x = [self.db executeQueryWithFormat:@"select url from repos where \"url\" = \"%@\"", url];
    if (![x next]) {
        return true;
    } else {
        return false;
    }
}

@end
