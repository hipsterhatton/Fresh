//
//  FreshFileAndDirServiceTests.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FRSHFileAndDirService.h"

@interface FreshFileAndDirServiceTests : XCTestCase
@property (nonatomic, retain) FRSHFileAndDirService *service;
@end

@implementation FreshFileAndDirServiceTests

- (void)setUp
{
    [super setUp];
    _service = [FRSHFileAndDirService new];
}

- (void)tearDown
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:@"/Users/Stephen/Library/Application Support/Fresh" error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    [super tearDown];
}

- (void)testCreateNewDirectories
{
    BOOL isDir = YES;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh" isDirectory:&isDir]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Downloads" isDirectory:&isDir]);
    isDir = NO;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Fresh.sqlite" isDirectory:&isDir]);
}

- (void)testExistingDirectories
{
    _service = nil;
    _service = [FRSHFileAndDirService new];
    
    BOOL isDir = YES;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh" isDirectory:&isDir]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Downloads" isDirectory:&isDir]);
    isDir = NO;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Fresh.sqlite" isDirectory:&isDir]);
}

- (void)testDownloadImageFromURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Query timed out"];
    
    [_service downloadImageFromURL:@"https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg" filename:@"test"]
    
    .then(^id (id blank) {
        return blank;
    }, nil)
    
    .then(^id (NSDictionary *response) {
        XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:@"/Users/Stephen/Library/Application Support/Fresh/Downloads/test.jpg"]);
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
