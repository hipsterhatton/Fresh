//
//  FRSHScreen.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "FRSHScreen.h"
#import "SDMacVersion.h"

@interface FRSHScreen : NSObject

@property (nonatomic, retain) NSScreen *screen;

- (id)initWithScreen:(NSScreen *)screen;
- (NSDictionary *)getScreenID;
- (NSDictionary *)getScreenDimensions;
- (BOOL)isScreenMainScreen;
- (BOOL)isFullscreen;
@end
