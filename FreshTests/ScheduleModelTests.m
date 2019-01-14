//
//  ScheduleModelTests.m
//  Fresh
//
//  Created by Stephen Hatton on 08/08/2018.
//  Copyright © 2018 Stephen Hatton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FRSHSchedule.h"
#import "GVUserDefaults+FastData.h"

@interface ScheduleModelTests : XCTestCase
@property (nonatomic, retain) FRSHSchedule *schedule;
@end

@implementation ScheduleModelTests

- (void)setUp
{
    [super setUp];
    _schedule = [[FRSHSchedule alloc] initWithScreenID:@"123"];
}

- (void)tearDown
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [super tearDown];
}

- (void)testUpdateScheduleDaily
{
    [_schedule setScheduleDailyAtHour:8 andMinute:30];
    
    NSDate *nextDate = [[NSDate date] dateByAddingDays:1];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:nextDate.day hour:8 minute:30 second:0];
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testUpdateScheduleWeekly
{
    [_schedule setScheduleWeeklyAtHour:9 andMinute:30 dayOfWeek:@"Thursday"];
    
    NSDate *nextDate = [NSDate date];
    
    // 0 Sunday, 1 Monday, 2 Tuesday, 3 Wednesday, 4 Thursday, 5 Friday, 6 Saturday
    int thursday = 5;
    
    while ([nextDate weekday] != thursday) {
        nextDate = [nextDate dateByAddingDays:1];
    }
    
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:nextDate.day hour:9 minute:30 second:0];
    
    if ([nextDate isLessThan:[NSDate date]]) {
        nextDate = [nextDate dateByAddingWeeks:1];
    }
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testUpdateScheduleFortnightly
{
    [_schedule setScheduleWeeklyAtHour:9 andMinute:30 dayOfWeek:@"Thursday"];
    
    NSDate *nextDate = [NSDate date];
    
    // 0 Sunday, 1 Monday, 2 Tuesday, 3 Wednesday, 4 Thursday, 5 Friday, 6 Saturday
    int thursday = 5;
    
    while ([nextDate weekday] != thursday) {
        nextDate = [nextDate dateByAddingDays:1];
    }
    
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:nextDate.day hour:9 minute:30 second:0];
    
    if ([nextDate isLessThan:[NSDate date]]) {
        nextDate = [nextDate dateByAddingWeeks:2];
    }
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testUpdateScheduleFDOM
{
    [_schedule setScheduleFDOMAtHour:9 andMinute:30];
    
    NSDate *nextDate = [[NSDate date] dateByAddingMonths:1];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:1 hour:9 minute:30 second:0];
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testUpdateScheduleLDOM
{
    [_schedule setScheduleLDOMAtHour:9 andMinute:30];
    
    NSDate *nextDate = [[NSDate date] dateByAddingMonths:2];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:0 hour:9 minute:30 second:0];
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testUpdateScheduleCDOM
{
    [_schedule setScheduleCDOMAtHour:11 andMinute:30 dayOfMonth:21];
    
    NSDate *nextDate = [NSDate date];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:21 hour:11 minute:30 second:0];
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testUpdateScheduleEveryXMinutesNoStartingFrom
{
    [_schedule setScheduleEveryXMinutes:10 startingFrom:nil];
    
    NSDate *nextDate = [NSDate date];
    nextDate = [nextDate dateByAddingMinutes:10];
    
    XCTAssertEqualWithAccuracy([nextDate timeIntervalSinceReferenceDate], [_schedule.downloadSchedule[@"next_download_datetime"] timeIntervalSinceReferenceDate], 1, @"");
}

- (void)testUpdateScheduleEveryXHoursNoStartingFrom
{
    [_schedule setScheduleEveryXHours:1 startingFrom:nil];
    
    NSDate *nextDate = [NSDate date];
    nextDate = [nextDate dateByAddingHours:1];
    XCTAssertEqualWithAccuracy([nextDate timeIntervalSinceReferenceDate], [_schedule.downloadSchedule[@"next_download_datetime"] timeIntervalSinceReferenceDate], 1, @"");
}

- (void)testUpdateScheduleEveryXDaysNoStartingFrom
{
    [_schedule setScheduleEveryXDays:10 startingFrom:nil];
    
    NSDate *nextDate = [NSDate date];
    nextDate = [nextDate dateByAddingDays:10];
    XCTAssertEqualWithAccuracy([nextDate timeIntervalSinceReferenceDate], [_schedule.downloadSchedule[@"next_download_datetime"] timeIntervalSinceReferenceDate], 1, @"");
}

- (void)testInitWithScreenID
{
    XCTAssertNotNil(_schedule);
    XCTAssertNotNil([_schedule screenID]);
}

