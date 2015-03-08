//
//  MainWindowController.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/26/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "MainWindowController.h"
#import "NextAppDelegate.h"

#define SEARCH_OPTIONS ([NSArray arrayWithObjects:@"Search", @"All", @"Name", @"Artist", @"Album", @"Album Artist", nil])

@interface MainWindowController(Private)
- (void)positionPlaylistSelectorInTitlebar;
- (void)positionPlaylistSelectorInBottombar;
@end

@implementation MainWindowController

@synthesize playlistTableView;
@synthesize queueTableView;
@synthesize mainWindow;
@synthesize searchField;
@synthesize queueTableViewController;

#pragma mark - awakeFromNib

- (void)awakeFromNib {
    [NSAPP_DELEGATE setMwc:self];
    [NSAPP_DELEGATE setMWindow:mainWindow];
    
    if (LION)
    {
        NSPoint origin = [collapseButton frame].origin;
        [collapseButton setFrameOrigin:NSMakePoint(origin.x+11, origin.y)];
    }
    
    [mainWindow setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    
    [searchField setDelegate:(id<NSTextFieldDelegate>)self];
    
    // Create the search options
    NSMenu* searchMenu = [[NSMenu alloc] initWithTitle:@"Search"];

    for (NSString* title in SEARCH_OPTIONS)
        [searchMenu addItemWithTitle:NSLocalizedString(title, nil) action:@selector(updateSearchBounds:) keyEquivalent:@""];

    [[[searchMenu itemArray] objectAtIndex:0] setAction:nil];
    
    [[searchField cell] setSearchMenuTemplate:searchMenu];
    
    // Initialize the window's elements
    [mainWindow setHidesOnDeactivate:[UserDefaults retrieveBoolFromUserDefaults:@"hideOnDeactivate"]];
    [mainWindow registerForDraggedTypes:[NSArray arrayWithObject:@"public.item"]];
    [mainWindow setDelegate:(id<NSWindowDelegate>)self];

    [splitView setDelegate:splitView];
    [queueTitle setStringValue:NSLocalizedString(@"0 tracks queued", @"Queue Title") ];
    [collapseButton setState:![UserDefaults retrieveBoolFromUserDefaults:@"queueCollapsed"]];
    [self updateCollapseButtonAndInit:YES];
    [self changeTextSize];
    
    // Heh... tableviews.
    playlistTableViewController = [[TableViewController alloc] init];
    queueTableViewController = [[TableViewController alloc] initWithQueue];
    [playlistTableViewController setDelegate:self];
    [queueTableViewController setDelegate:self];
    [playlistTableView setDataSource:playlistTableViewController];
    [playlistTableView setDelegate:(id<NSTableViewDelegate>)playlistTableViewController];
    [queueTableView setDataSource:queueTableViewController];
    [queueTableView setDelegate:(id<NSTableViewDelegate>)playlistTableViewController];
    [playlistTableView setDoubleAction:@selector(doubleClickInPlaylist)];
    [playlistTableView setTarget:self];
    [queueTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"NextQueuePrivateDataType", @"NextTrackAdditionPrivateDataType", nil]];
    
    // Give the window a default size and position (center) if there's no frame saved in user defaults
    NSSize defaultSize = [mainWindow frame].size; defaultSize.width = 700; defaultSize.height = 400;
    NSRect defaultFrame = [mainWindow frame]; defaultFrame.size = defaultSize;
    [mainWindow setFrame:defaultFrame display:NO];
    [mainWindow center];
    [mainWindow setFrameAutosaveName:@"MainWindow"];

    [self positionPlaylistSelectorInTitlebar];
    
    if ([UserDefaults retrieveBoolFromUserDefaults:@"resumeFullscreen"])
        [mainWindow performSelector:@selector(toggleFullScreen:) withObject:nil afterDelay:0.1];
}

#pragma mark - NSWindowDelegate Protocol

- (void)windowWillEnterFullScreen:(NSNotification*)note {
    // HidesOnDeactivate messes with the fullscreen mode
    [mainWindow setHidesOnDeactivate:NO];
    [collapseButton setEnabled:NO];
    [collapseButton setHidden:YES];
    
    [playlistSelector setHidden:YES];
}

