//
//  NextWindow.h
//  Next
//
//  Created by Mahdi Bchetnia on 12/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NextWindow : NSWindow {
    BOOL closeWindowOnEscape;
}

@property (readwrite) BOOL closeWindowOnEscape;

@end
