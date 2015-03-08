//
//  PreferencesController.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/26/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
#import "BowtieModule.h"
#import "LoginItem.h"
#import "SRRecorderControl.h"

@interface PreferencesController : NSObject {
@private
    IBOutlet NSTextField *addSelectedTrackLabel;
    IBOutlet SRRecorderControl *addSelectedTrackRecorder;
    IBOutlet NSTextField *behaviorSection;
    IBOutlet NSTextField *bowtieIntegrationSection;
    IBOutlet NSButton *closeMainWindowOnEscape;
    IBOutlet NSButton *enableBowtie;
    IBOutlet NSPopUpButton *fontSizeSelector;
    IBOutlet NSTextField *generalDescription;
    IBOutlet NSToolbarItem *generalTab;
    IBOutlet NSTextField *globalKeyboardShortcutsSection;
    IBOutlet NSTextField *growlNotificationsSection;
    IBOutlet NSButton *hideOnDeactivate;
    IBOutlet NSTextField *appearanceSection;
    IBOutlet NSButton *launchOnLogin;
    IBOutlet NSButton *launchiTunesWhenNecessary;
    IBOutlet NSTextField *listText;
    IBOutlet NSTextField *nextTrackLabel;
    IBOutlet SRRecorderControl *nextTrackRecorder;
    IBOutlet NSTextField *notificationsIntroduction;
    IBOutlet NSToolbarItem *notificationsTab;
    IBOutlet NSWindow *preferencesWindow;
    IBOutlet NSTextField *relaunchesNextInfo;
    IBOutlet NSTextField *shortcutsDescription;
    IBOutlet NSToolbarItem *shortcutsTab;
    IBOutlet NSButton *showDockIcon;
    IBOutlet NSButton *showMenubarIcon;
    IBOutlet NSTextField *showNextLabel;
    IBOutlet SRRecorderControl *showNextRecorder;
    IBOutlet NSButton *shuffleNotification;
    IBOutlet NSTextField *shuffleOnOffLabel;
    IBOutlet SRRecorderControl *shuffleOnOffRecorder;
    IBOutlet NSButton *trackAdditionNotification;
    IBOutlet NSButton *trackChangeNotification;
    
}

// Methods called from inside
- (void)resizeWindowAccordingly;
- (void)initializeWithValues;

// Interface Builder Actions
- (IBAction)changeTab:(id)sender;
- (IBAction)checkBoxValueChanged:(id)sender;

@end
