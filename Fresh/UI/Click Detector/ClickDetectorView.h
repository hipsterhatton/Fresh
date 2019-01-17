//
//  SampleView.h
//  Fresh
//
//  Created by Stephen Hatton on 22/10/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ClickDetectorView : NSView

@property (copy) void (^onLeftMouseClicked)(NSEvent *);
@property (copy) void (^onRightMouseClicked)(NSEvent *);

@end
