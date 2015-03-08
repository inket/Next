//
//  MBNextQueue.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/30/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "NextQueue.h"
#import "NextAppDelegate.h"

@implementation NextQueue

@synthesize delegate;

@synthesize queue;
@synthesize currentTrack;
@synthesize previousTrack;
@synthesize stopMarker;
@synthesize timer;

- (void)saveQueue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (![[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Next" stringByExpandingTildeInPath]])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Application Support/Next" stringByExpandingTildeInPath] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        NSDictionary* plist = [NSDictionary dictionaryWithObject:queue forKey:@"queue"];
        
        [plist writeToFile:[@"~/Library/Application Support/Next/queue.plist" stringByExpandingTildeInPath] atomically:YES];
    });
    
    if ([[self queue] count] > 0)
        stopMarker = YES;
}

- (void)loadQueue {    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Next/queue.plist" stringByExpandingTildeInPath]])
    {
        NSDictionary* plist = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Application Support/Next/queue.plist" stringByExpandingTildeInPath]];
        
        NSArray* tracks = [plist objectForKey:@"queue"];
        
        NSMutableArray* validDictionaries = [NSMutableArray array];
        
        for (NSDictionary* track in tracks) {
            if ([track isKindOfClass:[NSDictionary class]])
                [validDictionaries addObject:track];
        }
        
        tracks = validDictionaries;
        
        NSMutableArray* realTracks = [NSMutableArray array];
        for (NSDictionary* track in tracks) {
            [realTracks addObject:[NSNumber numberWithInteger:-1]];
        }
        
        // NSLog(@"%lu", [tracks count]);
        for (int i=0; i<[tracks count]; i++)
        {
            NSDictionary* track = [tracks objectAtIndex:i];
            NSDictionary* supposedlySameTrack = [[NSAPP_DELEGATE library] trackDictionaryFromID:[[track objectForKey:@"Track ID"] stringValue]];
            
            if ([[track objectForKey:@"Persistent ID"] isEqualToString:[supposedlySameTrack objectForKey:@"Persistent ID"]])
            {
                [realTracks replaceObjectAtIndex:i withObject:supposedlySameTrack];
                // NSLog(@"Match by Track ID seems good.");
            }
        }
        
        if ([realTracks containsObject:[NSNumber numberWithInteger:-1]])
        {
            // NSLog(@"Not all tracks were matched. Trying the hard way.");
            
            NSMutableIndexSet* indexesOfInvalidTracks = [NSMutableIndexSet indexSet];
            
            for (int i=0; i<[realTracks count]; i++)
            {
                if ([[realTracks objectAtIndex:i] isEqualTo:[NSNumber numberWithInteger:-1]])
                    [indexesOfInvalidTracks addIndex:i];
            }
            
            for (NSDictionary* dict in [[[NSAPP_DELEGATE library] allTracks] objectEnumerator])
            {
                [tracks enumerateObjectsAtIndexes:indexesOfInvalidTracks options:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                    if ([[obj objectForKey:@"Persistent ID"] isEqualToString:[dict objectForKey:@"Persistent ID"]])
                    {
                        // NSLog(@"Found track for item at index: %lu", idx);
                        [realTracks replaceObjectAtIndex:idx withObject:dict];
                        [indexesOfInvalidTracks removeIndex:idx];
                    }
                }];
                
                if ([indexesOfInvalidTracks count] == 0) {
                    // NSLog(@"Found all invalid tracks, breaking.");
                    break;
                }
            }
        }
        
        for (int i=0; i<[realTracks count]; i++)
        {
            if ([[realTracks objectAtIndex:i] isKindOfClass:[NSNumber class]])
            {
                [realTracks removeObjectAtIndex:i];
                i--;
                // NSLog(@"Deleted track because it couldn't be found.");
            }
        }
                        
        for (NSDictionary* track in realTracks) {
            [self addTrackWithoutSaving:track];
        }
        
        [self saveQueue];
        [[NSAPP_DELEGATE mwc] queueReload];
    }
}

