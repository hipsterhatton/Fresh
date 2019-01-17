//
//  FRSHApp.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHApp.h"

#define SCHEDULE_TIMER_CHECK_EVERY_X_SECONDS    5

@implementation FRSHApp

- (id)init
{
    if (self = [super init]) {
        [self setupScreensWithNotifications:YES];
        [self setupServices];
        [self startTimer];
        [[[_screens firstObject] schedule] setScheduleEveryXMinutes:1 startingFrom:nil];
    }
    return self;
}

- (void)setupScreensWithNotifications:(BOOL)setupNotification
{
    if (!_screens) {
        _screens = [NSMutableArray new];
    }
    
    [_screens removeAllObjects];
    
    for (int _a = 0; _a < [[NSScreen screens] count]; _a++) {
        FRSHScreen *_screen = [[FRSHScreen alloc] initWithScreen:[NSScreen screens][_a]];
        [_screens addObject:_screen];
    }
    
    if (!setupNotification) {
        return;
    }
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidChangeScreenParametersNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setScreenChangeNotification:)
                                                 name:NSApplicationDidChangeScreenParametersNotification
                                               object:nil];
}

- (void)setScreenChangeNotification:(NSNotification *)notification
{
    // Whenever a `screen has changed` notif. is fired
    // Clear the array, re-add all the screens...
    
    NSLog(@"Screen has changed...");
    [self setupScreensWithNotifications:NO];
}

- (void)setupServices
{
    _fileAndDirService = [FRSHFileAndDirService new];
    _wallpaperAPI = [FRSHUnsplashAPI new];
    _database = [FRSHDatabase new];
}

- (RXPromise *)downloadWallpaperForScreen:(FRSHScreen *)screen
{
    [[screen state] setObject:@"start: download and update procedure" forKey:@"status"];
    
    return [_wallpaperAPI getWallpaperURLForScreen:screen]
    
    .then(^id (NSDictionary *data) {
        [[screen state] setObject:data[@"id"] forKey:@"wallpaper_id"];
        [[screen state] setObject:[self getWallpaperFileName:screen] forKey:@"wallpaper_file_name"];
        return [_fileAndDirService downloadImageFromURL:data[@"url"] filename:[self getWallpaperFileName:screen] forScreen:screen];
    }, nil)
    
    .then(^id (id blank) {
        [[screen state] setObject:@"done: deleting old Unsplash image(s)" forKey:@"status"];
        return @"OK";
    }, nil)
    
    .then(^id (id blank) {;
        [[screen state] setObject:@"start: writing data to database" forKey:@"status"];
        [_database writeToDatabase:[screen state]];
        [[screen state] setObject:@"done: writing data to database" forKey:@"status"];
        return @"OK";
    }, nil)
    
    .then(^id (id blank) {
        [screen updateScreenWithWallpaper:[screen state][@"wallpaper_file_path"]];
        return @"OK";
    }, nil)
    
    .then(^id (id blank) {
        [[screen state] setObject:@"done: update wallpaper" forKey:@"status"];
        NSLog(@"...done!");
        NSLog(@"%@", [screen state]);
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError* error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return error;
    });
}

- (NSString *)getWallpaperFileName:(FRSHScreen *)screen
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    return [NSString stringWithFormat:@"%@_%@", [screen getScreenID][@"uuid"], [dateFormatter stringFromDate:[NSDate date]]];
}

- (void)startTimer
{
    _checkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:SCHEDULE_TIMER_CHECK_EVERY_X_SECONDS
                                                           target:self
                                                         selector:@selector(checkScreenSchedules)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)stopTimer
{
    [_checkScheduleTimer invalidate];
    _checkScheduleTimer = nil;
}

- (void)checkScreenSchedules
{
    NSLog(@"Checking schedules...");
    
    for (FRSHScreen *_screen in _screens) {
        NSLog(@"Screen: %@ - next download: %@", [_screen getScreenID][@"id"], [[_screen schedule] downloadSchedule][@"next_download_datetime"]);
        
        if ([[_screen schedule] timeToDownload]) {
            NSLog(@"Downloading fresh wallpaper...");
            [self downloadWallpaperForScreen:_screen];
        }
    }
}

- (void)loadAppAtLaunch
{
    if (![[NSBundle mainBundle] isLoginItem]) {
        [[NSBundle mainBundle] addToLoginItems];
        NSLog(@"Added Fresh to login items...");
    } else {
        NSLog(@"Fresh already added to login items...");
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
