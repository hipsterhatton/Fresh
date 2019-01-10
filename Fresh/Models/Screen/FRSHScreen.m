//
//  FRSHScreen.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHScreen.h"

@implementation FRSHScreen

typedef uint64_t CGSManagedDisplay;
typedef int CGSConnection;

extern CGSManagedDisplay kCGSPackagesMainDisplayIdentifier;
extern int CGSManagedDisplayGetCurrentSpace(const CGSConnection cid, CGSManagedDisplay display);
extern CGSConnection _CGSDefaultConnection(void);

- (id)initWithScreen:(NSScreen *)screen
{
    if (self = [super init]) {
        _screen = screen;
        _schedule = [[FRSHSchedule alloc] initWithScreenID:[self getScreenID][@"id"]];
    }
    return self;
}

////
// Get Screen ID and UUID
//
- (NSDictionary *)getScreenID
{
    NSString *_id =     [_screen deviceDescription][@"NSScreenNumber"];
    
    id uuid =           CFBridgingRelease(CGDisplayCreateUUIDFromDisplayID([_screen.deviceDescription[@"NSScreenNumber"] unsignedIntValue]));
    NSString *_uuid =   CFBridgingRelease(CFUUIDCreateString(NULL, (__bridge CFUUIDRef) uuid));;
    
    return @{
             @"id" :    [NSString stringWithFormat:@"%d", [_id intValue]],
             @"uuid" :  _uuid
             };
}

////
// Get the screen dimensiosn for the properrty: _screen
//
- (NSDictionary *)getScreenDimensions
{
    NSSize size = [SDMacVersion deviceScreenResolutionPixelSize:_screen];
    
    int _height =   (int)size.height;
    int _width =    (int)size.width;
    
    return @{
             @"height" : [NSNumber numberWithInt:_height],
             @"width" :  [NSNumber numberWithInt:_width]
             };
}

////
// Check whether `_screen` is the main screen
//
- (BOOL)isScreenMainScreen
{
    NSString *_id =             [self getScreenID][@"id"];
    NSString *_mainScreenId =   [NSString stringWithFormat:@"%d", [[[NSScreen mainScreen] deviceDescription][@"NSScreenNumber"] intValue]];
    
    return ([_id isEqualToString:_mainScreenId]);
}

////
// Check whether screen is currently in fullscreen mode or not
//
- (BOOL)isFullscreen
{
    int _temp = CGSManagedDisplayGetCurrentSpace(_CGSDefaultConnection(), kCGSPackagesMainDisplayIdentifier);
    
    if (_temp == 1) {
        return false;
    } else {
        return true;
    }
}

////
// Update Wallpaper
//
- (NSError *)updateScreenWithWallpaper:(NSString *)pathToImage
{
    // Check if the actual image exists - fire error if not
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToImage isDirectory:NO]) {
        return [NSError errorWithDomain:@"No file at path - wallpaper updater" code:200 userInfo:@{}];
    }
    
    if ([self isFullscreen]) {
        return [self updateWallpaperInFullscreenMode:pathToImage];
    } else {
        return [self updateWallpaperNotInFullscreenMode:pathToImage];
    }
}


////
// Update Desktop wallpaper (currently viewing screen)
//
- (NSError *)updateWallpaperNotInFullscreenMode:(NSString *)pathToImage
{
    NSError *error = nil;
    
    NSURL *_url = [[NSURL alloc] init];
    _url = [NSURL fileURLWithPath:pathToImage];
    
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:_url
                                            forScreen:_screen
                                              options:[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:_screen]
                                                error:&error];
    
    return error;
}


////
// Update Desktop Wallpaper (currently in fullscreen mode)
//
- (NSError *)updateWallpaperInFullscreenMode:(NSString *)pathToImage
{
    NSMutableArray *updateStatements = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSup = [paths firstObject];
    NSString *dbPath = [appSup stringByAppendingPathComponent:@"Dock/desktoppicture.db"];
    
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        const char *sql = [self buildUpdateSQL];
        
        sqlite3_stmt *select_stmt;
        if (sqlite3_prepare_v2(database, sql, -1, &select_stmt, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(select_stmt) == SQLITE_ROW) {
                
                const char *string = (char *)sqlite3_column_text(select_stmt, 0);
                
                [updateStatements addObject:
                 [NSString stringWithFormat:@"UPDATE data SET value='%@' WHERE ROWID=%@", pathToImage, [NSString stringWithUTF8String:string]]
                 ];
            }
        }
        
        for (NSString *updateStmt in updateStatements) {
            
            if (sqlite3_prepare_v2(database, [updateStmt UTF8String], -1, &select_stmt, NULL) == SQLITE_OK) {
                if (sqlite3_exec(database, [updateStmt UTF8String], NULL, NULL, NULL) == SQLITE_OK) {
                }
            }
        }
    }
    
    sqlite3_close(database);
    
    [self killallDock];
    
    return nil;
}


////
// Build SQL statement to update wallpaper details in database
//
- (const char *)buildUpdateSQL
{
    if ([self isScreenMainScreen]) {
        return [self mainScreenUpdateSQL];
    } else {
        return [self notMainScreenUpdateSQL];
    }
}

- (const char *)mainScreenUpdateSQL
{
    NSArray *_array;
    _array = @[
               @"SELECT data.rowid FROM preferences JOIN data ON preferences.data_id=data.ROWID JOIN pictures ON preferences.picture_id=pictures.ROWID JOIN displays ON pictures.display_id=displays.ROWID JOIN spaces ON pictures.space_id=spaces.ROWID WHERE spaces.space_uuid = '' AND displays.display_uuid = '",
               [self getScreenID][@"uuid"],
               @"'"
               ];
    
    return [[_array componentsJoinedByString:@""] UTF8String];
}

- (const char *)notMainScreenUpdateSQL
{
    NSArray *_array;
    _array = @[
               @"SELECT data.rowid, display_uuid,space_uuid,value FROM preferences JOIN data ON preferences.data_id=data.ROWID JOIN pictures ON preferences.picture_id=pictures.ROWID JOIN displays ON pictures.display_id=displays.ROWID JOIN spaces ON pictures.space_id=spaces.ROWID WHERE spaces.space_uuid != '' AND spaces.space_uuid != 'dashboard' AND displays.display_uuid = '",
               [self getScreenID][@"uuid"],
               @"'"
               ];
    
    return [[_array componentsJoinedByString:@""] UTF8String];
}


////
// Kill the Finder Dock - refreshes the wallpaper
//
- (void)killallDock
{
    system("killall Dock");
}

@end