- (void)setCurrentTrack:(NSString *)track {
    currentTrack = track;
}

- (void)setPreviousTrack:(NSString *)track {
    previousTrack = track;
}

- (NSUInteger)count {
    return [queue count];
}

- (void)addTrack:(NSDictionary*)track {
    [self addTrack:track atIndex:[queue count]];
}

- (void)addTrackWithoutSaving:(NSDictionary*)track {
    [self addTrackWithoutSaving:track atIndex:[queue count]];
}

- (void)addTrackWithoutTimerAndSaving:(NSDictionary *)track {
    [self addTrackWithoutTimerAndSaving:track atIndex:[queue count]];
}

- (void)addTrack:(NSDictionary *)track atIndex:(NSUInteger)index {
    if (track && [queue count] < 99) {
        [queue insertObject:track atIndex:index];
        
        if ([queue count] == 1) {
            [timer startTimer];
        }
    }

    [self saveQueue];
}

- (void)addTrackWithoutSaving:(NSDictionary *)track atIndex:(NSUInteger)index {
    if (track && [queue count] < 99) {
        [queue insertObject:track atIndex:index];
        
        if ([queue count] == 1) {
            [timer startTimer];
        }
    }
}

- (void)addTrackWithoutTimerAndSaving:(NSDictionary *)track atIndex:(NSUInteger)index {
    if (track && [queue count] < 99) {
        [queue insertObject:track atIndex:index];
    }
}



- (void)addSelectediTunesTrack {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"] count])
    {
        pid_t pid = [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"] objectAtIndex:0] processIdentifier];
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:pid];
        iTunesBrowserWindow* iTunesMainWindow = [[iTunes browserWindows] objectAtIndex:0];
        
        NSArray* selectedTracks = [[iTunesMainWindow selection] get];
        NSUInteger addedTracks = [queue count];
        
        // Did the user select tracks ?
        if ([selectedTracks count]) {
            
            NSString* notificationDescription = @"";
            
            for (iTunesTrack* track in selectedTracks) {
                if ([track videoKind] == iTunesEVdKNone) { // If the selected item is not a video
                    NSNumber* selectedTrackID = [NSNumber numberWithInteger:[track databaseID]];
                    NSDictionary* trackDict = [[NSAPP_DELEGATE library] trackDictionaryFromID:[selectedTrackID stringValue]];
                    
                    [self addTrackWithoutSaving:trackDict atIndex:[queue count]];
                    [[NSAPP_DELEGATE mwc] queueReload];
                    notificationDescription = [NSString stringWithFormat:@"%@%@%@", notificationDescription, ([notificationDescription isEqualToString:@""])?@"":@", ", [trackDict objectForKey:@"Name"]];
                }
            }
            
            [self saveQueue];
            
            addedTracks = [queue count] - addedTracks;
            if ([UserDefaults retrieveBoolFromUserDefaults:@"trackAdditionNotification"] && addedTracks > 0)
            {                    
                if ([notificationDescription length] > 70)
                {
                    notificationDescription = [NSString stringWithFormat:@"%@...", [notificationDescription substringToIndex:70]];
                }
                    
                [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"Added %ld track%@", addedTracks, (addedTracks > 1)?@"s":@""] description:notificationDescription notificationName:@"Track Added to the Queue" iconData:nil priority:0 isSticky:NO clickContext:nil];
            }
        }
    
    }
}

- (void)removeTracksAtIndexes:(NSIndexSet*)indexes {
    [queue removeObjectsAtIndexes:indexes];
    if ([queue count] == 0) {
        [timer stopTimerImmediately];
    }
    
    [[NSAPP_DELEGATE mwc] queueReload];
    [self saveQueue];
}

