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

#import <Foundation/Foundation.h>
#import "XPRepository.h"

@interface XPPackage : NSObject

-(instancetype) initWithpath:(NSString*)path;
-(instancetype) initWithpath:(NSString*)path andRepo:(NSString*)repon;
@property NSString* url;
@property NSString* package;
@property NSString* description;
@property NSString* maintainer;
@property NSString* version;
@property NSString* path;
@property NSString* name;
@property NSString* homepage;
@property NSString* sha256;
@property NSString* rmd160;
@property NSArray* mirrors;
@property NSArray* depends;
@property NSArray* dependers;
@property NSArray* recomended;
@property NSString* repo_name;
@property NSInteger* pkgid;

-(BOOL) install;
-(BOOL) remove;
@end
