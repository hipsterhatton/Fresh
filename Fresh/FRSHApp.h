//
//  FRSHApp.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "FRSHScreen.h"

#import "FRSHFileAndDirService.h"
#import "FRSHUnsplashAPI.h"

@interface FRSHApp : NSObject

@property (nonatomic, retain) NSMutableArray *screens;
@property (nonatomic, retain) FRSHFileAndDirService *fileAndDirService;
@property (nonatomic, retain) FRSHUnsplashAPI *wallpaperAPI;
@property (nonatomic, retain) NSTimer *checkScheduleTimer;

- (RXPromise *)downloadWallpaperForScreen:(FRSHScreen *)screen;

@end
