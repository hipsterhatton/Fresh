//
//  AboutUsViewController.m
//  Fresh
//
//  Created by Stephen Hatton on 18/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    NSLog(@"Something");
}

- (IBAction)reportFreshIssue:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"www.google.co.uk"]];
}

@end
