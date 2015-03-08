//
//  NextTimer.m
//  Next
//
//  Created by Mahdi Bchetnia on 4/5/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "NextTimer.h"
#import "NextAppDelegate.h"

@interface NextTimer(Private)
- (void)openiTunesAndPlay;
- (void)stopTimer;
- (BOOL)stringIsEqualToNSData:(NSString *)str withData:(NSData *)data;
@end

@implementation NextTimer

@synthesize delegate;

#pragma mark -
#pragma mark Getting iTunes' status

- (BOOL)iTunesOpen {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"];
    if ([runningApps count])
    {
        iTunesPID = [[runningApps objectAtIndex:0] processIdentifier];
        return YES;
    }
    
    return NO;
}

- (BOOL)iTunesPlaying {
    if ([self iTunesOpen]) {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
        
        if ([iTunes playerState] == iTunesEPlSPlaying) {
            return YES;
        }
    }
    
    return NO;
}

- (NSData*)iconDataForCurrentTrack {
    if ([self iTunesOpen]) {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
        NSData* rawData = [NSData dataWithData:[[[[iTunes currentTrack] artworks] objectAtIndex:0] rawData]];
        return rawData;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Manipulating the timer

- (void)resumeTimer {
    if ([self iTunesOpen])
    {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:[[iTunes currentTrack] finish]-[iTunes playerPosition]-1.9-crossfade
                                                 target:self
                                               selector:@selector(playNext)
                                               userInfo:nil
                                                repeats:NO];
        
//        NSLog(@"resumeTimer");
    }
}

- (void)startTimer {
    BOOL iTunesOpen = [self iTunesOpen];
    if (iTunesOpen && timerStopped) {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];

        if ([delegate count] > 0 && [iTunes playerState] != iTunesEPlSPaused)
        {            
            NSString* trackID = [[NSNumber numberWithInteger:[[iTunes currentTrack] databaseID]] stringValue];
            
            if (![delegate isRadio:trackID])
                timerStopped = NO;
        }
        else if ([UserDefaults retrieveBoolFromUserDefaults:@"stopAutomatically"]  && [iTunes playerState] != iTunesEPlSPaused &&
                 [[delegate currentTrack] isEqualToString:[[NSNumber numberWithInteger:[[iTunes currentTrack] databaseID]] stringValue]] )
        {
            timerStopped = NO;
        }
    }
    else if (!iTunesOpen)
    {
        [self openiTunesAndPlay];
    }
}

- (void)stopTimer {    
    if (timer) {
        if ([timer respondsToSelector:@selector(invalidate)]) {
            [timer invalidate];
        }
    }
    
    timer = nil;
}

- (void)stopTimerImmediately {
    timerStopped = YES;
    [self stopTimer];
}

- (void)updateTimer {
    [self stopTimer];
    
    if (!timerStopped)
        [self resumeTimer];
}

- (void)startMainTimerThread {
    @autoreleasepool {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        
        [runLoop run];
    }
}

#pragma mark -
#pragma mark Manipulating iTunes

- (void)openiTunes:(NSURL*)location {
    @autoreleasepool {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]])
            [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        else
        {
            [[NSWorkspace sharedWorkspace] openURLs:nil withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchAndHide additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        }
        
        openingiTunes = NO;
    }
}

- (void)openiTunesAndPlay {
    if ([UserDefaults retrieveBoolFromUserDefaults:@"launchiTunes"] && !openingiTunes) {
        NSDictionary* track = [delegate willOpeniTunesAndPlayTrack];
        
        NSURL* location = nil;
        if (track)
        {
            location = [NSURL URLWithString:[track objectForKey:@"Location"]];
        }

        NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(openiTunes:) object:location];
        openingiTunes = YES;
        [thread start];
    }
}

