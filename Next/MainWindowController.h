//
//  MainWindowController.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/26/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BWToolKitFramework/BWSplitView.h>
#import "MBSplitView.h"
#import "Library.h"
#import "TableViewController.h"
#import "NextTableView.h"
#import <Growl/Growl.h>
#import "MBPopUpButton.h"
#import "NextWindow.h"

@interface MainWindowController : NSObject <TableViewControllerDelegateProtocol> {
@private
    IBOutlet NextWindow *mainWindow;
    IBOutlet MBSplitView *splitView;
    IBOutlet NSPopUpButton *playlistSelector;
    IBOutlet NextTableView *playlistTableView;
    IBOutlet NSTextField *queueTitle;
    IBOutlet NextTableView *queueTableView;
    IBOutlet NSTextField *nextTrackLabel;
    IBOutlet NSButton *collapseButton;
    IBOutlet NSSearchField *searchField;
    
    IBOutlet NSTableColumn *nameColumn;
    IBOutlet NSTableColumn *artistColumn;
    IBOutlet NSTableColumn *albumColumn;
    IBOutlet NSTableColumn *queueColumn;

    IBOutlet NSButton* clearQueueButton;
    IBOutlet NSButton* removeTrackButton;
    
    TableViewController* playlistTableViewController;
    TableViewController* queueTableViewController;
    
    NSButton* fsButton;
}

@property (nonatomic, readonly) IBOutlet NextTableView* playlistTableView;
@property (nonatomic, readonly) IBOutlet NextTableView* queueTableView;
@property (nonatomic, readonly) IBOutlet NextWindow* mainWindow;
@property (readonly) IBOutlet NSSearchField *searchField;

@property (readonly) TableViewController* queueTableViewController;

- (IBAction)changeUIMode:(id)sender;
- (IBAction)changePlaylist:(id)sender;
- (IBAction)clearQueue:(id)sender;
- (IBAction)removeSelectedTracks:(id)sender;
- (void)updateCollapseButtonAndInit:(BOOL)init;
- (void)addToQueue:(NSDictionary*)track;
- (void)resizePlaylistSelectorToMatch;
- (IBAction)updateSearchFilter:(id)sender;
- (void)changeTextSize;
- (void)queueReload;
- (IBAction)addSelectedTracks:(id)sender;
- (void)addTrack:(NSDictionary*)track atIndex:(NSUInteger)index;
- (void)playImmediately;
- (void)addSelectedTracksUsingShortcut;
- (void)libraryLoaded;
- (void)libraryUpdated;

@end
