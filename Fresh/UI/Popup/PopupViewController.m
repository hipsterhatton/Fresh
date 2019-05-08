//
//  Popup.m
//  Fresh
//
//  Created by Stephen Hatton on 22/10/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import "PopupViewController.h"

@interface PopupViewController ()

@end

@implementation PopupViewController

- (void)toggleWindow:(id)sender
{
    if (!self.popover.shown) {
        [self showPopover:sender];
    } else {
        [self closePopover];
    }
}

- (void)showPopover:(id)sender
{
    NSRect aRect = [sender bounds];
    [self.popover showRelativeToRect:aRect
                              ofView:sender
                       preferredEdge:NSMaxYEdge];
    
    // Setup the labels with a click handler
    NSClickGestureRecognizer *click = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)];
    [_currentLabel addGestureRecognizer:click];
    [_historyLabel addGestureRecognizer:click];
    [_favouritesLabel addGestureRecognizer:click];
}

- (void)labelClick
{
    NSLog(@"Click");
    if (self.popover.contentSize.height > 176) {
        [self.popover setContentSize:NSMakeSize(self.popover.contentSize.width, 176)];
    } else {
        [self.popover setContentSize:NSMakeSize(self.popover.contentSize.width, 250)];
    }
}

- (void)closePopover
{
    [self.popover performClose:self];
}

- (NSPopover *)popover
{
    if (!_popover) {
        _popover = [[NSPopover alloc] init];
        [_popover setContentViewController:self];
        [_popover setBehavior:NSPopoverBehaviorTransient];
        [_popover setAnimates:YES];
    }
    
    return _popover;
}

@end