- (void)shuffleOnOff {
    if ([self iTunesOpen]) {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
        if ([[iTunes currentPlaylist] specialKind] == iTunesESpKMusic || [[iTunes currentPlaylist] specialKind] == iTunesESpKNone || [[iTunes currentPlaylist] specialKind] == iTunesESpKLibrary || [[iTunes currentPlaylist] specialKind] == iTunesESpKPurchasedMusic)
        {
            if (!shuffleSet) {
                shuffle = [[iTunes currentPlaylist] shuffle];
                shuffleSet = YES;
            }
            if (shuffle != [[iTunes currentPlaylist] shuffle]) {
                [[iTunes currentPlaylist] setShuffle:shuffle];
            }
            else
            {
                shuffle = !shuffle;
                [[iTunes currentPlaylist] setShuffle:shuffle];
            }
        
            if ([UserDefaults retrieveBoolFromUserDefaults:@"shuffleNotification"])
            {
                if (shuffle) {
                    [GrowlApplicationBridge notifyWithTitle:@"Shuffle Enabled" description:[NSString stringWithFormat:@"Shuffle enabled for playlist \"%@\"", [[iTunes currentPlaylist] name]] notificationName:@"Shuffle Status Change" iconData:nil priority:0 isSticky:NO clickContext:nil];
                }
                else
                {
                    [GrowlApplicationBridge notifyWithTitle:@"Shuffle Disabled" description:[NSString stringWithFormat:@"Shuffle disabled for playlist \"%@\"", [[iTunes currentPlaylist] name]] notificationName:@"Shuffle Status Change" iconData:nil priority:0 isSticky:NO clickContext:nil];
                }
            }
        }
    }
}

- (void)playNext {
    [self stopTimerImmediately];
    
    if ([self iTunesOpen]) {
        NSDictionary* track = [delegate willPlayNextTrack];

        if (track) {
            
            NSURL* location = [NSURL URLWithString:[track objectForKey:@"Location"]];
            
            if ([[location absoluteString] hasPrefix:@"file://"]) // Local file ? Check if it's there and play it
            {
                if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]])
                    [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
            }
            else // other type of URL (http?), play it directly; it's a radio
            {
                [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
            }
            
            [self startTimer];
        }
        else 
        {
            iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
            
            if ([UserDefaults retrieveBoolFromUserDefaults:@"stopAutomatically"] && [delegate stopMarker])
            {
                [iTunes stop];
                [delegate setCurrentTrack:nil];
                [delegate setStopMarker:NO];
            }
            else
                [iTunes nextTrack];
        }
    }
}

- (void)playPrevious {
    [self stopTimerImmediately];
    
    if ([self iTunesOpen]) {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
        if ([iTunes playerPosition] > 2) {
            [iTunes backTrack];
        }
        else
        {
            NSDictionary* track = [delegate willPlayPreviousTrack];
            
            if (track) {
                NSURL* location = [NSURL URLWithString:[track objectForKey:@"Location"]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]]) {
                    [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
                }
            }
            else
            {
                [iTunes previousTrack];
            }
        }
    }
}

- (void)playPreviousNoBackTracking {
    [self stopTimerImmediately];
    
    if ([self iTunesOpen]) {
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];

        NSDictionary* track = [delegate willPlayPreviousTrack];
            
        if (track) {
            NSURL* location = [NSURL URLWithString:[track objectForKey:@"Location"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]]) {
                [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
            }
        }
        else
        {
            [iTunes previousTrack];
        }
    }
}

- (void)playTrackImmediately:(NSNotification*)notification {
   if ([self iTunesOpen])
   {
       NSDictionary* track = [notification userInfo];
       NSURL* location = [NSURL URLWithString:[track objectForKey:@"Location"]];
       if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]]) {
           [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
       }
              
       [delegate setCurrentTrack:nil];
       [delegate setPreviousTrack:nil];
   }
   else if ([UserDefaults retrieveBoolFromUserDefaults:@"launchiTunes"] && !openingiTunes)
   {
       NSDictionary* track = [notification userInfo];
       NSURL* location = [NSURL URLWithString:[track objectForKey:@"Location"]];
       
       if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]]) {
           [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:location] withAppBundleIdentifier:@"com.apple.iTunes" options:NSWorkspaceLaunchAndHide additionalEventParamDescriptor:nil launchIdentifiers:NULL];
       }
       
       [delegate setCurrentTrack:nil];
       [delegate setPreviousTrack:nil];
   }
}