- (NSDictionary*)willPlayNextTrack {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"] count]) {
        if ([queue count] > 0)
        {
            if (currentTrack) {
                previousTrack = currentTrack;
            }
            else
            {
                iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
                if ([iTunes playerState] != iTunesEPlSStopped) {
                    previousTrack = [[[NSNumber numberWithInteger:[[iTunes currentTrack] databaseID]] stringValue] copy];
                }
                else
                {
                    previousTrack = nil;
                }
            }
            
            currentTrack = [[[[queue objectAtIndex:0] objectForKey:@"Track ID"] stringValue] copy];
            [self removeTracksAtIndexes:[NSIndexSet indexSetWithIndex:0]];
            return [[NSAPP_DELEGATE library] trackDictionaryFromID:currentTrack];
        }
        else
        {
            currentTrack = nil;
            previousTrack = nil;
            
            return nil;
        }
    }
    
    return nil;
}

- (NSDictionary*)willPlayPreviousTrack {
    if (currentTrack)
        [self addTrack:[[NSAPP_DELEGATE library] trackDictionaryFromID:currentTrack] atIndex:0];

    [[NSAPP_DELEGATE mwc] queueReload];
    [self saveQueue];
    
    if (previousTrack)
    {
        currentTrack = previousTrack;
        previousTrack = nil;
        return [[NSAPP_DELEGATE library] trackDictionaryFromID:currentTrack];
    }
    else
    {
        currentTrack = nil;
        previousTrack = nil;
        return nil;
    }
}

- (NSDictionary*)willOpeniTunesAndPlayTrack {
    if ([self count] > 0)
    {
        currentTrack = [[[[queue objectAtIndex:0] objectForKey:@"Track ID"] stringValue] copy];
        [self removeTracksAtIndexes:[NSIndexSet indexSetWithIndex:0]];
        
        return [[NSAPP_DELEGATE library] trackDictionaryFromID:currentTrack];
    }
    
    return nil;
}

- (void)updateQueue {
    NSMutableArray* newQueue = [[NSMutableArray alloc] init];
    
    for (NSDictionary* track in queue) {
        NSNumber* trackID = [track objectForKey:@"Track ID"];
        if ([[[NSAPP_DELEGATE library] allTracks] objectForKey:[trackID stringValue]]) {
            [newQueue insertObject:[[[NSAPP_DELEGATE library] allTracks] objectForKey:[trackID stringValue]] atIndex:[newQueue count]];
        }
    }
    
    queue = newQueue;
    [[NSAPP_DELEGATE mwc] queueReload];
    
    [self saveQueue];
}

- (void)clear {
    queue = [[NSMutableArray alloc] init];
    [timer stopTimerImmediately];
    
    [self saveQueue];
}

- (BOOL)isRadio:(NSString*)trackID {
    if ([[[[NSAPP_DELEGATE library] trackDictionaryFromID:trackID] objectForKey:@"Track Type"] isEqualToString:@"URL"])
        return YES;
    else
        return NO;
}

- (void)addStopMarker {
    [UserDefaults saveBoolToUserDefaults:YES forKey:@"stopAutomatically"];

    if ([[self queue] count] > 0 || ([[self queue] count] == 0 && [self currentTrack]) )
        stopMarker = YES;
    
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"] count])
    {
        pid_t pid = [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"] objectAtIndex:0] processIdentifier];
        iTunesApplication* iTunes = (iTunesApplication*)[[SBApplication alloc] initWithProcessIdentifier:pid];
        
        if ([currentTrack isEqualToString:[[NSNumber numberWithInteger:[[iTunes currentTrack] databaseID]] stringValue]])
            [timer startTimer];
    }
}

- (void)removeStopMarker {
    [UserDefaults saveBoolToUserDefaults:NO forKey:@"stopAutomatically"];
    
    stopMarker = NO;
    
    if ([queue count] == 0) [timer stopTimerImmediately];
}

- (id)init
{
    self = [super init];
    if (self) {
        timer = [[NextTimer alloc] init];
        [timer setDelegate:(id<NextTimerDelegateProtocol>)self];
        queue = [[NSMutableArray alloc] init];
        currentTrack = nil;
        previousTrack = nil;
    }
    
    return self;
}

@end
