//
//  TableViewControllerDelegateProtocol.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/30/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NextQueue.h"

@protocol TableViewControllerDelegateProtocol <NSObject>
@optional

- (NSTableView*)playlistTableView;
- (NSTableView*)queueTableView;
- (Library*)library;
- (void)addTrack:(NSDictionary*)track atIndex:(NSUInteger)index;
- (void)addTrackWithoutSaving:(NSDictionary*)track atIndex:(NSUInteger)index;
- (void)saveQueue;

@end
