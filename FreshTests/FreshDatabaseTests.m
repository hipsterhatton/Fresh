//
//  FreshDatabaseTests.m
//  Fresh
//
//  Created by Stephen Hatton on 14/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FRSHDatabase.h"
#import "FRSHFileAndDirService.h"

@interface HistoryService : XCTestCase
@property (nonatomic, retain) FRSHDatabase *history;
@property (nonatomic, retain) FRSHFileAndDirService *dir;
@end

@implementation HistoryService

- (void)setUp
{
    [super setUp];
    _dir = [[FRSHFileAndDirService alloc] init];
    _history = [[FRSHDatabase alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWriteToDatabase
{
    NSDictionary *_d = [[NSDictionary alloc] initWithDictionary:@{
                                                                   @"wallpaper_id" :  @"123",
                                                                   @"wallpaper_url" : @"www.google.co.uk",
                                                                   @"screen_id" :     @"123",
                                                                   @"downloaded_at" : [NSDate date]
                                                                   } copyItems:NO];
    
    BOOL _res = [_history writeToDatabase:_d];
    XCTAssertTrue(_res);
}

- (void)testReadFromDatabase
{
    [_history purgeDatabase];
    
    NSDictionary *_d = [[NSDictionary alloc] initWithDictionary:@{
                                                                  @"wallpaper_id" :  @"123",
                                                                  @"wallpaper_url" : @"www.google.co.uk",
                                                                  @"screen_id" :     @"123",
                                                                  @"downloaded_at" : [NSDate date]
                                                                  } copyItems:NO];
    
    BOOL _res = [_history writeToDatabase:_d];
    XCTAssertTrue(_res);
    _res = [_history writeToDatabase:_d];
    XCTAssertTrue(_res);
    _res = [_history writeToDatabase:_d];
    XCTAssertTrue(_res);
    
    NSArray *_db_res = [_history readFromDatabase];
    XCTAssertNotNil(_db_res);
    XCTAssertEqual([_db_res count], 3);
}

- (void)testReadFromDatabaseWhenBlank
{
    [_history purgeDatabase];
    
    NSArray *_db_res = [_history readFromDatabase];
    XCTAssertNotNil(_db_res);
    XCTAssertEqual([_db_res count], 0);
}

@end
