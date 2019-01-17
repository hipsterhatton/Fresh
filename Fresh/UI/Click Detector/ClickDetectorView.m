//
//  SampleView.m
//  Fresh
//
//  Created by Stephen Hatton on 22/10/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import "ClickDetectorView.h"

@implementation ClickDetectorView

- (void)mouseDown:(NSEvent *)theEvent
{
    if (_onLeftMouseClicked) {
        _onLeftMouseClicked(theEvent);
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if (_onRightMouseClicked) {
        _onRightMouseClicked(theEvent);
    }
}

@end
