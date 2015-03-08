//
//  MBNextQueue.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/30/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NextTimer.h"
#import "NextQueueDelegateProtocol.h"
#import <Growl/Growl.h>

@interface NextQueue : NSObject {
@private
    NSMutableArray* queue;
    
    NSString* currentTrack;
    NSString* previousTrack;
    
    NextTimer* timer;
    
    BOOL stopMarker;
    
    id <NextQueueDelegateProtocol> delegate;
}

@property (nonatomic, strong) id <NextQueueDelegateProtocol> delegate;

@property (nonatomic, readonly) NSMutableArray* queue;

@property (nonatomic, strong) NSString* currentTrack;
@property (nonatomic, strong) NSString* previousTrack;

@property (nonatomic, assign) BOOL stopMarker;

@property (nonatomic, strong) NextTimer* timer;

- (NSUInteger)count;
- (void)addTrack:(NSDictionary*)track;
- (void)addTrackWithoutSaving:(NSDictionary*)track;
- (void)addTrackWithoutTimerAndSaving:(NSDictionary *)track;
- (void)addTrack:(NSDictionary *)track atIndex:(NSUInteger)index;
- (void)addTrackWithoutSaving:(NSDictionary *)track atIndex:(NSUInteger)index;
- (void)addTrackWithoutTimerAndSaving:(NSDictionary *)track atIndex:(NSUInteger)index;
- (void)clear;
- (void)removeTracksAtIndexes:(NSIndexSet*)indexes;
- (BOOL)isRadio:(NSString*)trackID;

- (void)loadQueue;

- (void)updateQueue;
- (void)addSelectediTunesTrack;

- (void)addStopMarker;
- (void)removeStopMarker;

- (void)saveQueue;

@end
