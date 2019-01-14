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

@end
