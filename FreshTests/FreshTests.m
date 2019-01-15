//
//  FreshTests.m
//  FreshTests
//
//  Created by Stephen Hatton on 02/08/2018.
//  Copyright © 2018 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Shuttle.h"

@interface FreshTests : XCTestCase
@property (nonatomic, retain) Shuttle *shuttle;
@end

@implementation FreshTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
/*
- (void)testShuttleExpoBackoff
{
    _shuttle = [[Shuttle alloc] initWithDefaults:@{
                                                   @"Accept-Version" : @"v1"
                                                   }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    RXPromise *_rxp = [_shuttle launch:GET :JSON :@"https://www.google.co.uk" :nil];
    
    _rxp.then(^id (NSDictionary *rawJSON) {
        return @"OK";
    }, nil)
    
    .then(^id (NSDictionary *response) {
        [expectation fulfill];
        return @"OK";
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        XCTAssertNotNil(error);
    });
    
    [self waitForExpectationsWithTimeout:180 handler:nil];
}
*/
@end
