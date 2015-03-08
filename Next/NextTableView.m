//
//  NextTableView.m
//  Next
//
//  Created by Mahdi Bchetnia on 5/13/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "NextTableView.h"
#import "NextAppDelegate.h"

@implementation NextTableView

- (void)keyDown:(NSEvent *)theEvent {    
    switch ([theEvent keyCode]) {
        // Left Arrow
        case 123:
            if (self == [[NSAPP_DELEGATE mwc] queueTableView])
                [[NSAPP_DELEGATE mWindow] makeFirstResponder:[[NSAPP_DELEGATE mwc] playlistTableView]];
            else
                [super keyDown:theEvent];
            break;
        
        // Right Arrow
        case 124:
            if (self == [[NSAPP_DELEGATE mwc] playlistTableView])
                [[NSAPP_DELEGATE mwc] addSelectedTracksUsingShortcut];
            else
                [super keyDown:theEvent];
            break;
            
        // Enter
        case 36:
            if (self == [[NSAPP_DELEGATE mwc] playlistTableView])
                [[NSAPP_DELEGATE mwc] addSelectedTracksUsingShortcut];
            else
                [super keyDown:theEvent];
            break;
        
        // Backspace
        case 51:
            if (self == [[NSAPP_DELEGATE mwc] queueTableView])
                [[NSAPP_DELEGATE mwc] removeSelectedTracks:self];
            else
                [super keyDown:theEvent];
            break;
            
        default: [super keyDown:theEvent]; break;
    }
}

@end
