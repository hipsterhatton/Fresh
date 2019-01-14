//
//  FRSHDatabase.h
//  Fresh
//
//  Created by Stephen Hatton on 14/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <FMDB/FMDB.h>
#import <Foundation/Foundation.h>

@interface FRSHDatabase : NSObject

@property (nonatomic, retain) FMDatabase *database;
@property (nonatomic) int numberOfImagesFetched;

- (BOOL)writeToDatabase:(NSDictionary *)dataToWrite;
- (NSArray *)readFromDatabase;
- (void)purgeDatabase;

@end
