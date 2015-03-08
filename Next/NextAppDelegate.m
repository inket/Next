//
//  NextAppDelegate.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/5/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "NextAppDelegate.h"

@implementation NextAppDelegate

@synthesize shortcutRecorder;
@synthesize mwc;
@synthesize mWindow;
@synthesize pWindow;
@synthesize bowtie;
@synthesize library;

#pragma mark -
#pragma mark Notifications

- (void)restartApp {
    [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"sleep 1 ; /usr/bin/open '%@'", [[NSBundle mainBundle] bundlePath]], nil]];
    [NSApp terminate:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [mWindow makeKeyAndOrderFront:self];
    [pWindow makeKeyAndOrderFront:self];

    [mWindow makeFirstResponder:[mwc searchField]];
    [NSApp activateIgnoringOtherApps:YES];
    
    return YES;
}

- (IBAction)applicationShouldHandleReopen:(id)sender {
    [self applicationShouldHandleReopen:nil hasVisibleWindows:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if ([UserDefaults retrieveBoolFromUserDefaults:@"showMenubarIcon"]) {
        [self showMenubarIcon];
    }
    
    if (!LION)
    {
        [[[[NSApp menu] itemWithTitle:NSLocalizedString(@"View", @"View Menu")] submenu] setAutoenablesItems:NO];
        [[[[[NSApp menu] itemWithTitle:NSLocalizedString(@"View", @"View Menu")] submenu] itemAtIndex:2] setEnabled:NO];
    }
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self 
                                                           selector: @selector(receiveWakeNote:) 
                                                               name: NSWorkspaceDidWakeNotification object: NULL];

    [self openMainWindow];
    
    BOOL stopAutomatically = [UserDefaults retrieveBoolFromUserDefaults:@"stopAutomatically"];
    [stopiTunesAutomatically setState:stopAutomatically];
    [stopiTunesAutomaticallyStatusItem setState:stopAutomatically];
    
    [mWindow setCloseWindowOnEscape:[UserDefaults retrieveBoolFromUserDefaults:@"closeWindowOnEscape"]];
    
    // Setting up ShortcutRecorder
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        @autoreleasepool {
            shortcutRecorder = [[SRDelegate alloc] init];
            [shortcutRecorder registerGlobalHotKey:@"showNextHotkey" withDictionary:[UserDefaults retrieveHotKeyFromUserDefaults:@"showNextHotkey"]];
            [shortcutRecorder registerGlobalHotKey:@"nextTrackHotkey" withDictionary:[UserDefaults retrieveHotKeyFromUserDefaults:@"nextTrackHotkey"]];
            [shortcutRecorder registerGlobalHotKey:@"shuffleOnOffHotkey" withDictionary:[UserDefaults retrieveHotKeyFromUserDefaults:@"shuffleOnOffHotkey"]];
            [shortcutRecorder registerGlobalHotKey:@"addSelectedTrackHotkey" withDictionary:[UserDefaults retrieveHotKeyFromUserDefaults:@"addSelectedTrackHotkey"]];
        }
    });
    
    // Setting up the library :)
    library = [[Library alloc] init];
    [library load];
    
    // Setting up Growl
    growl = [[GrowlNotifier alloc] init];
    [GrowlApplicationBridge setGrowlDelegate:growl];
    
    if (![UserDefaults retrieveBoolFromUserDefaults:@"disableMediaKeyTap"])
    {
        mediaKeyTapDelegate = [[SPMediaKeyTapDelegate alloc] init];
        if ([SPMediaKeyTap usesGlobalMediaKeyTap]) [mediaKeyTapDelegate enableMediaKeyTap];
        [UserDefaults saveBoolToUserDefaults:NO forKey:@"disableMediaKeyTap"];
    }
    
    bowtie = [[BowtieModule alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willTerminate" object:nil];
    [UserDefaults saveStringToUserDefaults:[[mwc searchField] stringValue] forKey:@"resumeSearch"]; 
}

#pragma mark -
#pragma mark Managing Windows

- (void)openMainWindow {    
    if (!mWindow)
        [NSBundle loadNibNamed:@"MainWindow" owner:self];
    else
        [mWindow makeKeyAndOrderFront:self];
}

- (IBAction)openPreferences:(id)sender {
    if (!pWindow)
        [NSBundle loadNibNamed:@"Preferences" owner:self];

    [self applicationShouldHandleReopen:self];
}

#pragma mark -
#pragma mark Drag&Drop implementation

#pragma mark Dock icon

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addTracksFromFilenames" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:filename] forKey:@"filenames"]];
    
    [[NSAPP_DELEGATE mwc] queueReload];
    
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addTracksFromFilenames" object:nil userInfo:[NSDictionary dictionaryWithObject:filenames forKey:@"filenames"]];
    
    [[NSAPP_DELEGATE mwc] queueReload];
}