- (void)windowDidEnterFullScreen:(NSNotification*)note {
    // Save Fullscreen status to UserDefaults to be able to resume it next time
    [UserDefaults saveBoolToUserDefaults:YES forKey:@"resumeFullscreen"];
    [[[[[NSApp menu] itemWithTitle:NSLocalizedString(@"View", @"View Menu")] submenu] itemAtIndex:2] setTitle:NSLocalizedString(@"Exit Full Screen", @"Exit Full Screen")];
    
    // Make a fullscreen button and show it
    fsButton = [NSWindow standardWindowButton:NSWindowFullScreenButton forStyleMask:NSTitledWindowMask];
    NSRect superFrame = [[[mainWindow contentView] superview] frame];
    [fsButton setFrameOrigin:NSMakePoint(NSMaxX(superFrame)-NSWidth([fsButton frame])-3, NSMaxY(superFrame)-NSHeight([fsButton frame])-2)];
    
    NSImage* image = [NSImage imageNamed:@"fs-bg.png"];
    NSImageView* imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSMaxX(superFrame) - [image size].width + 140, NSMaxY(superFrame) - [image size].height - 5, [image size].width, [image size].height)];
    [imageView setImage:image];
    
    [imageView addSubview:fsButton];
    [imageView addSubview:playlistSelector];
    [fsButton setFrameOrigin:NSMakePoint(NSWidth([imageView frame]) - NSWidth([fsButton frame]) - 3, 1)];
    [playlistSelector setFrameOrigin:NSMakePoint(NSWidth([imageView frame]) - NSWidth([fsButton frame]) - NSWidth([playlistSelector frame]) - 7, -1)];
    [playlistSelector setHidden:NO];
    
    [[[mainWindow contentView] superview] addSubview:clearQueueButton];
    [[[mainWindow contentView] superview] addSubview:removeTrackButton];
    //[clearQueueButton setHidden:YES];
    //[removeTrackButton setHidden:YES];
    [clearQueueButton setFrameOrigin:NSMakePoint(NSMaxX([[clearQueueButton superview] frame])-68, NSMaxY([[clearQueueButton superview] frame])-NSHeight([clearQueueButton frame])-6)];
    [removeTrackButton setFrameOrigin:NSMakePoint(NSMaxX([[removeTrackButton superview] frame])-143, NSMaxY([[clearQueueButton superview] frame])-NSHeight([removeTrackButton frame])-6)];

    [[[mainWindow contentView] superview] addSubview:imageView];
    //[clearQueueButton setHidden:NO];
    //[removeTrackButton setHidden:NO];
    
    if ([splitView collapsed])
        [self changeUIMode:self];
    
    [[clearQueueButton animator] setFrameOrigin:NSMakePoint(NSMaxX([[clearQueueButton superview] frame])-68-140, [clearQueueButton frame].origin.y)];
    [[removeTrackButton animator] setFrameOrigin:NSMakePoint(NSMaxX([[removeTrackButton superview] frame])-143-140, [clearQueueButton frame].origin.y)];
    [[imageView animator] setFrameOrigin:NSMakePoint([imageView frame].origin.x - 140, [imageView frame].origin.y)];
    
    [self resizePlaylistSelectorToMatch];
}

- (void)windowWillExitFullScreen:(NSNotification *)note {
    [collapseButton setEnabled:YES];
    [collapseButton setHidden:NO];
    
    [self positionPlaylistSelectorInTitlebar];
    
    NSImageView* imageView = (NSImageView*)[fsButton superview];
    [fsButton removeFromSuperview];
    fsButton = nil;
    
    [imageView removeFromSuperview];
    
    NSView* superview = nil;
    for (NSView* view in [[[splitView subviews] objectAtIndex:1] subviews]) {
        if ([view frame].size.width != 1)
        {
            superview = view;
            break;
        }
    }
    
    [superview addSubview:clearQueueButton]; [superview addSubview:removeTrackButton]; 
    [clearQueueButton setFrameOrigin:NSMakePoint(NSMaxX([[clearQueueButton superview] frame])-68, 6)];
    [removeTrackButton setFrameOrigin:NSMakePoint(NSMaxX([[removeTrackButton superview] frame])-143, 6)];
}

