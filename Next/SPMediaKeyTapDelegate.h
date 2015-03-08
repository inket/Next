//
//  SPMediaKeyTapDelegate.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/27/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPMediaKeyTap.h"
#import "NextTimer.h"

#define KEY_DOWN 0xA
#define KEY_UP 0xB

@interface SPMediaKeyTapDelegate : NSObject {
@private
    SPMediaKeyTap* mediaKeyTap;
    
    BOOL fastForwarding;
    BOOL rewinding;
    
    BOOL shouldPlayNext; // Is it ok to play the next track when the user held the fast forward button ?
}

- (void)enableMediaKeyTap;

@end
