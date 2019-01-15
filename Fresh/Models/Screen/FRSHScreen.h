//
//  FRSHScreen.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "FRSHScreen.h"
#import "FRSHSchedule.h"
#import "SDMacVersion.h"

@interface FRSHScreen : NSObject

@property (nonatomic, retain) FastData *storedData;
@property (nonatomic, retain) NSScreen *screen;
@property (nonatomic, retain) FRSHSchedule *schedule;
@property (nonatomic, retain) NSMutableDictionary *state;

- (id)initWithScreen:(NSScreen *)screen;
- (NSArray *)getScreenCollections;
- (void)setScreenCollection:(NSArray *)collections;
- (NSDictionary *)getScreenState;
- (NSDictionary *)getScreenID;
- (NSDictionary *)getScreenDimensions;
- (BOOL)isScreenMainScreen;
- (BOOL)isFullscreen;
- (NSError *)updateScreenWithWallpaper:(NSString *)pathToImage;
@end
