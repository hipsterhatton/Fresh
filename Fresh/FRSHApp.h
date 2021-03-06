//
//  FRSHApp.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <IYLoginItem/NSBundle+LoginItem.h>

#import "MenuBar.h"

#import "FRSHScreen.h"
#import "FRSHDatabase.h"
#import "FRSHFileAndDirService.h"
#import "FRSHUnsplashAPI.h"

@interface FRSHApp : NSObject

typedef enum {
    StartingDownload,
    FinishedDownload,
    ErrorDuringDownload
} FreshState;

@property (nonatomic, retain) MenuBar *menubarUI;

@property (nonatomic, retain) NSTimer *checkScheduleTimer;
@property (nonatomic, retain) NSMutableArray *screens;
@property (nonatomic, retain) FRSHDatabase *database;
@property (nonatomic, retain) FRSHFileAndDirService *fileAndDirService;
@property (nonatomic, retain) FRSHUnsplashAPI *wallpaperAPI;

- (RXPromise *)downloadWallpaperForScreen:(FRSHScreen *)screen;

@end
