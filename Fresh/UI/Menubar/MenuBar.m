//
//  MenuBar.m
//  Wallpaper
//
//  Created by Stephen Hatton on 10/05/2016.
//  Copyright © 2016 Stephen Hatton. All rights reserved.
//

#import "MenuBar.h"

#define SYSTEM_BAR_ICON_IMAGE           @"MenuBarImage.png"
#define SYSTEM_BAR_ICON_TOOLTIP         @"SomeExampleTooltip"

@implementation MenuBar

#pragma mark - Lifecycle Methods

- (instancetype)init
{
    if (self = [super init]) {
        [self initSystemBarIcon];
        [self initSystemBarMenu];
        [self setupIconClickListeners];
    }
    return self;
}


////
// Create system bar icon
//
- (void)initSystemBarIcon
{
    _theSystemBarIcon = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [_theSystemBarIcon setImage:[NSImage imageNamed:SYSTEM_BAR_ICON_IMAGE]];
    [_theSystemBarIcon setToolTip:SYSTEM_BAR_ICON_TOOLTIP];
    
    _popup = [[PopupViewController alloc] initWithNibName:@"PopupView" bundle:nil];
}


////
// Create system bar menu (shown on right click)
//
- (void)initSystemBarMenu
{
    _theSystemBarMenu = [[NSMenu alloc] initWithTitle:@"testing"];
    
    [_theSystemBarMenu addItemWithTitle:@"SomethingGoesHere" action:nil keyEquivalent:@""];
    
    [_theSystemBarMenu addItem:[NSMenuItem separatorItem]];
    
    [_theSystemBarMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
}


////
// Set up the click listeners (left, right)
//
- (void)setupIconClickListeners
{
    ClickDetectorView *clickDetector = [[ClickDetectorView alloc] initWithFrame:_theSystemBarIcon.button.frame];
    
    [[_theSystemBarIcon button] addSubview:clickDetector];
    
    clickDetector.onLeftMouseClicked = ^(NSEvent *event) {
        [self onLeftClick:[_theSystemBarIcon button]];
    };
    
    clickDetector.onRightMouseClicked = ^(NSEvent *event) {
        [self onRightClick:[_theSystemBarIcon button]];
    };
}


#pragma mark - Private - On Click Methods

////
// Action: on left click
//
- (void)onLeftClick:(id)sender
{
    NSLog(@"Left Click...");
    [_popup toggleWindow:sender];
}


////
// Action: on right click
//
- (void)onRightClick:(id)sender
{
    NSLog(@"Right Click...");
    [_theSystemBarIcon popUpStatusItemMenu:_theSystemBarMenu];
}

@end
