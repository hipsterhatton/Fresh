//
//  GVUserDefaults+FastData.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "GVUserDefaults+FastData.h"

@implementation GVUserDefaults (FastData)
@dynamic data;

- (NSDictionary *)setupDefaults
{
    return @{
             @"data" : [@{} mutableCopy]
             };
}
@end
