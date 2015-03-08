//
//  SPMediaKeyTapDelegate.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/27/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "SPMediaKeyTapDelegate.h"


@implementation SPMediaKeyTapDelegate

#pragma mark -
#pragma mark Helper methods

- (BOOL)iTunesOpen {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"] count])
        return YES;
    
    return NO;
}

- (void)isFastForwarding:(NSNotification*)notification {
    NextTimer* object = [[notification userInfo] objectForKey:@"instance"];
    
    [object fastForwardCallback:shouldPlayNext];
    
    shouldPlayNext = NO;
}

#pragma mark -
#pragma mark SPMediaKeyTap Delegate Methods

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	assert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys);
        
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	int keyState = (((keyFlags & 0xFF00) >> 8));
	int keyRepeat = (keyFlags & 0x1);
    
    if (![self iTunesOpen])
    {
        if (keyState == KEY_DOWN) {
            switch (keyCode) {
                case NX_KEYTYPE_PLAY:
                    if (!keyRepeat) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"openiTunesAndPlay" object:nil];
                    }
                    return;
            }
        } 
    }
                    
    iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
    
	if (keyState == KEY_DOWN) {
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
                if (!keyRepeat) {
                    [iTunes playpause];
                }
                break;
				
			case NX_KEYTYPE_FAST:
                if (keyRepeat && !fastForwarding) {
                    [iTunes fastForward];
                    fastForwarding = YES;
                    shouldPlayNext = YES;
                }
                break;
				
			case NX_KEYTYPE_REWIND:
                if (keyRepeat && !rewinding) {
                    [iTunes rewind];
                    rewinding = YES;
                }
                break;
		}
	}
    else if (keyState == KEY_UP)
    {
        switch (keyCode) {
			case NX_KEYTYPE_FAST:
                if (fastForwarding)
                {
                    [iTunes resume];
                    fastForwarding = NO;
                    shouldPlayNext = NO;
                }
                else
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextTrack" object:nil];
                break;
                
            case NX_KEYTYPE_REWIND:
                if (rewinding) {
                    [iTunes resume];
                    rewinding = NO;
                }
                else
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"previousTrack" object:nil];
                break;
		}
    }
}

#pragma mark -
#pragma mark Initialization Methods

- (void)enableMediaKeyTap {
    [mediaKeyTap startWatchingMediaKeys];
}

- (id)init
{
    self = [super init];
    if (self) {
        fastForwarding = NO;
        rewinding = NO;
        shouldPlayNext = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isFastForwarding:) name:@"isFastForwarding" object:nil];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                                 nil]];
        
        mediaKeyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    mediaKeyTap = nil;
}

@end
