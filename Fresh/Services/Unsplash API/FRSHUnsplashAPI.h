//
//  FRSHUnsplashAPI.h
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RXPromise/RXPromise.h>

#import "FRSHScreen.h"
#import "Shuttle.h"

@interface FRSHUnsplashAPI : NSObject

@property (nonatomic, retain) Shuttle *shuttle;

- (NSString *)getRandomWallpaperFromCollections:(FRSHScreen *)screen;
@end