- (void)windowDidExitFullScreen:(NSNotification *)note {
    [UserDefaults saveBoolToUserDefaults:NO forKey:@"resumeFullscreen"];
    [mainWindow setHidesOnDeactivate:[UserDefaults retrieveBoolFromUserDefaults:@"hideOnDeactivate"]];
    [[[[[NSApp menu] itemWithTitle:NSLocalizedString(@"View", @"View Menu")] submenu] itemAtIndex:2] setTitle:NSLocalizedString(@"Enter Full Screen", @"Enter Full Screen")];
    
    if ([splitView preFullScreenCollapseStatus])
        [self changeUIMode:self];
    
    [self resizePlaylistSelectorToMatch];
}

#pragma mark - NSDragging Protocol

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    for (NSPasteboardItem* pbItem in [[sender draggingPasteboard] pasteboardItems]) {
        NSArray* types = [pbItem types];
        NSString* location = nil;
        
        if ([types containsObject:@"com.apple.pasteboard.promised-file-url"])
        {
            location = [pbItem stringForType:@"com.apple.pasteboard.promised-file-url"];
        }
        else if ([types containsObject:@"public.file-url"])
        {
            location = [pbItem stringForType:@"public.file-url"];
        }
        
        if (location)
        {
            location = [NSString stringWithUTF8String:[location cStringUsingEncoding:NSUTF8StringEncoding]];
            
            if ([location hasSuffix:@".mp3"] ||
                [location hasSuffix:@".m4a"] ||
                [location hasSuffix:@".wav"] ||
                [location hasSuffix:@".aiff"] ||
                [location hasSuffix:@".m4p"] ||
                [location hasSuffix:@".aa"])
            {
                return NSDragOperationCopy;
            }
        }
    }
        
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSArray* items = [[[sender draggingPasteboard] pasteboardItems] copy];

    for (NSPasteboardItem* pbItem in items) {        
        NSString* location = nil;
        NSArray* types = [pbItem types];
        
        if ([types containsObject:@"com.apple.pasteboard.promised-file-url"])
        {
            location = [pbItem stringForType:@"com.apple.pasteboard.promised-file-url"];
        }
        else if ([types containsObject:@"public.file-url"])
        {
            location = [pbItem stringForType:@"public.file-url"];
        }
        
        if (location)
        {
            location = [NSString stringWithUTF8String:[location cStringUsingEncoding:NSUTF8StringEncoding]];
            
            if ([[[NSAPP_DELEGATE library] allTracksLocations] objectForKey:location])
            {
                NSNumber* trackID = [[[NSAPP_DELEGATE library] allTracksLocations] objectForKey:location];
                NSDictionary* track = [[[NSAPP_DELEGATE library] allTracks] objectForKey:[trackID stringValue]];
                
                if (track) {
                    [[queueTableViewController queue] addTrackWithoutTimerAndSaving:track];
                }
            }
        }
    }
    
    [[queueTableViewController queue] saveQueue];
    [self queueReload];
    
    // Can't send messages to iTunes while it's providing the pasteboard... have to wait a bit.
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:[[queueTableViewController queue] timer] selector:@selector(startTimer) userInfo:nil repeats:NO];
    
    return YES;
}

#pragma mark - NSControlTextEditingDelegate Protocol

// Rerouting the newLine character to enable NSSearchField to NSTableView focus using ENTER
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
		[mainWindow makeFirstResponder:playlistTableView];
		if ([playlistTableView selectedRow] == -1 && [playlistTableView numberOfRows] > 0)
			[playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		return YES;
    }
    
    return NO;
}

#pragma mark - Configuring/Updating the UI

- (void)positionPlaylistSelectorInTitlebar {
    NSView *frameView = [[mainWindow contentView] superview];
    NSRect frame = [frameView frame];
    
    NSRect otherFrame = [playlistSelector frame];
    otherFrame.origin.x = NSMaxX( frame ) - NSWidth( otherFrame ) - (LION?22:4);
    otherFrame.origin.y = NSMaxY( frame ) - NSHeight( otherFrame );
    [playlistSelector setFrame: otherFrame];
    
    [frameView addSubview: playlistSelector];
}