- (void)fastForwardCallback:(BOOL)fastForwarding {
    if (fastForwarding && [delegate count] > 0)
    {
        showTrackChangeNotification = NO;
        [self playNext];
    }
}

#pragma mark -
#pragma mark Responding to iTunes' notifications

- (void)notifyWithGrowl:(NSDictionary*)userInfo {
    if (notificationsPile == 1 && userInfo)
    {
        [GrowlApplicationBridge
         notifyWithTitle:[userInfo objectForKey:@"Name"]
         description:[NSString stringWithFormat:@"%@\n%@", [userInfo objectForKey:@"Artist"], [userInfo objectForKey:@"Album"]]
         notificationName:@"Track Change Notification"
         iconData:[self iconDataForCurrentTrack]
         priority:0
         isSticky:NO
         clickContext:nil];
    }
    
    if (notificationsPile > 0) notificationsPile--;
}

- (void)gotNotification:(NSNotification *)notification {
	NSString *playerState = [[notification userInfo] objectForKey:@"Player State"];

    
	if ([playerState isEqualToString:@"Paused"])
	{
        [oldPlayerState setObject:[[notification userInfo] objectForKey:@"Player State"] forKey:@"Player State"];

        [self stopTimerImmediately];
	}
	else if ([playerState isEqualToString:@"Playing"])
	{
        if ([[oldPlayerState objectForKey:@"Player State"] isEqualToString:@"Playing"] && oldPlayerState) {
            
            if (![[[oldPlayerState objectForKey:@"PersistentID"] stringValue] isEqualToString:[[[notification userInfo] objectForKey:@"PersistentID"] stringValue]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isFastForwarding" object:nil userInfo:[NSDictionary dictionaryWithObject:self forKey:@"instance"]];
                [oldPlayerState setObject:[[notification userInfo] objectForKey:@"PersistentID"] forKey:@"PersistentID"];
                
                if ([UserDefaults retrieveBoolFromUserDefaults:@"trackChangeNotification"] && showTrackChangeNotification) {
                    NSString* trackName = [[notification userInfo] objectForKey:@"Name"]?[[notification userInfo] objectForKey:@"Name"]:@"";
                    NSString* trackArtist = [[notification userInfo] objectForKey:@"Artist"]?[[notification userInfo] objectForKey:@"Artist"]:@"";
                    NSString* trackAlbum = [[notification userInfo] objectForKey:@"Album"]?[[notification userInfo] objectForKey:@"Album"]:@"";

                    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trackName, @"Name", trackArtist, @"Artist", trackAlbum, @"Album", nil];
                    
                    if (notificationsPile==0)
                    {
                        notificationsPile++;
                        [GrowlApplicationBridge
                         notifyWithTitle:[userInfo objectForKey:@"Name"]
                         description:[NSString stringWithFormat:@"%@\n%@", [userInfo objectForKey:@"Artist"], [userInfo objectForKey:@"Album"]]
                         notificationName:@"Track Change Notification"
                         iconData:[self iconDataForCurrentTrack]
                         priority:0
                         isSticky:NO
                         clickContext:nil];
                        [self performSelector:@selector(notifyWithGrowl:) withObject:nil afterDelay:4];
                    }
                    else
                    {
                        notificationsPile++;
                        [self performSelector:@selector(notifyWithGrowl:) withObject:userInfo afterDelay:4];
                    }
                }
                else if (!showTrackChangeNotification)
                {
                    showTrackChangeNotification = YES;
                }
            }
        }
        else
            [oldPlayerState setObject:[[notification userInfo] objectForKey:@"Player State"] forKey:@"Player State"];

        [self startTimer];
	}
    
//    if ([playerState isEqualToString:@"Stopped"])
//    {
//        @try {
//            iTunesLibraryPlaylist* playlist = [[[[[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"] sources] objectAtIndex:0] libraryPlaylists] objectAtIndex:0];
//            
//            NSInteger count = [[playlist fileTracks] count];
//            int index = arc4random_uniform((u_int32_t)count);
//            [[[playlist fileTracks] objectAtIndex:index] playOnce:YES];
//        }
//        @catch (NSException *exception) {
//            NSLog(@"Couldn't play the main library. iTunes will remain stopped.");
//        }
//    }
}

