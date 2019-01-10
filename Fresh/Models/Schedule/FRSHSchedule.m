//
//  FRSHSchedule.m
//  Fresh
//
//  Created by Stephen Hatton on 24/11/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import "FRSHSchedule.h"

#define TIME_TO_DOWNLOAD_RANGE  120

@implementation FRSHSchedule

- (id)initWithScreenID:(NSString *)screenID
{
    if (self = [super init]) {
        _screenID = screenID;
        _storedData = [FastData sharedInstance];
        [self getScheduleSetup];
    }
    return self;
}

////
// Get the download schedule for screen w/ ID: `_screenID`
//
- (void)getScheduleSetup
{
    _downloadSchedule = (NSMutableDictionary *)[_storedData readData:@"screens", _screenID, @"schedule", nil];
    NSLog(@">>>>>>> Checking if existing schedule exists");

    if (!_downloadSchedule) {
        NSLog(@">>>>>>> Existing schedule does not exist");
        _downloadSchedule = [self getDefaultDownloadSchedule];
    } else {
        _downloadSchedule = [_downloadSchedule mutableDeepCopy];
    }
    
    NSLog(@">>>>>>> Updating schedule");
    [self calculateNextDownloadDateTime];
}

////
// Default download schedule
//
- (NSMutableDictionary *)getDefaultDownloadSchedule
{
    return [@{
             @"active" : @(YES),
             @"next_download_datetime_has_been_set" : @(false),
             @"next_download_datetime" : @(false),
             
             @"how_often_to_download" : @"Daily",
             @"what_time_to_download" : @[@(9), @(30)],
             
             @"day_of_week_to_download_on" : @"Monday",
             
             @"custom_dom_to_download_on" : @(10),
             
             @"download_every_x" : [@{
                                      @"starting_from" :  @(false),
                                      @"every_x" :        @(3),
                                      @"every_amount" :   @"days"
                                      } mutableCopy]
             } mutableCopy];
}

////
// Updated `freshSettings` data persistence schedule
//
- (void)updatePersistedSchedule
{
    [_storedData writeData:_downloadSchedule key:@"screens", _screenID, @"schedule", nil];
}

////
// Check whether the schedule is active -or- not (per screen basis)
//
- (BOOL)isScheduleActive
{
    return [_downloadSchedule[@"active"] boolValue];
}

////
// Check whether it's time to download or not (d/l time is within TIME_TO_DOWNLOAD_RANGE of present)
//
- (BOOL)timeToDownload
{
    if ([_downloadSchedule[@"next_download_datetime_has_been_set"] boolValue] == false) {
        NSLog(@"===> Date/time download has NOT been set! So do that now!");
        [self calculateNextDownloadDateTime];
    } else {
        NSLog(@"===> Date/time has been set, we're all good to go");
    }
    
    int _distance = [[NSDate date] secondsFrom:_downloadSchedule[@"next_download_datetime"]];
    
    if (_distance > 0 && _distance < TIME_TO_DOWNLOAD_RANGE) {
        [self calculateNextDownloadDateTime];
        return true;
    }
    
    return false;
}

////
// Print out next schedule 'time to download'
//
- (void)printTimeToDownload
{
    NSLog(@"%@", _downloadSchedule[@"next_download_datetime"]);
}


#pragma mark - Private Methods
#pragma mark - Date Calculation Methods

////
// Calculat the next d/l date if we've already passed ours
//
- (void)calculateNextDownloadDateTime
{
//    // Testing code
//    if (false) {
//        [self nextDateWeekly];
//        [_downloadSchedule setObject:@(true) forKey:@"next_download_datetime_has_been_set"];
//        [self updatePersistedSchedule];
//        return;
//    }
    
    if ([_downloadSchedule[@"how_often_to_download"] isEqualToString:@"Daily"]) {
        
        [self nextDateDaily];
        
    } else if ([_downloadSchedule[@"how_often_to_download"] isEqualToString:@"Weekly"]) {
        
        [self nextDateWeekly];
        
    } else if ([_downloadSchedule[@"how_often_to_download"] isEqualToString:@"Fortnightly"]) {
        
        [self nextDateFortnightly];
        
    } else if ([_downloadSchedule[@"how_often_to_download"] isEqualToString:@"FirstDayOfMonth"]) {
        
        [self nextDateFirstDayOfMonthDate];
        
    } else if ([_downloadSchedule[@"how_often_to_download"] isEqualToString:@"LastDayOfMonth"]) {
        
        [self nextDateLastDayOfMonthDate];
        
    } else if ([_downloadSchedule[@"how_often_to_download"] isEqualToString:@"CustomDayOfMonth"]) {
        
        [self nextDateCustomDayOfMonth:[NSDate date]];
        
    } else {
        
        [self nextDateEveryXMinutesHoursDays];
        
    }
    
    [_downloadSchedule setObject:@(true) forKey:@"next_download_datetime_has_been_set"];
    [self updatePersistedSchedule];
}

