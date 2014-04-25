//
//  xpkg, Advanced Package Management For Mac OS X
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "XPManager.h"
#import "XPPackage.h"
#import "XPRepository.h"
#import "xpkg.h"
#import <sqlite3.h>

@implementation XPManager

-(instancetype) init {

    NSString* dbpath = [xpkg getPathWithPrefix:@"/core/xpkg.db"];
    BOOL init = false;
    NSFileManager* f = [[NSFileManager alloc] init];
    
    init = ![f fileExistsAtPath:dbpath];

    if (self = [super init]) {
        sqlite3 *dbConnection;
        if (sqlite3_open([dbpath UTF8String], &dbConnection) != SQLITE_OK) {
            [xpkg printError:@"Unable to open package database"];
            return nil; // if it fails, return nil obj
        }
        self.db = dbConnection;
    }
    
    if (init) {
        [self SQLExec:@"CREATE TABLE pkgs(id integer primary key autoincrement, package varchar(50), version varchar(20), name varchar(50), description varchar(200), path varchar(75), url varchar(125), mirror1 varchar(125), mirror2 varchar(125), mirror3 varchar(125), mirror4 varchar(125), mirror5 varchar(125), sha varchar(64), rmd varchar(40), maintainer varchar(75), repo integer, installed integer)"];
    
        [self SQLExec:@"CREATE TABLE repos(id integer primary key autoincrement, name varchar(50), path varhcar(75), url varchar(125))"];
    
        [self SQLExec:@"CREATE TABLE deps(pkgid integer primary key, depid integer)"];
    }
    
    return self;
}

-(NSArray*) SQLExec:(NSString*) query, ... {
    
    va_list formatArgs;
    va_start(formatArgs, query);
    NSString* str = [[NSString alloc] initWithFormat:query arguments:formatArgs];
    query = str;
    va_end(formatArgs);
    
    sqlite3_stmt *statement = nil;
    const char *sql = [query UTF8String];
    if (sqlite3_prepare_v2(self.db, sql, -1, &statement, NULL) != SQLITE_OK) {
        [xpkg printError:@"[SQLITE] Error when preparing query!"];
    } else {
        NSMutableArray *result = [NSMutableArray array];
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableArray *row = [NSMutableArray array];
            for (int i = 0; i < sqlite3_column_count(statement); i++) {
                int colType = sqlite3_column_type(statement, i);
                id value;
                if (colType == SQLITE_TEXT) {
                    const unsigned char *col = sqlite3_column_text(statement, i);
                    value = [NSString stringWithFormat:@"%s", col];
                } else if (colType == SQLITE_INTEGER) {
                    int col = sqlite3_column_int(statement, i);
                    value = [NSNumber numberWithInt:col];
                } else if (colType == SQLITE_FLOAT) {
                    double col = sqlite3_column_double(statement, i);
                    value = [NSNumber numberWithDouble:col];
                } else if (colType == SQLITE_NULL) {
                    value = [NSNull null];
                } else {
                    [xpkg printError:@"[SQLITE] UNKNOWN DATATYPE"];
                }
                
                [row addObject:value];
            }
            [result addObject:row];
        }
        return result;
    }
    return nil;
}

-(XPPackage*) addPackageInfoToDatabase:(XPPackage*) pkg {
    [self SQLExec:@"INSERT INTO pkgs(package, version, name, description, path, url, mirror1, mirror2, mirror3, mirror4, mirror5, sha, rmd, maintainer, repo, installed) VALUES('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d', 0)", pkg.package, pkg.version, pkg.name, pkg.description, pkg.path, pkg.url, pkg.mirrors[0], pkg.mirrors[1], pkg.mirrors[2], pkg.mirrors[3], pkg.mirrors[4], pkg.sha256, pkg.rmd160, pkg.maintainer, [self getRepoID:pkg.repo_name]];
    return pkg;
}

-(XPPackage*) removePackage:(XPPackage*) pkg {
    return pkg;
}


-(XPRepository*) addRepoToDatabase:(XPRepository*) repo {
    [self SQLExec:@"INSERT INTO repos(name, path, url) values('%@', '%@', '%@')", repo.name, repo.path, repo.url];
    return repo;
}

-(XPRepository*) removeRepoFromDatabase:(XPRepository*) repo {
    return repo;
}

-(int) getRepoID:(NSString*) repo {
    return 0;
}

-(BOOL) repoExistsAtPath:(NSString*) url {
    return NO;
}

@end