- (void)testReadDefaultScheduleFromDataPersistence
{
    XCTAssertNotNil([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"]);
}

- (void)testUpdateScheduleWithoutSaving
{
    [_schedule downloadSchedule][@"active"] = @(NO);
    [_schedule downloadSchedule][@"day_of_week_to_download_on"] =   @"Wednesday";
    [_schedule downloadSchedule][@"custom_dom_to_download_on"] =    @(5);
    [_schedule downloadSchedule][@"download_every_x"][@"every_amount"] = @"hours";
    
    XCTAssertEqualObjects(_schedule.downloadSchedule[@"active"], @(NO));
    XCTAssertEqualObjects(_schedule.downloadSchedule[@"day_of_week_to_download_on"], @"Wednesday");
    XCTAssertEqualObjects(_schedule.downloadSchedule[@"custom_dom_to_download_on"], @(5));
    XCTAssertEqualObjects(_schedule.downloadSchedule[@"download_every_x"][@"every_amount"], @"hours");
}

- (void)testUpdateScheduleNoOverridingExisting
{
    FRSHSchedule *_anotherSchedule = [[FRSHSchedule alloc] initWithScreenID:@"456"];
    
    [_anotherSchedule downloadSchedule][@"active"] = @(YES);
    [_anotherSchedule downloadSchedule][@"day_of_week_to_download_on"] =   @"Monday";
    [_anotherSchedule downloadSchedule][@"custom_dom_to_download_on"] =    @(1);
    [_anotherSchedule downloadSchedule][@"download_every_x"][@"every_amount"] = @"days";
    [_anotherSchedule updatePersistedSchedule];
    
    [_schedule downloadSchedule][@"active"] = @(NO);
    [_schedule downloadSchedule][@"day_of_week_to_download_on"] =   @"Wednesday";
    [_schedule downloadSchedule][@"custom_dom_to_download_on"] =    @(5);
    [_schedule downloadSchedule][@"download_every_x"][@"every_amount"] = @"hours";
    [_schedule updatePersistedSchedule];
    
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"active"], @(NO));
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"day_of_week_to_download_on"], @"Wednesday");
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"custom_dom_to_download_on"], @(5));
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"download_every_x"][@"every_amount"], @"hours");
    
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"456"][@"schedule"][@"active"], @(YES));
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"456"][@"schedule"][@"day_of_week_to_download_on"], @"Monday");
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"456"][@"schedule"][@"custom_dom_to_download_on"], @(1));
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"456"][@"schedule"][@"download_every_x"][@"every_amount"], @"days");
}

- (void)testReadUpdatedScheduleFromDataPersistence
{
    [_schedule downloadSchedule][@"active"] = @(NO);
    [_schedule downloadSchedule][@"day_of_week_to_download_on"] =   @"Wednesday";
    [_schedule downloadSchedule][@"custom_dom_to_download_on"] =    @(5);
    [_schedule downloadSchedule][@"download_every_x"][@"every_amount"] = @"hours";
    
    [_schedule updatePersistedSchedule];
    
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"active"], @(NO));
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"day_of_week_to_download_on"], @"Wednesday");
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"custom_dom_to_download_on"], @(5));
    XCTAssertEqualObjects([[_schedule storedData] getData][@"screens"][@"123"][@"schedule"][@"download_every_x"][@"every_amount"], @"hours");
}

- (void)testReadOldScheduleFromDataPersistenceRecalculateDates
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // Destroy _schedule
    _schedule = nil;
    
    // Init _schedule (should read from data persistence as we've just created one)
    _schedule = [[FRSHSchedule alloc] initWithScreenID:@"123"];
    
    // Check dates are recalculated
    NSDate *nextDate = [[NSDate date] dateByAddingDays:1];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:nextDate.day hour:9 minute:30 second:0];
    XCTAssertEqualObjects(_schedule.downloadSchedule[@"how_often_to_download"], @"Daily");
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testIsScheduleActive
{
    XCTAssertTrue([_schedule isScheduleActive]);
}

- (void)testDailyDate
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"Daily";
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [[NSDate date] dateByAddingDays:1];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:nextDate.day hour:9 minute:30 second:0];
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testWeeklyDate
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"Weekly";
    _schedule.downloadSchedule[@"day_of_week_to_download_on"] = @"Thursday";
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [NSDate date];
    
    // 0 Sunday, 1 Monday, 2 Tuesday, 3 Wednesday, 4 Thursday, 5 Friday, 6 Saturday
    int thursday = 5;
    
    while ([nextDate weekday] != thursday) {
        nextDate = [nextDate dateByAddingDays:1];
    }
    
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:nextDate.day hour:9 minute:30 second:0];
    
    if ([nextDate isLessThan:[NSDate date]]) {
        nextDate = [nextDate dateByAddingWeeks:1];
    }
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testFirstDayOfMonth
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"FirstDayOfMonth";
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [[NSDate date] dateByAddingMonths:1];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:1 hour:9 minute:30 second:0];
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testLastDayOfMonth
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"LastDayOfMonth";
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [[NSDate date] dateByAddingMonths:2];
    nextDate = [NSDate dateWithYear:nextDate.year month:nextDate.month day:0 hour:9 minute:30 second:0];
    
    XCTAssertEqualObjects(nextDate, _schedule.downloadSchedule[@"next_download_datetime"]);
}