- (void)resizePlaylistSelectorToMatch {
    NSFont* playlistSelectorFont = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
    [playlistSelector setFont:playlistSelectorFont];
    
    CGFloat newWidth = 0;
    NSRect oldRect = [playlistSelector frame];
    
    if ([mainWindow styleMask] & NSFullScreenWindowMask)
        newWidth = 118;
    else
    {
        NSDictionary* attrs = [[NSDictionary alloc] initWithObjectsAndKeys:playlistSelectorFont, NSFontAttributeName, nil];
        
        newWidth = [[playlistSelector title] sizeWithAttributes:attrs].width + 30;
                
        if (newWidth > 180)
            newWidth = 180;
    }
    
    [playlistSelector setFrameSize:NSMakeSize(newWidth, oldRect.size.height)];
    if (newWidth != oldRect.size.width)
        [playlistSelector setFrame:NSMakeRect(oldRect.origin.x - (newWidth-oldRect.size.width), oldRect.origin.y, newWidth, oldRect.size.height)];
}

- (void)updateCollapseButtonAndInit:(BOOL)init {
    if ([collapseButton state]) {
        if ([collapseButton frame].size.width == 71) {
            [collapseButton setFrameSize:NSMakeSize(47, 18)];
            [collapseButton setFrameOrigin:NSMakePoint([collapseButton frame].origin.x+24, [collapseButton frame].origin.y)];
        }
        else if ([collapseButton frame].size.width == 62)
        {
            [collapseButton setFrameSize:NSMakeSize(37, 18)];
            [collapseButton setFrameOrigin:NSMakePoint([collapseButton frame].origin.x+25, [collapseButton frame].origin.y)];
        }
        
        [collapseButton setTitle:NSLocalizedString(@"Queue", @"Queue Button Title")];
        [nextTrackLabel setStringValue:@""];
    }
    else
    {
        if ([collapseButton frame].size.width == 47) {
            [collapseButton setFrameSize:NSMakeSize(71, 18)];
            [collapseButton setFrameOrigin:NSMakePoint([collapseButton frame].origin.x-24, [collapseButton frame].origin.y)];
        }
        else if ([collapseButton frame].size.width == 37)
        {
            [collapseButton setFrameSize:NSMakeSize(62, 18)];
            [collapseButton setFrameOrigin:NSMakePoint([collapseButton frame].origin.x-25, [collapseButton frame].origin.y)];
        }
        
        if (init)
            [collapseButton setTitle:NSLocalizedString(@"Queue (0)", @"Queue Button Title")];
        else
            [collapseButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Queue (%d)", @"Queue Button Title"), [queueTableViewController numberOfRowsInTableView:queueTableView]]];
        
        if ([queueTableView numberOfRows] > 0) {
            if ([queueTableViewController tableView:queueTableView objectValueForTableColumn:queueColumn row:0]) {
                [nextTrackLabel setStringValue:
                 [NSString stringWithFormat:NSLocalizedString(@"Next: %@.", @"Next track label - bottom bar"), (NSString*)[queueTableViewController tableView:queueTableView objectValueForTableColumn:nameColumn row:0]]];
            }
        }
        else
            [nextTrackLabel setStringValue:NSLocalizedString(@"Next: none.", @"Next track label - bottom bar")];
    }
    
    
    if ([queueTableView numberOfRows] > 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBowtie" object:nil userInfo:[NSDictionary dictionaryWithObject:[queueTableViewController firstTrack] forKey:@"track"]];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBowtie" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSDictionary dictionary] forKey:@"track"]];
}


- (IBAction)changeUIMode:(id)sender {
    if (sender != collapseButton)
        [collapseButton setState:![collapseButton state]];
    
    [splitView collapse];
    
    [self updateCollapseButtonAndInit:NO];
}

