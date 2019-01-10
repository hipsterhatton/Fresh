//
//  FastDataServiceTests.m
//  Fresh
//
//  Created by Stephen Hatton on 02/08/2018.
//  Copyright © 2018 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import "FastData.h"
#import "GVUserDefaults.h"
#import "GVUserDefaults+FastData.h"

@interface FastDataServiceTests : XCTestCase
@property (nonatomic, retain) FastData *data;
@end

@implementation FastDataServiceTests

- (void)setUp
{
    [super setUp];
    _data = [FastData sharedInstance];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitSingleton
{
    XCTAssertNotNil(_data);
    FastData *_data2 = [FastData sharedInstance];
    XCTAssertNotNil(_data2);
    XCTAssertEqual(_data, _data2);
}

- (void)testWriteDataOneKey
{
    NSLog(@"%@", [_data getData]);
    [_data writeData:@"ABC" key:@"a", nil];
    XCTAssertNotNil([_data getData]);
    XCTAssertEqualObjects([_data getData][@"a"], @"ABC");
}

- (void)testWriteDataManyKeys
{
    [_data writeData:@"ABC" key:@"a", @"b", @"c", nil];
    XCTAssertNotNil([_data getData]);
    XCTAssertEqualObjects([_data getData][@"a"][@"b"][@"c"], @"ABC");
}

- (void)testLotsOfData
{
    [_data writeData:@"ABC" key:@"a", nil];
    XCTAssertEqualObjects([_data getData][@"a"], @"ABC");
    
    [_data writeData:@"ABC" key:@"a", @"a1", nil];
    XCTAssertEqualObjects([_data getData][@"a"][@"a1"], @"ABC");
    
    [_data writeData:@"ABC" key:@"a", @"a1", @"a2", nil];
    XCTAssertEqualObjects([_data getData][@"a"][@"a1"][@"a2"], @"ABC");
    
    [_data writeData:@"ABC" key:@"a", @"b", nil];
    XCTAssertEqualObjects([_data getData][@"a"][@"b"], @"ABC");
    
    [_data writeData:@"ABC" key:@"a", @"c", nil];
    XCTAssertEqualObjects([_data getData][@"a"][@"c"], @"ABC");
    
    [_data writeData:@"ABC" key:@"a", @"d", nil];
    XCTAssertEqualObjects([_data getData][@"a"][@"d"], @"ABC");
    
    [_data writeData:@"ABC" key:@"a", @"d", @"d1", nil];
    XCTAssertEqualObjects([_data getData][@"a"][@"d"][@"d1"], @"ABC");
    
    XCTAssertEqualObjects([_data getData][@"a"][@"a1"][@"a2"], @"ABC");
    XCTAssertEqualObjects([_data getData][@"a"][@"b"], @"ABC");
    XCTAssertEqualObjects([_data getData][@"a"][@"c"], @"ABC");
    XCTAssertEqualObjects([_data getData][@"a"][@"d"][@"d1"], @"ABC");
}

- (void)testPurgeDataBottomLevel
{
    [_data writeData:@"ABC" key:@"a", @"a1", @"a2", nil];
    XCTAssertNotNil([_data getData]);
    
    [_data purgeData:@"a", @"a1", @"a2", nil];
    NSLog(@"%@", [_data getData]);
}

- (void)testPurgeDataMidLevel
{
    [_data writeData:@"ABC" key:@"a", @"a1", nil];
    XCTAssertNotNil([_data getData]);
    
    [_data purgeData:@"a", @"a1", nil];
    NSLog(@"%@", [_data getData]);
}

- (void)testPurgeDataTopLevel
{
    [_data writeData:@"ABC" key:@"a", nil];
    XCTAssertNotNil([_data getData]);
    
    [_data purgeData:@"a", nil];
    NSLog(@"%@", [_data getData]);
}

- (void)testReadBottomLevel
{
    [_data writeData:@"ABC" key:@"a", @"a1", @"a2", nil];
    XCTAssertNotNil([_data getData]);
    
    NSDictionary *_d = (NSDictionary *)[_data readData:@"a", @"a1", @"a2", nil];
    XCTAssertEqualObjects(_d, @"ABC");
}

- (void)testReadDataMidLevel
{
    [_data writeData:@"ABC" key:@"a", @"a1", nil];
    XCTAssertNotNil([_data getData]);
    
    NSDictionary *_d = (NSDictionary *)[_data readData:@"a", @"a1", nil];
    XCTAssertEqualObjects(_d, @"ABC");
}

- (void)testReadDataTopLevel
{
    [_data writeData:@"ABC" key:@"a", nil];
    XCTAssertNotNil([_data getData]);
    
    NSDictionary *_d = (NSDictionary *)[_data readData:@"a", nil];
    XCTAssertEqualObjects(_d, @"ABC");
}

- (void)testReadEncounterError
{
    [_data writeData:@"ABC" key:@"a", @"a1", @"a2", nil];
    XCTAssertNotNil([_data getData]);
    
    NSDictionary *_d = (NSDictionary *)[_data readData:@"a", @"sdfjhgdsfh", @"a2", nil];
    XCTAssertNil(_d);
}

@end
