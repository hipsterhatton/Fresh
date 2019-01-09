//
//  FRSHApp.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHApp.h"

@implementation FRSHApp

- (id)init
{
    if (self = [super init]) {
    }
    
    [self setupScreensWithNotifications:YES];
    return self;
}

- (void)setupScreensWithNotifications:(BOOL)setupNotification
{
    if (!_screens) {
        _screens = [NSMutableArray new];
    }
    
    [_screens removeAllObjects];
    
    for (int _a = 0; _a < [[NSScreen screens] count]; _a++) {
        FRSHScreen *_screen = [[FRSHScreen alloc] initWithScreen:[NSScreen screens][_a]];
        [_screens addObject:_screen];
    }
    
    if (!setupNotification) {
        return;
    }
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidChangeScreenParametersNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setScreenChangeNotification:)
                                                 name:NSApplicationDidChangeScreenParametersNotification
                                               object:nil];
}

- (void)setScreenChangeNotification:(NSNotification *)notification
{
    // Whenever a `screen has changed` notif. is fired
    // Clear the array, re-add all the screens...
    
    NSLog(@"Screen has changed...");
    [self setupScreensWithNotifications:NO];
}

@end
