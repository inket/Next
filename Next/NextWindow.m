//
//  NextWindow.m
//  Next
//
//  Created by Mahdi Bchetnia on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NextWindow.h"
#import "NextAppDelegate.h"

@implementation NextWindow

@synthesize closeWindowOnEscape;

- (void)cancelOperation:(id)sender {
    if (closeWindowOnEscape) [[NSAPP_DELEGATE mWindow] close];
    else [super cancelOperation:sender];
}

@end