- (void)queueReload {
    [queueTableView reloadData];
    [queueTitle setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d track%@ queued", @"Queue Title"), [queueTableViewController numberOfRowsInTableView:queueTableView], ([queueTableViewController numberOfRowsInTableView:queueTableView]==1)?@"":NSLocalizedString(@"s", @"Suffix for multiple of track")]];
    
    [self updateCollapseButtonAndInit:NO];
    
    // update queue in menu item
    [NSThread detachNewThreadSelector:@selector(updateMenuItemQueue) toTarget:self withObject:nil];
}

- (void)updateMenuItemQueue {
    @autoreleasepool {
        NSMutableArray* list = [NSMutableArray array];
        
        for (int i=0; i<[queueTableView numberOfRows]; i++)
        {
            NSString* title = [[queueTableView dataSource] tableView:queueTableView objectValueForTableColumn:[[queueTableView tableColumns] objectAtIndex:1] row:i];
            
            [list addObject:title];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateQueue" object:nil userInfo:[NSDictionary dictionaryWithObject:list forKey:@"list"]];
    }
}

- (void)changeTextSize {
    float size = [[UserDefaults retrieveFromUserDefaults:@"fontSize"] floatValue];
    if (size == 0) size = 12;
    NSFont* font = [NSFont systemFontOfSize:size];
    [[nameColumn dataCell] setFont:font];
    [[artistColumn dataCell] setFont:font];
    [[albumColumn dataCell] setFont:font];
    [[queueColumn dataCell] setFont:font];
    [playlistTableView reloadData];
    [queueTableView reloadData];
}

#pragma mark - Responding to the library

- (void)libraryLoaded {    
    [playlistSelector setMenu:[[NSAPP_DELEGATE library] playlistsAsMenu]];
    
    // Restore the selected playlist
    NSString* oldPlaylist = [UserDefaults retrieveStringFromUserDefaults:@"selectedPlaylist"];
    if ([[[NSAPP_DELEGATE library] playlists] objectForKey:oldPlaylist])
        if ([playlistSelector itemWithTitle:oldPlaylist])
            [playlistSelector selectItemWithTitle:oldPlaylist];
        else
            [playlistSelector selectItemAtIndex:0];
    else
        [playlistSelector selectItemAtIndex:0];
    
    [self resizePlaylistSelectorToMatch];
    
    [[NSAPP_DELEGATE library] setSelectedPlaylist:[playlistSelector titleOfSelectedItem]];
    
    // Restore the sorting order
    NSString* sortKey = [UserDefaults retrieveStringFromUserDefaults:@"sortKey"];
    if (!sortKey || [sortKey isEqualToString:@""]) sortKey = @"Album";
    
    BOOL sortAscending = ![UserDefaults retrieveBoolFromUserDefaults:@"sortDescending"];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:sortAscending];
    [playlistTableView setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self queueReload];
    
    // Restore the search input
    NSString* resumeSearch = [UserDefaults retrieveStringFromUserDefaults:@"resumeSearch"];
    if (resumeSearch && ![resumeSearch isEqualToString:@""])
    {
        [searchField setStringValue:resumeSearch];
        [self updateSearchFilter:searchField];
    }
    
    // Restore the search bounds
    NSMenu* searchMenu = [[searchField cell] searchMenuTemplate];
    NSNumber* searchBound = [UserDefaults retrieveFromUserDefaults:@"searchBounds"];
    NSInteger savedSearchBounds = searchBound?[searchBound integerValue]:0;
    
    if (savedSearchBounds == 0 || savedSearchBounds >= [[searchMenu itemArray] count])
        savedSearchBounds = 1;

    [self updateSearchBounds:[[searchMenu itemArray] objectAtIndex:savedSearchBounds]];
    
    // Restore the queue
    [[queueTableViewController queue] loadQueue];
}

- (void)libraryUpdated {
    NSString* selectedItem = [playlistSelector titleOfSelectedItem];
    
    [playlistSelector setMenu:[[NSAPP_DELEGATE library] playlistsAsMenu]];
    
    if ([[playlistSelector menu] itemWithTitle:selectedItem]) {
        [playlistSelector selectItemWithTitle:selectedItem];
    }
    else
    {
        [playlistSelector selectItemAtIndex:0];
        [self resizePlaylistSelectorToMatch];
    }

    [playlistTableView reloadData];
    
    [[queueTableViewController queue] updateQueue];
}

- (IBAction)changePlaylist:(id)sender {
    [self resizePlaylistSelectorToMatch];
    
    // [[playlistSelector selectedItem] title] is released if sent directly. Have to make a copy. Not leaking even if analyzer says so.
    [[NSAPP_DELEGATE library] setSelectedPlaylist:[playlistSelector titleOfSelectedItem]];
    [playlistTableViewController updateSortedTable];
    [searchField setStringValue:@""];
    [playlistTableView reloadData];
    [UserDefaults saveStringToUserDefaults:[playlistSelector titleOfSelectedItem] forKey:@"selectedPlaylist"];
}

#pragma mark - User Actions

// Call from keyboard shortcut CMD+O or Controls -> Play Immediately
- (void)playImmediately {
    if ([playlistTableView selectedRow] != -1) {
        NSDictionary* track = [[[NSAPP_DELEGATE library] selectedPlaylistArray] objectAtIndex:[playlistTableView selectedRow]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrackImmediately" object:nil userInfo:track];
    }
}

// Call from the menu item: Controls -> Add to Queue (shortcut: Enter)
- (void)addSelectedTracksUsingShortcut {
    if ([mainWindow firstResponder] == playlistTableView) {
        [self addSelectedTracks:self];
    }
}

// Call from the button
- (IBAction)addSelectedTracks:(id)sender {
    if ([[playlistTableView selectedRowIndexes] count] > 0) {
        [[playlistTableView selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if ([[[NSAPP_DELEGATE library] selectedPlaylistArray] count] > idx && [[[NSAPP_DELEGATE library] selectedPlaylistArray] objectAtIndex:idx]) { // Does the object exist ?
                NSNumber* selectedTrackID = [[[[NSAPP_DELEGATE library] selectedPlaylistArray] objectAtIndex:idx] objectForKey:@"Track ID"];
                NSDictionary* track = [[[NSAPP_DELEGATE library] allTracks] objectForKey:[selectedTrackID stringValue]];
                
                [[queueTableViewController queue] addTrackWithoutSaving:track];
            }
        }];
        
        [[queueTableViewController queue] saveQueue];
        [self queueReload];
    }
}

// Bridging
- (void)addTrack:(NSDictionary*)track atIndex:(NSUInteger)index {
    [queueTableViewController addTrack:track atIndex:index];
    [self queueReload];
}

// Called every time the user double clicks in a tableview row
- (void)doubleClickInPlaylist {
    if ([playlistTableView clickedRow] != -1) {
        [self addSelectedTracks:self];
    }
}

// Bridging
- (void)addToQueue:(NSDictionary*)track {
    [queueTableViewController addTrack:track];
}

- (IBAction)clearQueue:(id)sender {
    [queueTableViewController clearQueue];
    [self queueReload];
}

- (IBAction)removeSelectedTracks:(id)sender {
    [queueTableViewController removeTracks:[queueTableView selectedRowIndexes]];
    [queueTableView deselectAll:self];
    [self queueReload];
}

- (IBAction)updateSearchFilter:(id)sender {
    [[NSAPP_DELEGATE library] setSearchString:[sender stringValue] justARefresh:NO];
    [playlistTableView deselectAll:self];
}

- (IBAction)updateSearchBounds:(id)sender {
    NSMenuItem* item = sender;
    
    for (NSMenuItem* anItem in [[item menu] itemArray]) {
        [anItem setState:NSOffState];
    }
    
    [item setState:NSOnState];
    NSInteger index = [[item menu] indexOfItem:item];
    
    [UserDefaults saveToUserDefaults:(float)index forKey:@"searchBounds"];
    
    [[NSAPP_DELEGATE library] setSearchBounds:index<=1?nil:[SEARCH_OPTIONS objectAtIndex:index]];
    [[NSAPP_DELEGATE library] setSearchString:@"" justARefresh:YES];
    [playlistTableView deselectAll:self];
}

@end