- (void)calculateNextDownloadDateTime:(NSDate *)overrideDate
{
    [self nextDateCustomDayOfMonth:overrideDate];
    [self updatePersistedSchedule];
}

////
// Build next download date: daily (today/tomorrow)
//
- (void)nextDateDaily
{
    NSLog(@"===> Building next download date: Daily");
    
    NSDate *_date = [self buildDateTodayWithTime];
    
    while ([_date isEarlierThan:[NSDate date]]) {
        _date = [_date dateByAddingDays:1];
    }
    
    // If we've already got a date set...check if we're past it
    // Add 1 day then - repeat this until we're set
    [_downloadSchedule setValue:_date forKey:@"next_download_datetime"];
    return;
}

////
// Build next download date: weekly (today/next week)
//
- (void)nextDateWeekly
{
    NSLog(@"===> Building next download date: Weekly");
    
    NSDate *_date = [self buildDateTodayWithTime];
    
    // Set the weekday...
    
    int _dayOfWeek = [self getDayOfWeekToDownloadOn];
    
    while ([_date weekday] != _dayOfWeek) {
        _date = [_date dateByAddingDays:1];
    }
    
    // If we've already got a date set...check if we're past it
    // Add 1 week then - repeat this until we're set
    
    while ([_date isEarlierThan:[NSDate date]]) {
        _date = [_date dateByAddingWeeks:1];
    }
    
    [_downloadSchedule setValue:_date forKey:@"next_download_datetime"];
    return;
}

////
// Build next download date: weekly (today/next week)
//
- (void)nextDateFortnightly
{
    NSLog(@"===> Building next download date: Weekly");
    
    NSDate *_date = [self buildDateTodayWithTime];
    
    // Set the weekday...
    
    int _dayOfWeek = [self getDayOfWeekToDownloadOn];
    
    while ([_date weekday] != _dayOfWeek) {
        _date = [_date dateByAddingDays:1];
    }
    
    // If we've already got a date set...check if we're past it
    // Add 1 week then - repeat this until we're set
    
    while ([_date isEarlierThan:[NSDate date]]) {
        _date = [_date dateByAddingWeeks:1];
    }
    
    // Add another week, to make our fortnight
    
    _date = [_date dateByAddingWeeks:1];
    
    [_downloadSchedule[_screenID] setValue:_date forKey:@"next_download_datetime"];
    return;
}

////
// Build next download date: 1st of month
//
- (void)nextDateFirstDayOfMonthDate
{
    NSLog(@"===> Building next download date: 1st of month");
    
    NSDate *_date = [self buildDateTodayWithTime];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [cal components: NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: _date];
    
    [dateComponents setDay:1];
    
    _date = [cal dateFromComponents: dateComponents];
    
    if ([_date isEarlierThan:[NSDate date]]) {
        _date = [_date dateByAddingMonths:1];
    }
    
    [_downloadSchedule setValue:_date forKey:@"next_download_datetime"];
    return;
}

////
// Build next download date: last day of month
//
- (void)nextDateLastDayOfMonthDate
{
    NSLog(@"===> Building next download date: last of month");
    
    // Get the current month, last day...
    
    NSDate *_date = [self buildDateTodayWithTime];
    _date = [_date dateByAddingMonths:2];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [cal components: NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: _date];
    
    [dateComponents setDay:0];
    
    _date = [cal dateFromComponents: dateComponents];
    
    // not sure about this one...
    
    if ([_date isEarlierThan:[NSDate date]]) {
        _date = [_date dateByAddingMonths:1];
    }
    
    [_downloadSchedule setValue:_date forKey:@"next_download_datetime"];
    return;
}