- (void)testEveryXMinutes
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"EveryX";
    _schedule.downloadSchedule[@"download_every_x"][@"every_amount"] =  @"minutes";
    _schedule.downloadSchedule[@"download_every_x"][@"every_x"] =       @(20);
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [[NSDate date] dateByAddingMinutes:20];
    
    NSString *one = [NSString stringWithFormat:@"%@", nextDate];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

- (void)testEveryXHours
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"EveryX";
    _schedule.downloadSchedule[@"download_every_x"][@"every_amount"] =  @"hours";
    _schedule.downloadSchedule[@"download_every_x"][@"every_x"] =       @(3);
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [[NSDate date] dateByAddingHours:3];
    
    NSString *one = [NSString stringWithFormat:@"%@", nextDate];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

- (void)testEveryXDays
{
    _schedule.downloadSchedule[@"how_often_to_download"] = @"EveryX";
    _schedule.downloadSchedule[@"download_every_x"][@"every_amount"] =  @"days";
    _schedule.downloadSchedule[@"download_every_x"][@"every_x"] =       @(3);
    [_schedule calculateNextDownloadDateTime];
    
    NSDate *nextDate = [[NSDate date] dateByAddingDays:3];
    
    NSString *one = [NSString stringWithFormat:@"%@", nextDate];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

- (void)testCustomDaysOfMonthDateNotPassed
{
    _schedule.downloadSchedule[@"how_often_to_download"] =      @"CustomDayOfMonth";
    _schedule.downloadSchedule[@"custom_dom_to_download_on"] =  @(15);
    
    NSDate *overrideDate = [NSDate dateWithYear:2017 month:1 day:1 hour:9 minute:30 second:0];
    [_schedule calculateNextDownloadDateTime:overrideDate];
    
    NSString *one = [NSString stringWithFormat:@"%@", [NSDate dateWithYear:2017 month:1 day:15 hour:9 minute:30 second:0]];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

- (void)testCustomDaysOfMonthDateAlreadyPassed
{
    _schedule.downloadSchedule[@"how_often_to_download"] =      @"CustomDayOfMonth";
    _schedule.downloadSchedule[@"custom_dom_to_download_on"] =  @(15);
    
    NSDate *overrideDate = [NSDate dateWithYear:2017 month:1 day:20 hour:9 minute:30 second:0];
    [_schedule calculateNextDownloadDateTime:overrideDate];
    
    NSString *one = [NSString stringWithFormat:@"%@", [NSDate dateWithYear:2017 month:2 day:15 hour:9 minute:30 second:0]];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

- (void)testCustomDaysOfMonthDateAlreadyPassedDecemberAndNewYear
{
    _schedule.downloadSchedule[@"how_often_to_download"] =      @"CustomDayOfMonth";
    _schedule.downloadSchedule[@"custom_dom_to_download_on"] =  @(15);
    
    NSDate *overrideDate = [NSDate dateWithYear:2017 month:12 day:20 hour:9 minute:30 second:0];
    [_schedule calculateNextDownloadDateTime:overrideDate];
    
    NSString *one = [NSString stringWithFormat:@"%@", [NSDate dateWithYear:2018 month:1 day:15 hour:9 minute:30 second:0]];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

- (void)testCustomDaysOfMonthDateAlreadyPassedJanToFeb
{
    _schedule.downloadSchedule[@"how_often_to_download"] =      @"CustomDayOfMonth";
    _schedule.downloadSchedule[@"custom_dom_to_download_on"] =  @(30);
    
    NSDate *overrideDate = [NSDate dateWithYear:2017 month:1 day:31 hour:9 minute:30 second:0];
    [_schedule calculateNextDownloadDateTime:overrideDate];
    
    NSString *one = [NSString stringWithFormat:@"%@", [NSDate dateWithYear:2017 month:2 day:28 hour:9 minute:30 second:0]];
    NSString *two = [NSString stringWithFormat:@"%@", _schedule.downloadSchedule[@"next_download_datetime"]];
    
    XCTAssertTrue([one isEqualToString:two]);
}

@end
