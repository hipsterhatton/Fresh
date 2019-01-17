//
//  AppDelegate.m
//  Fresh
//
//  Created by Stephen Hatton on 02/08/2018.
//  Copyright © 2018 Stephen Hatton. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self launchFreshApp];
    [self launchFreshUI];
}

- (void)launchFreshApp
{
    NSLog(@"Launching Fresh...");
    _app = [[FRSHApp alloc] init];
}

- (void)launchFreshUI
{
    NSLog(@"Building Fresh UI...");
    _menubarUI = [[MenuBar alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

@end
