//
//  FreshUnsplashApiTests.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FRSHUnsplashAPI.h"

@interface FreshUnsplashApiTests : XCTestCase
@property (nonatomic, retain) FRSHUnsplashAPI *api;
@end

@implementation FreshUnsplashApiTests

- (void)setUp
{
    [super setUp];
    _api = [FRSHUnsplashAPI new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetRandomWallpaperURL
{
    [_api.shuttle.mockRequests disableMockShuttleRequests];
    
    FRSHScreen *_sc = [[FRSHScreen alloc] initWithScreen:[NSScreen mainScreen]];
    XCTAssertNotNil([_api getWallpaperURLForScreen:_sc]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_api getWallpaperURLForScreen:_sc]
    
    .then(^id (NSDictionary *_data) {
        XCTAssertFalse([_data[@"url"] rangeOfString:@"https://images.unsplash.com/photo-"].location == NSNotFound);
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertThrows(error);
        return error;
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testSearchCollections
{
    [_api.shuttle.mockRequests disableMockShuttleRequests];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_api searchCollections:@"coffee" pageNumber:1]
    
    .then(^id (NSDictionary *_data) {
        XCTAssertNotNil(_data[@"collections"]);
        XCTAssertGreaterThan([_data[@"collections"] count], 1);
        XCTAssertNotNil(_data[@"number_of_results"]);
        XCTAssertGreaterThan([_data[@"number_of_results"] intValue], 1);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *_data) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
        return error;
    });
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testSearchCollectionsWithBadSearchTerm
{
    [_api.shuttle.mockRequests disableMockShuttleRequests];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_api searchCollections:@"sdjhfshjlfd" pageNumber:1]
    
    .then(^id (NSDictionary *_data) {
        XCTAssertNotNil(_data[@"collections"]);
        XCTAssertEqual([_data[@"collections"] count], 0);
        XCTAssertNotNil(_data[@"number_of_results"]);
        int _x = [_data[@"number_of_results"] intValue];
        XCTAssertEqual(_x, 0);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *_data) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
        return error;
    });
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testGetRelevantCollections
{
    [_api.shuttle.mockRequests disableMockShuttleRequests];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_api getRelatedCollectionIDsForCollectionID:@"764827"]
    
    .then(^id (NSArray *_d) {
        XCTAssertNotNil(_d);
        XCTAssertGreaterThan([_d count], 1);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *_data) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        return error;
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testSearchPhotos
{
    [_api.shuttle.mockRequests disableMockShuttleRequests];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_api searchPhotos:@"coffee" pageNumber:1]
    
    .then(^id (NSArray *_data) {
        XCTAssertNotNil(_data);
        XCTAssertGreaterThan([_data count], 1);
        XCTAssertNotNil([_data firstObject][@"id"]);
        XCTAssertNotNil([_data firstObject][@"url"]);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *_data) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
        return error;
    });
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

- (void)testGetPhotoURL
{
    [_api.shuttle.mockRequests disableMockShuttleRequests];
    FRSHScreen *_sc = [[FRSHScreen alloc] initWithScreen:[NSScreen mainScreen]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_api searchPhotos:@"coffee" pageNumber:1]
    
    .then(^id (NSArray *_data) {
        __block NSString *_id =     _data[0][@"id"];
        __block NSString *_url =    _data[0][@"url"];
        [_api getWallpaperURLForScreen:_sc withImageID:_id withImageURL:_url];
        __block NSString *_apiURL = [_sc state][@"wallpaper_url"];
        XCTAssertNotNil(_apiURL);
        XCTAssertFalse([_apiURL rangeOfString:@"https://images.unsplash.com/photo-"].location == NSNotFound);
        XCTAssertFalse([_apiURL rangeOfString:@"&w="].location == NSNotFound);
        XCTAssertFalse([_apiURL rangeOfString:@"&h="].location == NSNotFound);
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *_data) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNil(error);
        return error;
    });
    
    [self waitForExpectationsWithTimeout:120 handler:nil];
}

@end