- (void)trackDrop:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    NSArray* pasteboardItems = [pboard pasteboardItems];

    dispatch_sync(dispatch_get_global_queue(0, 0), ^(void){
        @autoreleasepool {
            for (NSPasteboardItem* pbItem in pasteboardItems)
            {
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
                        if ([[[NSAPP_DELEGATE library] allTracksLocations] objectForKey:location]) {
                            NSNumber* trackID = [[[NSAPP_DELEGATE library] allTracksLocations] objectForKey:location];
                            
                            if ([[[NSAPP_DELEGATE library] allTracks] objectForKey:[trackID stringValue]]) {
                                NSDictionary* track = [[[NSAPP_DELEGATE library] allTracks] objectForKey:[trackID stringValue]];
                                
                                [[[mwc queueTableViewController] queue] addTrackWithoutTimerAndSaving:track];
                            }
                        }
                    }
                }
            }
        }
    });
    
    [[[mwc queueTableViewController] queue] saveQueue];
    [mwc queueReload];
    
    // Can't send messages to iTunes while it's providing the pasteboard... have to wait a bit.
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:[[[mwc queueTableViewController] queue] timer] selector:@selector(startTimer) userInfo:nil repeats:NO];
}

#pragma mark Menubar icon

- (NSDragOperation)statusItemView:(BCStatusItemView *)view draggingEntered:(id <NSDraggingInfo>)info
{
    for (NSPasteboardItem* pbItem in [[info draggingPasteboard] pasteboardItems]) {
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

- (void)statusItemView:(BCStatusItemView *)view draggingExited:(id <NSDraggingInfo>)info
{
    // Do nothing
}

- (BOOL)statusItemView:(BCStatusItemView *)view prepareForDragOperation:(id <NSDraggingInfo>)info
{
	return YES;
}

- (BOOL)statusItemView:(BCStatusItemView *)view performDragOperation:(id <NSDraggingInfo>)info
{
    [self trackDrop:[info draggingPasteboard] userData:nil error:nil];

    return YES;
}

#pragma mark -
#pragma mark Managing the menu bar icon

- (void)showMenubarIcon {
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setupView];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:[NSImage imageNamed:@"StatusItem-Default.png"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"StatusItem-Selected.png"]];
	[statusMenu setAutoenablesItems:NO];
	[statusItem setToolTip:@"Next"];
	[statusItem setHighlightMode:YES];
	[statusItem setViewDelegate:self];
	[[statusItem view] registerForDraggedTypes:[NSArray arrayWithObjects:@"com.apple.pasteboard.promised-file-url", @"public.file-url", nil]];
}

- (void)hideMenubarIcon {
    [statusItem removeObserver];
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    statusItem = nil;
}

#pragma mark -
#pragma mark Object initialization & termination

