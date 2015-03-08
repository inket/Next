//
//  MenubarActions.h
//  Next
//
//  Created by Mahdi Bchetnia on 4/10/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenubarActions : NSObject {
@private
    IBOutlet NSMenuItem* queue;
    NSLock* lock;
}

- (IBAction)playPause:(id)sender;
- (IBAction)previousTrack:(id)sender;
- (IBAction)addSelectedTracks:(id)sender;
- (IBAction)collapseQueue:(id)sender;
- (IBAction)playImmediately:(id)sender;
- (IBAction)skipTrack:(id)sender;
- (IBAction)addToQueue:(id)sender;
- (IBAction)find:(id)sender;
- (IBAction)clearQueue:(id)sender;
- (IBAction)toggleFullscreen:(id)sender;
- (IBAction)openSupport:(id)sender;

@end
