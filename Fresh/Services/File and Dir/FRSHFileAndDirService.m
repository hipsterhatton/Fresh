//
//  FRSHFileAndDirService.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHFileAndDirService.h"

#define APP_DIR         @"Fresh"
#define IMAGE_DL_DIR    @"Downloads"
#define APP_DATABASE    @"Fresh.sqlite"

@implementation FRSHFileAndDirService

- (id)init
{
    if (self = [super init]) {
        _shuttle = [[Shuttle alloc] initWithDefaults:@{
                                                       @"Accept-Version" : @"v1"
                                                       }];
    }
    
    [self setupAppDirectories];
    [self setupDatabase];
    return self;
}

- (NSError *)setupAppDirectories
{
    NSError *_error;
    BOOL _isDir = YES;
    NSString *_dir;
    
    _dir = [self getDirectoryPath:APP_DIR, nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_dir isDirectory:&_isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_dir withIntermediateDirectories:YES attributes:nil error:&_error];
    }
    
    if (_error) {
        NSLog(@"Error: %@", [_error description]);
    }
    
    _dir = [self getDirectoryPath:APP_DIR, IMAGE_DL_DIR, nil];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_dir isDirectory:&_isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_dir withIntermediateDirectories:YES attributes:nil error:&_error];
    }
    
    if (_error) {
        NSLog(@"Error: %@", [_error description]);
    }
    
    return _error;
}

- (NSError *)setupDatabase
{
    NSError *_error;
    BOOL _isDir = NO;
    NSString *_dir;
    
    _dir = [self getDirectoryPath:APP_DIR, APP_DATABASE, nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_dir isDirectory:&_isDir]) {
        
        // The writable database does not exist, so copy the default to the appropriate location.
        NSString *_defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:APP_DATABASE];
        
        // Copy the database to the location
        _dir = [self getDirectoryPath:APP_DIR, APP_DATABASE, nil];
        
        [[NSFileManager defaultManager] copyItemAtPath:_defaultDBPath toPath:_dir error:&_error];
    }
    
    if (_error) {
        NSLog(@"Error: %@", [_error description]);
    }
    
    return _error;
}

- (NSString *)getDirectoryPath:(NSString *)pathPart, ...
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    va_list args;
    va_start(args, pathPart);
    for (NSString *arg = pathPart; arg != nil; arg = va_arg(args, NSString *)) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:arg];
    }
    va_end(args);
    return documentsDirectory;
}

- (NSError *)writeImageDataToDiskWithFilename:(NSString *)filepath fileData:(NSData *)fileData
{
    NSError *_error;
    [fileData writeToFile:filepath options:NSDataWritingAtomic error:&_error];
    return _error;
}

- (RXPromise *)downloadImageFromURL:(NSString *)imageURL filename:(NSString *)filename forScreen:(FRSHScreen *)screen
{
    [[screen state] setObject:@"about to download image" forKey:@"status"];
    
    return [self.shuttle launch:GET :Image :imageURL :nil]
    
    .then(^id(NSImage *rawImage) {
        NSString *_path = [self getDirectoryPath:APP_DIR, IMAGE_DL_DIR, [NSString stringWithFormat:@"%@.jpg", filename], nil];
        [[screen state] setObject:_path forKey:@"wallpaper_file_path"];
        [[screen state] setObject:@"writing image to disk" forKey:@"status"];
        return [self writeImageDataToDiskWithFilename:_path fileData:[rawImage TIFFRepresentation]];
    }, nil)
    
    .then(^id(id blank) {
        return [self deleteOldDownloadedWallpapers:filename];
    }, nil);
}

- (NSError *)deleteOldDownloadedWallpapers:(NSString *)wallpaperFileName
{
    NSError *_error = nil;
    NSString *_path = [self getDirectoryPath:APP_DIR, IMAGE_DL_DIR, nil];
    NSArray *_listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:&_error];
    __block NSString *_str;
    
    if (_error) {
        return _error;
    }
    
    wallpaperFileName = [self getDirectoryPath:APP_DIR, IMAGE_DL_DIR, [wallpaperFileName stringByAppendingString:@".jpg"]];
    
    for (int _a = 0; _a < [_listOfFiles count]; _a++) {
        _str = [self getDirectoryPath:APP_DIR, IMAGE_DL_DIR, _listOfFiles[_a]];
        
        if (![_str isEqualToString:wallpaperFileName]) {
            [[NSFileManager defaultManager] removeItemAtPath:_str error:&_error];
            if (_error) {
                break;
            }
        }
    }
    
    return _error;
}

@end
