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

- (void)testSservicesAreSetup
{
    XCTAssertNotNil(_app);
    XCTAssertNotNil(_app.fileAndDirService);
    XCTAssertNotNil(_app.wallpaperAPI);
}

@end
