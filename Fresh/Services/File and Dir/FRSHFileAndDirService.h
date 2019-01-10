//
//  FRSHFileAndDirService.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <RXPromise/RXPromise.h>

#import "FRSHScreen.h"
#import "Shuttle.h"

@interface FRSHFileAndDirService : NSObject

@property (nonatomic, retain) Shuttle *shuttle;

- (RXPromise *)downloadImageFromURL:(NSString *)imageURL filename:(NSString *)filename forScreen:(FRSHScreen *)screen;

@end
