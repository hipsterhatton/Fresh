//
//  FRSHSchedule.h
//  Fresh
//
//  Created by Stephen Hatton on 24/11/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import <DateTools/DateTools.h>
#import <Foundation/Foundation.h>

#import "FastData.h"

@interface FRSHSchedule : NSObject

@property (nonatomic, retain) FastData *storedData;
@property (nonatomic, retain) NSString *screenID;
@property (nonatomic, retain) NSMutableDictionary *downloadSchedule;

- (id)initWithScreenID:(NSString *)screenID;
- (void)getScheduleSetup;
- (void)updatePersistedSchedule;
- (void)calculateNextDownloadDateTime;
- (void)calculateNextDownloadDateTime:(NSDate *)overrideDate;
- (BOOL)isScheduleActive;
- (BOOL)timeToDownload;
- (void)printTimeToDownload;

- (void)setScheduleDailyAtHour:(int)hour andMinute:(int)minute;
- (void)setScheduleWeeklyAtHour:(int)hour andMinute:(int)minute dayOfWeek:(NSString *)dayOfWeek;
- (void)setScheduleFortnightlyAtHour:(int)hour andMinute:(int)minute dayOfWeek:(NSString *)dayOfWeek;
- (void)setScheduleFDOMAtHour:(int)hour andMinute:(int)minute;
- (void)setScheduleLDOMAtHour:(int)hour andMinute:(int)minute;
- (void)setScheduleCDOMAtHour:(int)hour andMinute:(int)minute dayOfMonth:(int)dayOfMonth;
- (void)setScheduleEveryXMinutes:(int)minutes startingFrom:(NSDate *)startingFromDate;
- (void)setScheduleEveryXHours:(int)minutes startingFrom:(NSDate *)startingFromDate;
- (void)setScheduleEveryXDays:(int)minutes startingFrom:(NSDate *)startingFromDate;

@end
