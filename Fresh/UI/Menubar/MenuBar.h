//
//  MenuBar.h
//  Wallpaper
//
//  Created by Stephen Hatton on 10/05/2016.
//  Copyright © 2016 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "ClickDetectorView.h"
#import "PopupViewController.h"

@interface MenuBar : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) NSStatusItem *theSystemBarIcon;
@property (nonatomic, retain) NSMenu *theSystemBarMenu;
@property (nonatomic, retain) PopupViewController *popup;

@end