//
//  FreshScreenTests.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FRSHScreen.h"

@interface FreshScreenTests : XCTestCase
@property (nonatomic, retain) FRSHScreen *screen;
@end

@implementation FreshScreenTests

- (void)setUp
{
    [super setUp];
    _screen = [[FRSHScreen alloc] initWithScreen:[NSScreen mainScreen]];
}

- (void)tearDown
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [super tearDown];
}

- (void)testInitWithScreen
{
    XCTAssertNotNil(_screen);
}

- (void)testInitWithSchedule
{
    XCTAssertNotNil([_screen schedule]);
}

- (void)testInitWithDefaultCollection
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    _screen = nil;
    _screen = [[FRSHScreen alloc] initWithScreen:[NSScreen mainScreen]];
    XCTAssertNotNil([_screen getScreenCollections]);
    XCTAssertEqualObjects([_screen getScreenCollections][0], @"220388");
}

- (void)testGetScreenID
{
    XCTAssertNotNil([_screen getScreenID]);
    XCTAssertNotNil([_screen getScreenID][@"id"]);
    XCTAssertNotNil([_screen getScreenID][@"uuid"]);
}

- (void)testIsScreenFullscreen
{
    XCTAssertTrue([_screen isFullscreen]);
}

- (void)testIsMainScreenYes
{
    _screen = [[FRSHScreen alloc] initWithScreen:[NSScreen mainScreen]];
    XCTAssertTrue([_screen isScreenMainScreen]);
}

- (void)testGetScreenDimensions
{
    XCTAssertNotNil([_screen getScreenDimensions]);
    XCTAssertNotNil([_screen getScreenDimensions][@"width"]);
    XCTAssertNotNil([_screen getScreenDimensions][@"height"]);
}

- (void)testGetSetScreenCollections
{
    NSArray *_a;
    _a = @[@"ABC", @"DEF", @"XYZ"];
    [_screen setScreenCollection:_a];
    XCTAssertNotNil([_screen getScreenCollections]);
    XCTAssertEqualObjects([_screen getScreenCollections], _a);
    
    _a = @[@"111", @"222", @"333"];
    [_screen setScreenCollection:_a];
    XCTAssertNotNil([_screen getScreenCollections]);
    XCTAssertEqualObjects([_screen getScreenCollections], _a);
}

@end
