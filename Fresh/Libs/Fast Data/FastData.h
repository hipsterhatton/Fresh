//
//  FastData.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "GVUserDefaults+FastData.h"
#import "NSDictionary+DeepMutableCopy.h"

@interface FastData : NSObject
+ (id)sharedInstance;
- (void)writeData:(NSObject *)dataToWrite key:(NSString *)key, ...;
- (NSObject *)readData:(NSString *)key, ...;
- (void)purgeData:(NSString *)key, ...;
- (NSDictionary *)getData;
@end
