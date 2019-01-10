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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    if (![[NSBundle mainBundle] isLoginItem]) {
//        [[NSBundle mainBundle] addToLoginItems];
//        NSLog(@"Added Fresh to login items...");
//    } else {
//        NSLog(@"Fresh already added to login items...");
//    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