////
// Build next download date: custom day in month
//
- (void)nextDateCustomDayOfMonth:(NSDate *)compareDate
{
    NSLog(@"===> Building next download date: custom day in month");
    
    int _customDayOfMonth = [_downloadSchedule[@"custom_dom_to_download_on"] intValue];
    
    NSDate *_thisMonth = compareDate;
    _thisMonth = [NSDate dateWithYear:_thisMonth.year month:(_thisMonth.month + 1) day:0 hour:1 minute:1 second:0];
    
    NSDate *_nextMonth = [compareDate dateByAddingMonths:1];
    _nextMonth = [NSDate dateWithYear:_nextMonth.year month:(_nextMonth.month + 2) day:0 hour:1 minute:1 second:0];
    
    // If our custom day of month is greater than the number of days in this month
    if (_customDayOfMonth > [_thisMonth day]) {
        _customDayOfMonth = (int)[_thisMonth day];
    }
    
    int _hour =     [_downloadSchedule[@"what_time_to_download"][0] intValue];
    int _minute =   [_downloadSchedule[@"what_time_to_download"][1] intValue];
    
    NSDate *_customDownloadDate = [NSDate dateWithYear:_thisMonth.year month:_thisMonth.month day:_customDayOfMonth hour:_hour minute:_minute second:0];
    
    // If our next download date is earlier than today..,than +1 month (check if we can do this!)
    if ([_customDownloadDate isEarlierThan:compareDate]) {
        
        // If our next download date won't work for next month, because this month has more days (e.g. 31) and next month only has less (e.g.: 30)
        // Then subtract enough time, and then +1 month
        if (_customDayOfMonth > [_nextMonth day]) {
            _customDownloadDate = [_customDownloadDate dateBySubtractingDays:(_customDayOfMonth - (int)[_nextMonth day])];
        }
        
        _customDownloadDate = [_customDownloadDate dateByAddingMonths:1];   
    }
    
    [_downloadSchedule setValue:_customDownloadDate forKey:@"next_download_datetime"];
    return;
}

////
// Build next download date: every X days
//
- (void)nextDateEveryXMinutesHoursDays
{
    NSLog(@"===> Building next download date: Every X Days");
    
    NSDate *_date;
    if ([_downloadSchedule[@"download_every_x"][@"starting_from"] boolValue] == false) {
        _date = [NSDate date];
    } else {
        _date = _downloadSchedule[@"download_every_x"][@"starting_from"];
    }
    
    while ([_date isEarlierThan:[NSDate date]]) {
        
        if ([_downloadSchedule[@"download_every_x"][@"every_amount"] isEqualToString:@"minutes"]) {
            _date = [_date dateByAddingMinutes:[_downloadSchedule[@"download_every_x"][@"every_x"] intValue]];
        } else if ([_downloadSchedule[@"download_every_x"][@"every_amount"] isEqualToString:@"hours"]) {
            _date = [_date dateByAddingHours:[_downloadSchedule[@"download_every_x"][@"every_x"] intValue]];
        } else if ([_downloadSchedule[@"download_every_x"][@"every_amount"] isEqualToString:@"days"]) {
            _date = [_date dateByAddingDays:[_downloadSchedule[@"download_every_x"][@"every_x"] intValue]];
        }
    }
    
    [_downloadSchedule setValue:_date forKey:@"next_download_datetime"];
    return;
}



#pragma mark - Utility Methods

////
// Build a NSDate with a set time (from the `downloadSchedule`
//
- (NSDate *)buildDateTodayWithTime
{
    NSDate *_tempDate = [NSDate date];
    
    int _hour =     [[_downloadSchedule[@"what_time_to_download"] firstObject] intValue];
    int _minute =   [[_downloadSchedule[@"what_time_to_download"] lastObject] intValue];
    
    _tempDate = [NSDate dateWithYear:[_tempDate year] month:[_tempDate month] day:[_tempDate day] hour:_hour minute:_minute second:0];
    
    return _tempDate;
}

////
// Convert string DoW to integer DoW
//
- (int)getDayOfWeekToDownloadOn
{
    NSArray *_DAYS_OF_WEEK = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    return (int)[_DAYS_OF_WEEK indexOfObject:_downloadSchedule[@"day_of_week_to_download_on"]] + 1;
}

@end
