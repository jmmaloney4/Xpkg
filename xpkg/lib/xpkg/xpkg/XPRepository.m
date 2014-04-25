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

#import "XPRepository.h"
#import "xpkg.h"
#import "XPManager.h"

@implementation XPRepository

-(instancetype) initWithURL:(NSString*)url {
    self = [super init];
    self.url = url;
    NSArray* u = [self.url componentsSeparatedByString:@"/"];
    u = [u[u.count - 1] componentsSeparatedByString:@"."];
    self.name = u[0];
    [xpkg print:self.name];
    self.path = [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/core/repos/%@", self.name]];
    return self;
}

-(instancetype) initWithPath:(NSString*)path {
    self = [super init];

    self.path = path;
    NSArray* u = [self.url componentsSeparatedByString:@"/"];
    self.name = u [u.count - 1];
    return self;
}

-(void) add {
    XPManager* manager = [[XPManager alloc] init];

    if ([manager repoExistsAtPath:self.path]) {
        [xpkg printError:@"Repo Already Exists"];
        return;
    }

    NSFileManager* filem = [[NSFileManager alloc] init];

    [xpkg printInfo:[NSString stringWithFormat:@"Adding Repository from %@", self.url]];
    
    [xpkg addAndCommit];
    [filem createDirectoryAtPath:[xpkg getPathWithPrefix:@"/core/repos"] withIntermediateDirectories:true attributes:nil error:nil];
    [xpkg addAndCommit];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"add", @"--force", self.url] andPath:[xpkg getPathWithPrefix:@"/core/repos"] printErr:false printOut:false returnOut:false];
    [xpkg addAndCommit];
    
    NSString* repoFilePath = [NSString stringWithFormat:@"%@/REPO", self.path];

    self.name = [xpkg parseRepoFile:repoFilePath][0];
    self.maintainer = [xpkg parseRepoFile:repoFilePath][1];
    
    [manager addRepoToDatabase:self];
    
    // Scan packages
    NSMutableArray* pkgs;
    NSArray* cons = [filem contentsOfDirectoryAtPath:self.path error:nil];
    for (int d = 0; d < cons.count; d++) {
        if (![xpkg fileIsIgnoredInRepo:cons[d]]) {
            // Add Package to sqlite3 database
            XPPackage* pkg = [[XPPackage alloc] initWithpath:[NSString stringWithFormat:@"%@/%@", self.path, cons[d]] andRepo:self.name];
            [pkgs insertObject:cons[d] atIndex:d];
            [manager addPackageInfoToDatabase:pkg];
        }
    }
    [xpkg print:@"\tDone."];
}

-(void) remove {
    NSArray* r = [self.path componentsSeparatedByString:@"/"];
    NSString* d = r[r.count - 1];

    XPManager* manager = [[XPManager alloc] init];

    if (![manager repoExistsAtPath:self.path]) {
        [xpkg printError:@"Repository Does Not Exist"];
        return;
    }
    NSFileManager* filem = [[NSFileManager alloc] init];
    NSMutableArray* pkgs;
    NSArray* cons = [filem contentsOfDirectoryAtPath:self.path error:nil];
    for (int a = 0; a < cons.count; a++) {
        [pkgs insertObject:cons[a] atIndex:a];
        if (![xpkg fileIsIgnoredInRepo:cons[a]]) {
            // Add Package to sqlite3 database
            XPPackage* pkg = [[XPPackage alloc] initWithpath:[NSString stringWithFormat:@"%@/%@", self.path, cons[a]] andRepo:self.name];
            [xpkg print:self.name];
            [manager removePackage:pkg];
        }
    }

    [manager removeRepoFromDatabase:self];

    [xpkg printInfo:[NSString stringWithFormat:@"Removing Repository at %@", self.path]];

    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"deinit", @"-f", [NSString stringWithFormat:@"./%@", d]] andPath:[xpkg getPathWithPrefix:@"/core/repos/"] printErr:false printOut:false];

    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"rm", @"-f", [NSString stringWithFormat:@"./%@", d]] andPath:[xpkg getPathWithPrefix:@"/core/repos/"] printErr:false printOut:false];

    [xpkg addAndCommit];
    
    [xpkg print:@"\tDone."];
}
/*
+(int) getRepoIDForName:(NSString*) name {
    int rv = -1;

    XPManager* x = [[XPManager alloc] init];
    FMResultSet* f = [x.db executeQuery:[NSString stringWithFormat:@"select * from repos where \"name\" = \"%@\"", name]];
    if ([f next]) {
        return [f intForColumn:@"uid"];
    }
    return rv;
}
*/
@end
