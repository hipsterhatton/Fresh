//
//  FRSHApp.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHApp.h"

@implementation FRSHApp

- (id)init
{
    if (self = [super init]) {
    }
    
    [self setupScreensWithNotifications:YES];
    [self setupServices];
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
}

- (RXPromise *)downloadWallpaperForScreen:(FRSHScreen *)screen
{
    [[screen state] setObject:@"time to download" forKey:@"status"];
    
    return [_wallpaperAPI getWallpaperURLForScreen:screen]
    
    .then(^id (NSString *wallpaperURL) {
        [[screen state] setObject:[self getWallpaperFileName:screen] forKey:@"wallpaper_file_name"];
        return [_fileAndDirService downloadImageFromURL:wallpaperURL filename:[self getWallpaperFileName:screen] forScreen:screen];
    }, nil)
    
    .then(^id (id blank) {
        [[screen state] setObject:@"done" forKey:@"status"];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
