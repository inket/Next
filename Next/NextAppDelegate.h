//
//  NextAppDelegate.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/5/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Library.h"
#import "BowtieModule.h"
#import "SPMediaKeyTapDelegate.h"
#import "SRDelegate.h"
#import "UserDefaults.h"
#import "LoginItem.h"
#import "GrowlNotifier.h"
#import "NSStatusItem+BCStatusItem.h"
#import "BCStatusItemView.h"
#import "MainWindowController.h"
#import "SPMediaKeyTap.h"
#import "JAProcessInfo.h"
#import "NextWindow.h"

@interface NextAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NextWindow* mWindow; // Main Window
    
    NSWindow* pWindow; // Preferences Window
    
    NSStatusItem* statusItem;
    IBOutlet NSMenu* statusMenu;
    
    IBOutlet NSMenuItem* stopiTunesAutomatically;
    IBOutlet NSMenuItem* stopiTunesAutomaticallyStatusItem;
    
    BowtieModule* bowtie;
    Library* library;
    SRDelegate* shortcutRecorder;
    SPMediaKeyTapDelegate* mediaKeyTapDelegate;
    GrowlNotifier* growl;
    MainWindowController* mwc;
}

@property (nonatomic, readonly) SRDelegate* shortcutRecorder;
@property (strong) MainWindowController* mwc;
@property (strong) NextWindow* mWindow;
@property (strong) NSWindow* pWindow;
@property (strong) BowtieModule* bowtie;
@property (strong) Library* library;

- (IBAction)applicationShouldHandleReopen:(id)sender;

- (void)openMainWindow;
- (IBAction)openPreferences:(id)sender;

- (IBAction)addStopMarker:(id)sender;

- (void)showMenubarIcon;
- (void)hideMenubarIcon;
- (void)trackDrop:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

- (void)restartApp;

@end
