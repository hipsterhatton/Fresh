//
//  Popup.h
//  Fresh
//
//  Created by Stephen Hatton on 22/10/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PopupViewController : NSViewController

@property (nonatomic, strong) NSPopover *popover;

@property (weak) IBOutlet NSTextField *historyLabel;
@property (weak) IBOutlet NSTextField *currentLabel;
@property (weak) IBOutlet NSTextField *favouritesLabel;
@property (weak) IBOutlet NSTextField *labelSelectedMarker;


- (void)toggleWindow:(id)sender;

@end
