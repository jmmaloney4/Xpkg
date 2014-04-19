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
    BOOL init = NO;
    init = ![fm fileExistsAtPath:[xpkg getPathWithPrefix:@"/core/info/xpkg.db"] isDirectory:NULL];

    self.db = [FMDatabase databaseWithPath:[xpkg getPathWithPrefix:@"/core/info/xpkg.db"]];

    if (![self.db open]) {
        return nil;
    }

    /*
     *  Creates the pkg Table
     */
    if (init) {
        [self.db executeUpdate:@"create table pkgs(pkgid integer primary key autoincrement, package varchar(50), version varchar(20), name varchar(50), description varchar(200), path varchar(75), url varchar(125), mirror1 varchar(125), mirror2 varchar(125), mirror3 varchar(125), mirror4 varchar(125), mirror5 varchar(125), sha varchar(64), rmd varchar(40), maintanier varchar(75), repo integer, installed integer)"];
        // if installed is equal to 0 than it is not installed, else it is installed

        /*
         *  Creates the repos Table
         */
        [self.db executeUpdate:@"create table repos(uid integer primary key autoincrement, name varchar(50), path varhcar(75), url varchar(125))"];

        /*
         *  Creates the deps Table
         */
        [self.db executeUpdate:@"create table deps(pkgid integer primary key, depid integer)"];
    }
    return self;
}

-(XPPackage*) addPackageInfoToDatabase:(XPPackage*) pkg {
    FMResultSet* results = [self.db executeQueryWithFormat:@"select package, repo from pkgs where \"package\" = \"%@\"", pkg.package];
    // Checks for a package by this name, in this repository in the database
    while ([results next]) {
        if ([[results stringForColumn:@"package"] isEqualToString:[NSString stringWithFormat:@"%@", pkg.package]]) {
            // Check for package from repository
            FMResultSet* r = [self.db executeQuery:[NSString stringWithFormat:@"select name from repos where \"name\" = \"%@\"", pkg.repo_name]];
            if ([r next]) {
                if ([[r stringForColumn:@"repo"] isEqualToString:[NSString stringWithFormat:@"%@", pkg.repo_name]]) {
                    [xpkg log:[NSString stringWithFormat:@"Package %@ is already added from repository %@", pkg.package, pkg.repo_name]];
                }
            }
        }
    }

    [self.db executeUpdate:[NSString stringWithFormat:@"insert into pkgs(package, version, name, description, path, url, mirror1, mirror2, mirror3, mirror4, mirror5, sha, rmd, maintainer, installed) values('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', 0)", pkg.package, pkg.version, pkg.name, pkg.description, pkg.path, pkg.url, pkg.mirrors[1], pkg.mirrors[2], pkg.mirrors[3], pkg.mirrors[4], pkg.mirrors[5], pkg.sha256, pkg.rmd160, pkg.maintainer]];

    FMResultSet* x = [self.db executeQueryWithFormat:@"select pkgid from pkgs where \"package\" = \"%@\"", pkg.package];
    if ([x next]) {
        pkg.pkgid = [NSNumber numberWithInt:[x intForColumn:@"pkgid"]];
    }

    for (int a = 0; a < pkg.depends.count; a++) {
        x = [self.db executeQuery:[NSString stringWithFormat:@"select pkgid from pkgs where \"package\" = \"%@\"", pkg.depends[a]]];
        if ([x next]) {
            [self.db executeUpdate:[NSString stringWithFormat:@"insert into deps(pkgid, depid) values('%@', '%@')", pkg.pkgid, [x stringForColumn:@"pkgid"]]];
        } else {
            [xpkg printError:[NSString stringWithFormat:@"Dependancy of %@, %@ does not exist", pkg.package, pkg.depends[a]]];
        }
    }
    return pkg;
}

-(XPRepository*) addRepoToDatabase:(XPRepository*) repo {
    [self.db executeUpdate:[NSString stringWithFormat:@"insert into repos(name, path, url) values('%@', '%@', '%@')", repo.name, repo.path, repo.url]];
    return repo;
}

-(XPRepository*) removeRepoFromDatabase:(XPRepository*) repo {
    [self.db executeUpdate:[NSString stringWithFormat:@"delete from repos where \"url\" = \"%@\"", repo.path]];
    return repo;
}

-(BOOL) repoExistsAtPath:(NSString*) url {
    [xpkg print:@"%@", url];
    FMResultSet* x = [self.db executeQuery:[NSString stringWithFormat:@"select * from repos where \"path\" = \"%@\"", url]];
    if ([x next]) {
        [xpkg print:@"%@", [x stringForColumn:@"path"]];
        return true;
    } else {
        return false;
    }
}

@end
