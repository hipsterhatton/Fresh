//
//  FRSHScreen.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHScreen.h"

@implementation FRSHScreen

typedef uint64_t CGSManagedDisplay;
typedef int CGSConnection;

extern CGSManagedDisplay kCGSPackagesMainDisplayIdentifier;
extern int CGSManagedDisplayGetCurrentSpace(const CGSConnection cid, CGSManagedDisplay display);
extern CGSConnection _CGSDefaultConnection(void);

- (id)initWithScreen:(NSScreen *)screen
{
    if (self = [super init]) {
        _screen = screen;
        _schedule = [[FRSHSchedule alloc] initWithScreenID:[self getScreenID][@"id"]];
    }
    return self;
}

////
// Get Screen ID and UUID
//
- (NSDictionary *)getScreenID
{
    NSString *_id =     [_screen deviceDescription][@"NSScreenNumber"];
    
    id uuid =           CFBridgingRelease(CGDisplayCreateUUIDFromDisplayID([_screen.deviceDescription[@"NSScreenNumber"] unsignedIntValue]));
    NSString *_uuid =   CFBridgingRelease(CFUUIDCreateString(NULL, (__bridge CFUUIDRef) uuid));;
    
    return @{
             @"id" :    [NSString stringWithFormat:@"%d", [_id intValue]],
             @"uuid" :  _uuid
             };
}

////
// Get the screen dimensiosn for the properrty: _screen
//
- (NSDictionary *)getScreenDimensions
{
    NSSize size = [SDMacVersion deviceScreenResolutionPixelSize:_screen];
    
    int _height =   (int)size.height;
    int _width =    (int)size.width;
    
    return @{
             @"height" : [NSNumber numberWithInt:_height],
             @"width" :  [NSNumber numberWithInt:_width]
             };
}

////
// Check whether `_screen` is the main screen
//
- (BOOL)isScreenMainScreen
{
    NSString *_id =             [self getScreenID][@"id"];
    NSString *_mainScreenId =   [NSString stringWithFormat:@"%d", [[[NSScreen mainScreen] deviceDescription][@"NSScreenNumber"] intValue]];
    
    return ([_id isEqualToString:_mainScreenId]);
}

////
// Check whether screen is currently in fullscreen mode or not
//
- (BOOL)isFullscreen
{
    int _temp = CGSManagedDisplayGetCurrentSpace(_CGSDefaultConnection(), kCGSPackagesMainDisplayIdentifier);
    
    if (_temp == 1) {
        return false;
    } else {
        return true;
    }
}

@end

