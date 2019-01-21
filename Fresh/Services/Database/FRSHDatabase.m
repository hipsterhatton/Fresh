//
//  FRSHDatabase.m
//  Fresh
//
//  Created by Stephen Hatton on 14/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHDatabase.h"

#define APP_FOLDER_NAME         @"Fresh"
#define DATABASE_NAME           @"Fresh.sqlite"
#define TO_FETCH_VIA_FROM_DB    10

@implementation FRSHDatabase

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}



#pragma mark - Private - General Database Methods

////
// Open database connection
//
- (BOOL)openDatabase
{
    _database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    BOOL _openResult = [_database open];
    
    if (!_openResult) {
        _database = nil;
        return false;
    }
    
    return true;
}

////
// Close the database connection
//
- (void)closeDatabase
{
    [_database close];
}

////
// Get path to the database
//
- (NSString *)getDatabasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    
    documentsDirectory =  [documentsDirectory stringByAppendingPathComponent:APP_FOLDER_NAME];
    documentsDirectory =  [documentsDirectory stringByAppendingPathComponent:DATABASE_NAME];
    return documentsDirectory;
}



#pragma mark - Public - Read/Write Methods

////
// SQL Read/Write methods: write, read, delete
//
- (BOOL)writeToDatabase:(NSDictionary *)dataToWrite
{
    [self openDatabase];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (![_database executeUpdate:@"INSERT INTO wallpaper_history VALUES(?, ?, ?, ?)",
          dataToWrite[@"wallpaper_id"],
          dataToWrite[@"wallpaper_url"],
          dataToWrite[@"screen_id"],
          [formatter stringFromDate:[NSDate date]]]) {
        NSLog(@"Error: INSERT INTO: %@", [_database lastErrorMessage]);
        [self closeDatabase];
        return false;
    }
    
    [self closeDatabase];
    return true;
}

- (NSArray *)readFromDatabase
{
    [self openDatabase];
    
    int _totalNumberOfImages = 0;
    
    FMResultSet *_count = [_database executeQuery:@"SELECT COUNT(*) FROM wallpaper_history"];
    if ([_count next]) {
        _totalNumberOfImages = [_count intForColumnIndex:0];
    }
    
    // If we've already fetched all the images...
    if (_numberOfImagesFetched >= _totalNumberOfImages) {
        [self closeDatabase];
        return @[];
    }
    
    NSMutableArray *imageID = [[NSMutableArray alloc] init];
    
    NSString *_sqlQuery = [NSString stringWithFormat:@"SELECT * FROM wallpaper_history LIMIT %d OFFSET %d;", TO_FETCH_VIA_FROM_DB, _numberOfImagesFetched];
    FMResultSet *sqlQuery = [_database executeQuery:_sqlQuery];
    
    while ([sqlQuery next]) {
        [imageID addObject:[sqlQuery stringForColumnIndex:0]];
    }
    
    // Start: 0, next call: 10, etc.
    _numberOfImagesFetched += 10;
    
    [self closeDatabase];
    return imageID;
}

- (void)purgeDatabase
{
    [self openDatabase];
    
    if (![_database executeUpdate:@"DELETE FROM wallpaper_history;"]) {
        NSLog(@"Failed to delete wallpaper details from database: %@", [_database lastErrorMessage]);
    }
}

@end