#pragma mark -
#pragma mark Managing the crossfade value

- (void)setCrossfade {
    // Get the "Crossfade Songs" preference from iTunes
    NSData *iTunesPrefs = [[NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.apple.iTunes.plist" stringByExpandingTildeInPath]] objectForKey:@"pref:130:Preferences"];
    crossfade = 0;
    
    if ([self stringIsEqualToNSData:@"01" withData:[iTunesPrefs subdataWithRange:NSMakeRange(1945, 1)]])
    {
        NSInteger *crossfadeSeconds = (NSInteger *)[[iTunesPrefs subdataWithRange:NSMakeRange(1946, 1)] bytes];
        switch (*crossfadeSeconds) {
            case 6: crossfade = 6.5; break;
            case 7: crossfade = 7; break;
            case 8: crossfade = 7; break;
            case 9: crossfade = 7; break;
            case 10: crossfade = 8; break;
            case 11: crossfade = 8; break;
            case 12: crossfade = 9; break;
            default: crossfade = *crossfadeSeconds+1; break;
        }
    }
    
    iTunesPreferencesOpen = NO;
}

- (void)iTunesDialogNotification:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    if (iTunesPreferencesOpen && [[userInfo objectForKey:@"Showing Dialog"] intValue] == 0 && [[userInfo objectForKey:@"Dialog Level"] intValue] == 0)
    {
        [self setCrossfade];
    }
    else if ([[userInfo objectForKey:@"Showing Dialog"] intValue] == 1
             && [[userInfo objectForKey:@"Dialog Level"] intValue] == 1
             && [[userInfo objectForKey:@"Dialog ID"] intValue] == 134)
    {
        iTunesPreferencesOpen = YES;
    }
}

- (BOOL)stringIsEqualToNSData:(NSString *)str withData:(NSData *)data {
	NSMutableData *newData= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	byte_chars[0] = [str characterAtIndex:0];
	byte_chars[1] = [str characterAtIndex:1];
	whole_byte = strtol(byte_chars, NULL, 16);
	[newData appendBytes:&whole_byte length:1]; 
	
	return [newData isEqualToData:data];
}

#pragma mark -
#pragma mark Object initialization & destruction methods

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNext) name:@"nextTrack" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPrevious) name:@"previousTrack" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shuffleOnOff) name:@"shuffleOnOff" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playTrackImmediately:) name:@"playTrackImmediately" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openiTunesAndPlay) name:@"openiTunesAndPlay" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPreviousNoBackTracking) name:@"previousTrackNoBackTracking" object:nil];
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(gotNotification:)
                                                                name:@"com.apple.iTunes.playerInfo"
                                                              object:@"com.apple.iTunes.player"];
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(iTunesDialogNotification:)
                                                                name:@"com.apple.iTunes.dialogInfo"
                                                              object:@"com.apple.iTunes.dialog"];
        

        openingiTunes = NO;
        timerStopped = YES;
        shuffleSet = NO;
        showTrackChangeNotification = YES;
        notificationsPile = 0;
        
        NSThread* mainTimerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startMainTimerThread) object:nil]; //Create a new thread
        [mainTimerThread start];
        
        oldPlayerState = [[NSMutableDictionary alloc] init];
        
        // Initialize oldPlayerState so that we know if the track changed or not when we receive a notification
        if ([self iTunesOpen]) {
            iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:iTunesPID];
            switch ([iTunes playerState]) {
                case iTunesEPlSPaused:
                    [oldPlayerState setObject:@"Paused" forKey:@"Player State"];
                    break;
                    
                default: [oldPlayerState setObject:@"Playing" forKey:@"Player State"];
                    break;
            }
        }
        else
        {
            [oldPlayerState setObject:@"Playing" forKey:@"Player State"];
        }
        
        [self setCrossfade];
    }
    
    return self;
}

- (void)dealloc {
    oldPlayerState = nil;
}

@end
