//
//  MenuBar.m
//  Wallpaper
//
//  Created by Stephen Hatton on 10/05/2016.
//  Copyright © 2016 Stephen Hatton. All rights reserved.
//

#import "MenuBar.h"

#define SYSTEM_BAR_ICON_TOOLTIP         @"Fresh"
#define SYSTEM_BAR_ICON_IMAGE           @"MenuBarImage.png"

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
    _theSystemBarMenu = [[NSMenu alloc] init];
    [_theSystemBarMenu setAutoenablesItems:YES];
    
    [_theSystemBarMenu addItemWithTitle:@"About Fresh" action:@selector(showFreshAboutWindow) keyEquivalent:@""];
    [_theSystemBarMenu addItemWithTitle:@"Preferences..." action:@selector(showFreshPrefsWindow) keyEquivalent:@""];
    [_theSystemBarMenu addItem:[NSMenuItem separatorItem]];
    [_theSystemBarMenu addItemWithTitle:@"Quit Fresh" action:@selector(terminate:) keyEquivalent:@"q"];
    
    // About Us Window
    [[_theSystemBarMenu itemArray][0] setTarget:self];
    
    // Preferences Window
    [[_theSystemBarMenu itemArray][1] setTarget:self];
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


////
// Update the menubar icon (depending on the state)
//
- (void)updateMenubarIcon:(NSString *)imageToShow
{
    [_theSystemBarIcon setImage:[NSImage imageNamed:imageToShow]];
}

- (void)revertMenubarIcon
{
    [_theSystemBarIcon setImage:[NSImage imageNamed:SYSTEM_BAR_ICON_IMAGE]];
}


#pragma mark - Private - On Click Methods

////
// Action: on left/right click
//
- (void)onLeftClick:(id)sender
{
    NSLog(@"Left Click...");
    [_popup toggleWindow:sender];
}

- (void)onRightClick:(id)sender
{
    NSLog(@"Right Click...");
    [_theSystemBarIcon popUpStatusItemMenu:_theSystemBarMenu];
}


#pragma mark - Private - Windows

////
// Load "About Fresh" window
//
- (void)showFreshAboutWindow
{
    NSLog(@"Showing Preferences Window...");

    if (!_aboutUsWindow) {
        _aboutUsWindow = [[AboutUsWindow alloc] init];
    }

    [_aboutUsWindow showPreferencesWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

////
// Load "About Fresh" window
//
- (void)showFreshPrefsWindow
{
    if (!_preferencesWindow) {
        _preferencesWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow" owner:self];
    }
    
    [_preferencesWindow showWindow:self];
}

////
// Load "About Fresh" window
//
- (void)showFreshRegistrationWindow
{
    // Label: (yes - no)
    // Input: registration code
    // Validate (disabled, becomes active once full length code entered) - networking: check code (contact my server) - Yes/No
    // How do I make sure that once the app has been registered, it's all good? Encrypt and store a value :: before running
    // any promises - check!
}

@end