- (id)init {
	self = [super init];
        
	// First time the user launches the app / Used v1 ?
	if (![UserDefaults retrieveFromUserDefaults:@"version"])
	{
		// Used v1 before ?
        if ([UserDefaults retrieveBoolFromUserDefaults:@"notFirstLaunch"])
        {
            // Clean up old keys/objects
            [UserDefaults removeFromUserDefaults:@"notFirstLaunch"];
            [UserDefaults removeFromUserDefaults:@"albumColumnWidth"];
            [UserDefaults removeFromUserDefaults:@"artistColumnWidth"];
            [UserDefaults removeFromUserDefaults:@"nameColumnWidth"];
            [UserDefaults removeFromUserDefaults:@"NSWindow Frame Next"];
            [UserDefaults removeFromUserDefaults:@"hotkey"];
            if ([UserDefaults retrieveBoolFromUserDefaults:@"launchOnLogin"])
            {
                [LoginItem removeLoginItem];
                [LoginItem addLoginItem];
            }
            [UserDefaults removeFromUserDefaults:@"launchOnLogin"];
        }
        else // Put default values
        {
            [UserDefaults saveBoolToUserDefaults:NO forKey:@"hideOnDeactivate"];
            [UserDefaults saveBoolToUserDefaults:YES forKey:@"launchiTunes"];
            
            [UserDefaults saveToUserDefaults:12 forKey:@"fontSize"];
            [UserDefaults saveBoolToUserDefaults:YES forKey:@"showDockIcon"];
            [UserDefaults saveBoolToUserDefaults:YES forKey:@"showMenubarIcon"];
            
            [UserDefaults saveBoolToUserDefaults:NO forKey:@"enableBowtie"];
            
            [UserDefaults saveBoolToUserDefaults:YES forKey:@"trackChangeNotification"];
            [UserDefaults saveBoolToUserDefaults:YES forKey:@"trackAdditionNotification"];
            [UserDefaults saveBoolToUserDefaults:YES forKey:@"shuffleNotification"];
            
            [UserDefaults saveBoolToUserDefaults:NO forKey:@"queueCollapsed"];
            [UserDefaults saveBoolToUserDefaults:NO forKey:@"disableMediaKeyTap"];
            
            [UserDefaults saveBoolToUserDefaults:NO forKey:@"resumeFullscreen"];
            [UserDefaults saveStringToUserDefaults:@"" forKey:@"resumeSearch"];
        }
        
        [UserDefaults saveStringToUserDefaults:@"2.3" forKey:@"version"];
	}
    else if (![[UserDefaults retrieveStringFromUserDefaults:@"version"] isEqualToString:@"2.1"] && ![[UserDefaults retrieveStringFromUserDefaults:@"version"] isEqualToString:@"2.1.1"] && ![[UserDefaults retrieveStringFromUserDefaults:@"version"] isEqualToString:@"2.2"]) // Version 2.0.0 and up until 2.1
    {
        [UserDefaults removeFromUserDefaults:@"version"];
        [UserDefaults saveStringToUserDefaults:@"2.3" forKey:@"version"];
        
        [UserDefaults saveBoolToUserDefaults:NO forKey:@"resumeFullscreen"];
        [UserDefaults saveStringToUserDefaults:@"" forKey:@"resumeSearch"];
    }
    
    // Removing 2.1 keys
    if ([[UserDefaults retrieveStringFromUserDefaults:@"version"] isEqualToString:@"2.1"])
    {
        [UserDefaults removeFromUserDefaults:@"sortColumnDesc"];
        [UserDefaults removeFromUserDefaults:@"sortColumn"];
    }
    
    [UserDefaults saveStringToUserDefaults:@"2.3" forKey:@"version"];
    
    mWindow = nil;
    pWindow = nil;
    
	if ([UserDefaults retrieveBoolFromUserDefaults:@"showDockIcon"]) {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }
    
	if (![NSApp isHidden])
        [NSApp activateIgnoringOtherApps:YES];
    
    [NSApp setServicesProvider:self];
    
	return self;
}

- (void)dealloc {
    statusItem = nil;
    mediaKeyTapDelegate = nil;
    pWindow = nil;
    mWindow = nil;
    bowtie = nil;
}

#pragma mark -
#pragma mark 2.0.3 Bug fix

- (void)receiveWakeNote:(NSNotification*)note {
    JAProcessInfo* procInfo = [[JAProcessInfo alloc] init];
    
    [procInfo obtainFreshProcessList];
    
    BOOL result = NO;
    
    for (NSString* process in [procInfo processList]) {
        if ([process rangeOfString:@"Jitouch" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            result = YES;
            break;
        }
    }
    
    procInfo = nil;
    
    if (result)
    {
        NSLog(@"Restarting Next so as to not cause incompatibilities with Jitouch.");
        [self restartApp];
    }
}

#pragma mark - 2.2 feature

- (IBAction)addStopMarker:(id)sender {
    BOOL newState = ![sender state];
    [stopiTunesAutomatically setState:newState];
    [stopiTunesAutomaticallyStatusItem setState:newState];
    
    if (newState)
        [[[mwc queueTableViewController] queue] addStopMarker];
    else
        [[[mwc queueTableViewController] queue] removeStopMarker];
}

@end
