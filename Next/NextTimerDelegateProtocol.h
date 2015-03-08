//
//  NextTimerDelegateProtocol.h
//  Next
//
//  Created by Mahdi Bchetnia on 4/5/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NextTimerDelegateProtocol <NSObject>
@optional

- (NSMutableArray*)queue;
- (NSUInteger)count;

- (void)addTrack:(NSDictionary*)track atIndex:(NSUInteger)index;

- (NSString*)currentTrack;
- (NSString*)previousTrack;
- (void)setCurrentTrack:(NSString*)dict;
- (void)setPreviousTrack:(NSString*)dict;

- (NSDictionary*)willPlayNextTrack;
- (NSDictionary*)willPlayPreviousTrack;
- (NSDictionary*)willOpeniTunesAndPlayTrack;

- (BOOL)isRadio:(NSString*)trackID;

- (BOOL)stopMarker;
- (void)setStopMarker:(BOOL)val;


@end
