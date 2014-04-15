//
//  Repository.m
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import "XPRepository.h"
#import "xpkg.h"
#include "XPManager.h"

@implementation XPRepository

-(instancetype) initWithURL:(NSString*)url {
    self = [super init];
    self.url = url;
    NSArray* u = [self.url componentsSeparatedByString:@"/"];
    u = [u[u.count - 1] componentsSeparatedByString:@"."];
    self.name = u[0];
    self.path = [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/core/repos/%@", self.name]];
    return self;
}

+(XPRepository*) getRepoFromPath:(NSString*) path {
    // get a url from db for the repository at the path
    // XPRepository* repo = [[XPRepository alloc] initWithURL:];
    return nil;
}


-(void) add {
    XPManager* manager = [[XPManager alloc] init];

    if ([manager repoExistsAtPath:self.path]) {
        [xpkg printError:@"Repo Already Exists"];
        return;
    }

    NSFileManager* filem = [[NSFileManager alloc] init];

    [xpkg printInfo:[NSString stringWithFormat:@"Adding Repository from %@", self.url]];


    [filem createDirectoryAtPath:[xpkg getPathWithPrefix:@"/core/repos"] withIntermediateDirectories:true attributes:nil error:nil];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"add", @"--force", self.url] andPath:[xpkg getPathWithPrefix:@"/core/repos"] printErr:false printOut:false returnOut:false];

    NSString* repoFilePath = [NSString stringWithFormat:@"%@/REPO", self.path];

    self.name = [xpkg parseRepoFile:repoFilePath][0];
    self.maintainer = [xpkg parseRepoFile:repoFilePath][1];

    [manager addRepoToDatabase:self];

    [xpkg print:@"\tDone."];
}

-(void) remove {
    NSArray* r = [self.path componentsSeparatedByString:@"/"];
    NSString* d = r[r.count - 1];

    [xpkg printInfo:[NSString stringWithFormat:@"Removing Repository at %@", self.path]];

    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"deinit", @"-f", [NSString stringWithFormat:@"./%@", d]] andPath:[xpkg getPathWithPrefix:@"/core/repos/"] printErr:false printOut:false];

    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"rm", @"-f", [NSString stringWithFormat:@"./%@", d]] andPath:[xpkg getPathWithPrefix:@"/core/repos/"] printErr:false printOut:false];

    [xpkg addAndCommit];
    [xpkg print:@"\tDone."];

    // Needs to remove Repo entry from the repo db file
}

@end
