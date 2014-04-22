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

@implementation XPManager
-(instancetype) init {
    self = [super init];
    return self;
}

-(XPPackage*) addPackageInfoToDatabase:(XPPackage*) pkg {
    return pkg;
}

-(XPPackage*) removePackage:(XPPackage*) pkg {
    return pkg;
}


-(XPRepository*) addRepoToDatabase:(XPRepository*) repo {
    return repo;
}

-(XPRepository*) removeRepoFromDatabase:(XPRepository*) repo {
    return repo;
}

-(BOOL) repoExistsAtPath:(NSString*) url {
    return NO;
}

@end
