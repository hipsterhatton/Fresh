//
//  FreshAppTests.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FRSHApp.h"

@interface FreshAppTests : XCTestCase
@property (nonatomic, retain) FRSHApp *app;
@end

@implementation FreshAppTests

- (void)setUp
{
    [super setUp];
    _app = [FRSHApp new];
    [_app.wallpaperAPI.shuttle.mockRequests disableMockShuttleRequests];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testScreensAreSetup
{
    XCTAssertNotNil(_app);
    XCTAssertNotNil(_app.screens);
    XCTAssertGreaterThanOrEqual(_app.screens.count, 1);
}

- (void)testFireScreenChangeObservation
{
    NSObject *_old = _app.screens[0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationDidChangeScreenParametersNotification object:self];
    
    NSObject *_new = _app.screens[0];
    
    XCTAssertNotEqualObjects(_old, _new);
}

- (void)testServicesAreSetup
{
    XCTAssertNotNil(_app);
    XCTAssertNotNil(_app.fileAndDirService);
    XCTAssertNotNil(_app.wallpaperAPI);
}

- (void)testOneDownloadWallpaper
{
    [_app.database purgeDatabase];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_app downloadWallpaperForScreen:_app.screens.firstObject]
    
    .then(^id (id blank) {
        NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Downloads/" error:nil];
        XCTAssertEqual(listOfFiles.count, 1);
        XCTAssertFalse([listOfFiles[0] rangeOfString:[_app.screens.firstObject getScreenID][@"uuid"]].location == NSNotFound);
        return @"OK";
    }, nil)
    
    .then(^id (id blank) {
        NSArray *_db_res = [_app.database readFromDatabase];
        XCTAssertNotNil(_db_res);
        XCTAssertEqual([_db_res count], 1);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *response) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testTwoDownloadWallpaper
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_app downloadWallpaperForScreen:_app.screens.firstObject]
    
    .then(^id (id blank) {
        NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Downloads/" error:nil];
        XCTAssertEqual(listOfFiles.count, 1);
        XCTAssertFalse([listOfFiles[0] rangeOfString:[_app.screens.firstObject getScreenID][@"uuid"]].location == NSNotFound);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *response) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testThreeDownloadWallpaper
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_app downloadWallpaperForScreen:_app.screens.firstObject]
    
    .then(^id (id blank) {
        NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Downloads/" error:nil];
        XCTAssertEqual(listOfFiles.count, 1);
        XCTAssertFalse([listOfFiles[0] rangeOfString:[_app.screens.firstObject getScreenID][@"uuid"]].location == NSNotFound);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *response) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testDownloadWallpaperUpdateState
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_app downloadWallpaperForScreen:_app.screens.firstObject]
    
    .then(^id (id blank) {
        NSDictionary *_d = [_app.screens[0] getScreenState];
        XCTAssertNotNil(_d[@"wallpaper_id"]);
        XCTAssertNotNil(_d[@"status"]);
        XCTAssertNotNil(_d[@"wallpaper_file_name"]);
        XCTAssertNotNil(_d[@"wallpaper_file_path"]);
        XCTAssertNotNil(_d[@"wallpaper_url"]);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *response) {
        NSLog(@"%@", [_app.screens[0] getScreenState]);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *response) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testTimerIsSetup
{
    XCTAssertNotNil([_app checkScheduleTimer]);
}

@end
