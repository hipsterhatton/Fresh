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

@end
