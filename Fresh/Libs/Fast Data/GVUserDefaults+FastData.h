//
//  GVUserDefaults+FastData.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (FastData)
@property (nonatomic, weak) NSDictionary *data;
@end
