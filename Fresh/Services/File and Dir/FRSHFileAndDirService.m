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

- (NSError *)writeImageDataToDiskWithFilename:(NSString *)filename fileData:(NSData *)fileData
{
    NSError *_error;
    
    NSString *path = [self getDirectoryPath:APP_DIR, IMAGE_DL_DIR, nil];
    path = [path stringByAppendingPathComponent:filename];
    
    [fileData writeToFile:path options:NSDataWritingAtomic error:&_error];
    
    return _error;
}

- (RXPromise *)downloadImageFromURL:(NSString *)imageURL filename:(NSString *)filename
{
    return [self.shuttle launch:GET :Image :imageURL :nil]
    
    .then(^id(NSImage *rawImage) {
        NSString *_imageName = [NSString stringWithFormat:@"%@.jpg", filename];
        return [self writeImageDataToDiskWithFilename:_imageName fileData:[rawImage TIFFRepresentation]];
    }, nil);
}

@end
