//
//  NextTimer.h
//  Next
//
//  Created by Mahdi Bchetnia on 4/5/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NextTimerDelegateProtocol.h"
#import <Growl/Growl.h>

@interface NextTimer : NSObject <NextTimerDelegateProtocol> {
@private
    BOOL timerStopped;
    
    double crossfade;
    BOOL iTunesPreferencesOpen;
        
    NSTimer* timer;
    
    BOOL shuffleSet;
    BOOL shuffle;
    
    BOOL openingiTunes;
    
    NSMutableDictionary* oldPlayerState;
    
    pid_t iTunesPID;
    
    BOOL showTrackChangeNotification;
    
    NSInteger notificationsPile;
    
    id <NextTimerDelegateProtocol> delegate; // NextQueue
}

@property (nonatomic, strong) id <NextTimerDelegateProtocol> delegate;

- (void)playNext;
- (void)playPrevious;

- (void)startTimer;
- (void)stopTimerImmediately;

- (void)fastForwardCallback:(BOOL)fastForwarding;

@end
