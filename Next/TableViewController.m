//
//  TableViewController.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/30/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "TableViewController.h"
#import "NextAppDelegate.h"

@implementation TableViewController

@synthesize delegate;
@synthesize queue;

- (NSDictionary*)firstTrack {
    if (queue)
        return [[queue queue] objectAtIndex:0];

    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == [delegate playlistTableView])
    {
        return [[NSAPP_DELEGATE library] numberOfTracksInSelectedPlaylist];
    }
    else if (tableView == [delegate queueTableView])
    {
        return [queue count];
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (aTableView == [delegate playlistTableView])
    {
        NSMutableArray* plArray = [[NSAPP_DELEGATE library] selectedPlaylistArray];
        NSDictionary* track = nil;
        if ([plArray count] > rowIndex) track = [plArray objectAtIndex:rowIndex];
        return [track objectForKey:[aTableColumn identifier]];
    }
    else if (aTableView == [delegate queueTableView])
    {
        if ([[aTableColumn identifier] isEqualToString:@"idx"])
            return [NSString stringWithFormat:@"%ld", rowIndex+1];
        else
        {
            if (rowIndex < [queue count])
            {
                NSString* name = [[[queue queue] objectAtIndex:rowIndex] objectForKey:@"Name"];
                NSString* artist = ([[[queue queue] objectAtIndex:rowIndex] objectForKey:@"Artist"])?([NSString stringWithFormat:NSLocalizedString(@" by %@", @"Name by Artist - Track"), [[[queue queue] objectAtIndex:rowIndex] objectForKey:@"Artist"]]):(@"");
                
                return [NSString stringWithFormat:@"%@%@",
                        name,
                        artist
                        ];
            }
        }
    }
    
    return 0;
}

// NSTableView delegate function
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    if ([[tableView sortDescriptors] count] > 0)
    {
        NSSortDescriptor* sortDescriptor = [[tableView sortDescriptors] objectAtIndex:0];
        
        [[NSAPP_DELEGATE library] sortSelectedPlaylist:[sortDescriptor key] order:![sortDescriptor ascending]];
        
        [tableView reloadData];
        [UserDefaults saveStringToUserDefaults:[sortDescriptor key] forKey:@"sortKey"];
        [UserDefaults saveBoolToUserDefaults:![sortDescriptor ascending] forKey:@"sortDescending"];
    }
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    if (tableView == [delegate queueTableView])
    {
        // Copy the row numbers to the pasteboard.
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pboard declareTypes:[NSArray arrayWithObject:@"NextQueuePrivateDataType"] owner:self];
        [pboard setData:data forType:@"NextQueuePrivateDataType"];
        return YES;
    }
    else if (tableView == [delegate playlistTableView])
    {
        // Copy the row numbers to the pasteboard.
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pboard declareTypes:[NSArray arrayWithObject:@"NextTrackAdditionPrivateDataType"] owner:self];
        [pboard setData:data forType:@"NextTrackAdditionPrivateDataType"];
        return YES;
    }
    
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (tableView == [delegate queueTableView])
    {
        int result = NSDragOperationNone;
        
        if (dropOperation == NSTableViewDropAbove) {
            result = NSDragOperationMove;
        }
        
        return (result);
    }
    else if (tableView == [delegate playlistTableView])
    {
        return NSDragOperationEvery;
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)aRow dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:@"NextQueuePrivateDataType"];
    if (rowData)
    {
        NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        
        NSMutableIndexSet* selectedRows = [NSMutableIndexSet indexSet];
        NSInteger dragRow = [rowIndexes firstIndex];
        
        __block NSInteger row = aRow;
        
        __block NSUInteger x = 0;
        
        if (dragRow != row)
            [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSUInteger newIdx;
                if (idx > row)
                {
                    newIdx = idx;
                    while (newIdx != row+x)
                    {
                        [[queue queue] exchangeObjectAtIndex:newIdx withObjectAtIndex:newIdx-1];
                        newIdx--;
                    }
                }
                else
                {
                    row--;
                    newIdx = idx-x;
                    while (newIdx != row+x)
                    {
                        [[queue queue] exchangeObjectAtIndex:newIdx withObjectAtIndex:newIdx+1];
                        newIdx++;
                    }
                }
                x++;
                [selectedRows addIndex:newIdx];
            }];
        
        [tableView selectRowIndexes:selectedRows byExtendingSelection:NO];
        [[NSAPP_DELEGATE mwc] queueReload];
        
        return YES;
    }
    else
    {
        __block NSUInteger x = 0;
        
        rowData = [pboard dataForType:@"NextTrackAdditionPrivateDataType"];
        NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
            if ([[[NSAPP_DELEGATE library] selectedPlaylistArray] count] > idx && [[[NSAPP_DELEGATE library] selectedPlaylistArray] objectAtIndex:idx])
            { // Does the object exist ?
                NSNumber* selectedTrackID = [[[[NSAPP_DELEGATE library] selectedPlaylistArray] objectAtIndex:idx] objectForKey:@"Track ID"];
                NSDictionary* track = [[NSAPP_DELEGATE library] trackDictionaryFromID:[selectedTrackID stringValue]];
                
                if (aRow+x <= [queue count])
                    [queue addTrackWithoutSaving:track atIndex:aRow+x];
                else
                    [queue addTrackWithoutSaving:track atIndex:[queue count]];
                x++;
            }
        }];
        
        [queue saveQueue];
        [[NSAPP_DELEGATE mwc] queueReload];
        
        return YES;
    }
    
    return NO;
}

- (void)updateSortedTable {
    [self tableView:[delegate playlistTableView] sortDescriptorsDidChange:nil];
    //[[NSAPP_DELEGATE library] sortSelectedPlaylist:[lastColumn identifier] order:sortDescending];
}

- (void)addTracksFromFilenames:(NSNotification*)notification {
    if ([[notification userInfo] objectForKey:@"filenames"]) {
        for (NSString* filename in [[notification userInfo] objectForKey:@"filenames"]) {
             NSNumber* trackID = [[[NSAPP_DELEGATE library] allTracksLocations] objectForKey:[[NSString stringWithFormat:@"file://localhost%@", filename] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
            if (trackID) {
                [self addTrack:[[[NSAPP_DELEGATE library] allTracks] objectForKey:[trackID stringValue]]];
            }
        }
    }
}

- (void)addTrack:(NSDictionary*)track {
    [queue addTrack:track];
}

- (void)addTrack:(NSDictionary*)track atIndex:(NSUInteger)index {
    [queue addTrack:track atIndex:index];
}

- (void)clearQueue {
    [queue clear];
}

- (void)removeTracks:(NSIndexSet*)indexes {
    [queue removeTracksAtIndexes:indexes];
}

- (id)init {
    self = [super init];
    
    if (self)
    {
        queue = nil;
    }
    
    return self;
}

- (id)initWithQueue {
    self = [super init];
    if (self) {
        queue = [[NextQueue alloc] init];
        [queue setDelegate:(id<NextQueueDelegateProtocol>)self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTracksFromFilenames:) name:@"addTracksFromFilenames" object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    queue = nil;
}

@end
