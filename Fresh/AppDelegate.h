//
//  AppDelegate.h
//  Fresh
//
//  Created by Stephen Hatton on 02/08/2018.
//  Copyright © 2018 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FRSHApp.h"
#import "MenuBar.h"
#import "AboutUsWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, retain) FRSHApp *app;
@property (nonatomic, retain) MenuBar *menubarUI;

@property (nonatomic, retain) AboutUsWindow *aboutUsWindow;
@end

