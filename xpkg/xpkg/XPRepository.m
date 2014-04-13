//
//  Repository.m
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import "XPRepository.h"
#import "xpkg.h"

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


-(void) add {
    NSFileManager* filem = [[NSFileManager alloc] init];
    [filem createDirectoryAtPath:[xpkg getPathWithPrefix:@"/core/repos"] withIntermediateDirectories:true attributes:nil error:nil];
    NSFileHandle* repos;

    if (![filem fileExistsAtPath:[xpkg getPathWithPrefix:@"/core/info/repos"]]) {
        NSData* data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        [filem createFileAtPath:[xpkg getPathWithPrefix:@"/core/info/repos"] contents:data attributes:nil];
    }

    repos = [NSFileHandle fileHandleForReadingAtPath:[xpkg getPathWithPrefix:@"/core/info/repos"]];

    NSArray* rf = [[xpkg getStringFromData:[repos readDataToEndOfFile]] componentsSeparatedByString:@"\n"];

    [xpkg print:[xpkg getStringFromData:[repos readDataToEndOfFile]]];

    for (int z = 0; z < rf.count; z++) {
        if (!([rf[z] rangeOfString:self.url].location == NSNotFound)) {
            [xpkg printError:@"Repository already exists"];
            return;
        } else {
            [xpkg print:rf[z]];
        }
    }

    [xpkg printInfo:[NSString stringWithFormat:@"Adding Repository from %@", self.url]];

    // Parse Repo name from URL
    NSArray* u = [self.url componentsSeparatedByString:@"/"];
    u = [u[u.count - 1] componentsSeparatedByString:@"."];

    [filem createDirectoryAtPath:[xpkg getPathWithPrefix:@"/core/repos"] withIntermediateDirectories:true attributes:nil error:nil];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"add", @"--force", self.url] andPath:[xpkg getPathWithPrefix:@"/core/repos"] printErr:false printOut:false returnOut:false];

    NSString* path = [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/core/repos/%@/REPO", u[0]]];

    NSString* name = [xpkg parseRepoFile:path][0];

    NSString* s = [NSString stringWithFormat:@"====\n"];
    s = [s stringByAppendingString:[NSString stringWithFormat:@"@NAME: %@\n", name]];
    s = [s stringByAppendingString:[NSString stringWithFormat:@"@PATH: %@\n", [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/core/repos/%@", name]]]];
    s = [s stringByAppendingString:[NSString stringWithFormat:@"@URL: %@\n", self.url]];

    NSString* contents = @"";
    contents = [NSString stringWithContentsOfFile:[xpkg getPathWithPrefix:@"/core/info/repos"] encoding:NSUTF8StringEncoding error:nil];
    contents = [contents stringByAppendingString:s];
    [repos writeData:[contents dataUsingEncoding:NSUTF8StringEncoding]];
    
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
