//
//  MenubarActions.m
//  Next
//
//  Created by Mahdi Bchetnia on 4/10/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "MenubarActions.h"
#import "NextAppDelegate.h"
#import "MainWindowController.h"

@interface MenubarActions(Private)
- (void)updateQueue:(NSNotification*)notification;
@end

@implementation MenubarActions

- (void)awakeFromNib {
    lock = [[NSLock alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueue:) name:@"updateQueue" object:nil];
    
    [[queue submenu] setAutoenablesItems:NO];
}

- (void)updateQueue:(NSNotification *)notification {
    if ([lock lockBeforeDate:[NSDate dateWithTimeInterval:1 sinceDate:[NSDate date]]])
    {
        NSArray* list = [[notification userInfo] objectForKey:@"list"];
    
        NSMenu* submenu = [queue submenu];
        
        if (list && [list count] > 0)
        {
            [submenu removeAllItems];
            
            for (int i=0; i<[list count]; i++) {
                NSString* title = [list objectAtIndex:i];
                NSMenuItem* item = [NSMenuItem alloc];
                
                if (i==0)
                    item = [item initWithTitle:title action:@selector(skipTrack:) keyEquivalent:@""];
                else
                    item = [item initWithTitle:title action:nil keyEquivalent:@""];

                [item setTarget:self];
                [item setEnabled:(i==0)?YES:NO];
                [submenu addItem:item];
            }
        }
        else
        {
            // Weird, but atleast it works.
            while ([submenu numberOfItems] > 1) {
                [submenu removeItemAtIndex:0];
            }
            
            [[submenu itemAtIndex:0] setTitle:NSLocalizedString(@"Empty", @"Queue menu item")];
            [[submenu itemAtIndex:0] setAction:nil];
            [[submenu itemAtIndex:0] setEnabled:NO];
        }
    
        [submenu update];
            
        [lock unlock];
    }
}

- (IBAction)playPause:(id)sender {
    iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
    [iTunes playpause];
}

- (IBAction)previousTrack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"previousTrackNoBackTracking" object:nil];
}

- (IBAction)addSelectedTracks:(id)sender {
    [[[[NSAPP_DELEGATE mwc] queueTableViewController] queue] addSelectediTunesTrack];
}

- (IBAction)collapseQueue:(id)sender {
    [[NSAPP_DELEGATE mwc] changeUIMode:sender];
}

- (IBAction)playImmediately:(id)sender {
    [[NSAPP_DELEGATE mwc] playImmediately];
}

- (IBAction)skipTrack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextTrack" object:nil];
}

- (IBAction)addToQueue:(id)sender {
    [[NSAPP_DELEGATE mwc] addSelectedTracksUsingShortcut];
}

- (IBAction)find:(id)sender {
    [[NSAPP_DELEGATE mWindow] makeFirstResponder:[[NSAPP_DELEGATE mwc] searchField]];
}

- (IBAction)clearQueue:(id)sender {
    [[NSAPP_DELEGATE mwc] clearQueue:sender];
}

- (IBAction)openSupport:(id)sender {
    NSURL* url = [NSURL URLWithString:NSLocalizedString(@"mailto:mahdi.adp@gmail.com", @"Support URL")];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)toggleFullscreen:(id)sender {
    [[NSAPP_DELEGATE mWindow] toggleFullScreen:sender];
}

- (void)dealloc {
    lock = nil;
}
@end
