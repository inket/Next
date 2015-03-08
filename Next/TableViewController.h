//
//  TableViewController.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/30/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Library.h"
#import "TableViewControllerDelegateProtocol.h"
#import "NextQueue.h"
#import "NextQueueDelegateProtocol.h"

@interface TableViewController : NSObject <NSTableViewDataSource> {
@private
    id <TableViewControllerDelegateProtocol> delegate;
    
    NextQueue* queue;
}

@property (nonatomic, strong) id <TableViewControllerDelegateProtocol> delegate;
@property (readonly) NextQueue* queue;

- (id)initWithQueue;
- (void)addTrack:(NSDictionary*)track;
- (void)addTrack:(NSDictionary*)track atIndex:(NSUInteger)index;
- (NSDictionary*)firstTrack;
- (void)clearQueue;
- (void)removeTracks:(NSIndexSet*)indexes;
//- (void)tableView: (NSTableView *)tableView didClickTableColumn: (NSTableColumn *) tableColumn;
- (void)updateSortedTable;

@end
