//
//  AboutUsWindow.m
//  Fresh
//
//  Created by Stephen Hatton on 17/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "AboutUsWindow.h"

@interface AboutUsWindow ()
@property (weak) IBOutlet NSButton *testButton;
@end

@implementation AboutUsWindow

- (id)init
{
    if (![super initWithWindowNibName:@"AboutUsWindow"]) {
        return nil;
    }
    
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)showPreferencesWindow:(id)sender
{
    [[self window] center];
    [NSApp activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:sender];
}

@end
