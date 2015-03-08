//
//  PreferencesController.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/26/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "PreferencesController.h"
#import "NextAppDelegate.h"

@implementation PreferencesController

- (void)resizeWindowAccordingly {
    if ([[[preferencesWindow toolbar] selectedItemIdentifier] isEqual:[generalTab itemIdentifier]]) {
        NSRect newFrame = [preferencesWindow frame];
        newFrame.size.height = 388;
        newFrame.origin.y -= 388-[preferencesWindow frame].size.height;
        [preferencesWindow setFrame:newFrame display:YES animate:YES];
        
        [preferencesWindow setContentMaxSize:newFrame.size];
        [preferencesWindow setContentMinSize:newFrame.size];
    }
    else if ([[[preferencesWindow toolbar] selectedItemIdentifier] isEqual:[shortcutsTab itemIdentifier]])
    {
        NSRect newFrame = [preferencesWindow frame];
        newFrame.size.height = 350;
        newFrame.origin.y -= 350-[preferencesWindow frame].size.height;
        [preferencesWindow setFrame:newFrame display:YES animate:YES];
        
        [preferencesWindow setContentMaxSize:newFrame.size];
        [preferencesWindow setContentMinSize:newFrame.size];
    }
    else if ([[[preferencesWindow toolbar] selectedItemIdentifier] isEqual:[notificationsTab itemIdentifier]])
    {
        NSRect newFrame = [preferencesWindow frame];
        newFrame.size.height = 221;
        newFrame.origin.y -= 221-[preferencesWindow frame].size.height;
        [preferencesWindow setFrame:newFrame display:YES animate:YES];
        
        [preferencesWindow setContentMaxSize:newFrame.size];
        [preferencesWindow setContentMinSize:newFrame.size];
    }
}
- (IBAction)changeTab:(id)sender {
    [preferencesWindow setTitle:[sender label]];
    [[preferencesWindow toolbar] setSelectedItemIdentifier:[sender itemIdentifier]];
    
    if (sender == generalTab) {
        [behaviorSection setHidden:NO];
        [bowtieIntegrationSection setHidden:NO];
        [closeMainWindowOnEscape setHidden:NO];
        [enableBowtie setHidden:NO];
        [fontSizeSelector setHidden:NO];
        [generalDescription setHidden:NO];
        [hideOnDeactivate setHidden:NO];
        [appearanceSection setHidden:NO];
        [launchOnLogin setHidden:NO];
        [launchiTunesWhenNecessary setHidden:NO];
        [listText setHidden:NO];
        [relaunchesNextInfo setHidden:NO];
        [showDockIcon setHidden:NO];
        [showMenubarIcon setHidden:NO];
        
        [globalKeyboardShortcutsSection setHidden:YES];
        [showNextLabel setHidden:YES];
        [showNextRecorder setHidden:YES];
        [nextTrackLabel setHidden:YES];
        [nextTrackRecorder setHidden:YES];
        [shuffleOnOffLabel setHidden:YES];
        [shuffleOnOffRecorder setHidden:YES];
        [addSelectedTrackLabel setHidden:YES];
        [addSelectedTrackRecorder setHidden:YES];
        [shortcutsDescription setHidden:YES];
        
        [growlNotificationsSection setHidden:YES];
        [notificationsIntroduction setHidden:YES];
        [trackChangeNotification setHidden:YES];
        [trackAdditionNotification setHidden:YES];
        [shuffleNotification setHidden:YES];
    }
    else if (sender == shortcutsTab)
    {
        [behaviorSection setHidden:YES];
        [bowtieIntegrationSection setHidden:YES];
        [closeMainWindowOnEscape setHidden:YES];
        [enableBowtie setHidden:YES];
        [fontSizeSelector setHidden:YES];
        [generalDescription setHidden:YES];
        [hideOnDeactivate setHidden:YES];
        [appearanceSection setHidden:YES];
        [launchOnLogin setHidden:YES];
        [launchiTunesWhenNecessary setHidden:YES];
        [listText setHidden:YES];
        [relaunchesNextInfo setHidden:YES];
        [showDockIcon setHidden:YES];
        [showMenubarIcon setHidden:YES];
        
        [globalKeyboardShortcutsSection setHidden:NO];
        [showNextLabel setHidden:NO];
        [showNextRecorder setHidden:NO];
        [nextTrackLabel setHidden:NO];
        [nextTrackRecorder setHidden:NO];
        [shuffleOnOffLabel setHidden:NO];
        [shuffleOnOffRecorder setHidden:NO];
        [addSelectedTrackLabel setHidden:NO];
        [addSelectedTrackRecorder setHidden:NO];
        [shortcutsDescription setHidden:NO];
        
        [growlNotificationsSection setHidden:YES];
        [notificationsIntroduction setHidden:YES];
        [trackChangeNotification setHidden:YES];
        [trackAdditionNotification setHidden:YES];
        [shuffleNotification setHidden:YES];
    }
    else if (sender == notificationsTab)
    {
        [behaviorSection setHidden:YES];
        [bowtieIntegrationSection setHidden:YES];
        [closeMainWindowOnEscape setHidden:YES];
        [enableBowtie setHidden:YES];
        [fontSizeSelector setHidden:YES];
        [generalDescription setHidden:YES];
        [hideOnDeactivate setHidden:YES];
        [appearanceSection setHidden:YES];
        [launchOnLogin setHidden:YES];
        [launchiTunesWhenNecessary setHidden:YES];
        [listText setHidden:YES];
        [relaunchesNextInfo setHidden:YES];
        [showDockIcon setHidden:YES];
        [showMenubarIcon setHidden:YES];
        
        [globalKeyboardShortcutsSection setHidden:YES];
        [showNextLabel setHidden:YES];
        [showNextRecorder setHidden:YES];
        [nextTrackLabel setHidden:YES];
        [nextTrackRecorder setHidden:YES];
        [shuffleOnOffLabel setHidden:YES];
        [shuffleOnOffRecorder setHidden:YES];
        [addSelectedTrackLabel setHidden:YES];
        [addSelectedTrackRecorder setHidden:YES];
        [shortcutsDescription setHidden:YES];
        
        [growlNotificationsSection setHidden:NO];
        [notificationsIntroduction setHidden:NO];
        [trackChangeNotification setHidden:NO];
        [trackAdditionNotification setHidden:NO];
        [shuffleNotification setHidden:NO];
    }
    
    [self resizeWindowAccordingly];
}
- (IBAction)checkBoxValueChanged:(id)sender {
    if (sender == launchOnLogin)
    {
        if ([sender state] && ![LoginItem loginItemExists])
        {
            [LoginItem addLoginItem];
        }
        else if (![sender state] && [LoginItem loginItemExists])
        {
            [LoginItem removeLoginItem];
        }
    }
    else if (sender == hideOnDeactivate)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"hideOnDeactivate"];
        
        if (!([[NSAPP_DELEGATE mWindow] styleMask] & NSFullScreenWindowMask))
            [[NSAPP_DELEGATE mWindow] setHidesOnDeactivate:[sender state]];
    }
    else if (sender == showDockIcon)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"showDockIcon"];
        if ([sender state])
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        else
            [NSAPP_DELEGATE restartApp];
    }
    else if (sender == showMenubarIcon)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"showMenubarIcon"];
        if ([sender state])
            [NSAPP_DELEGATE showMenubarIcon];
        else
            [NSAPP_DELEGATE hideMenubarIcon];
    }
    else if (sender == enableBowtie)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"enableBowtie"];
        
        if ([sender state])
            [[NSAPP_DELEGATE bowtie] startModule];
        else
            [[NSAPP_DELEGATE bowtie] stopModule];
    }
    else if (sender == trackChangeNotification)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"trackChangeNotification"];
    }
    else if (sender == trackAdditionNotification)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"trackAdditionNotification"];

    }
    else if (sender == shuffleNotification)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"shuffleNotification"];
    }
    else if (sender == fontSizeSelector)
    {
        [UserDefaults saveToUserDefaults:[fontSizeSelector indexOfSelectedItem] == 0 ? 12:13 forKey:@"fontSize"];
        [[NSAPP_DELEGATE mwc] changeTextSize];
    }
    else if (sender == launchiTunesWhenNecessary)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"launchiTunes"];
    }
    else if (sender == closeMainWindowOnEscape)
    {
        [UserDefaults saveBoolToUserDefaults:[sender state] forKey:@"closeWindowOnEscape"];
        [[NSAPP_DELEGATE mWindow] setCloseWindowOnEscape:[sender state]];
    }
}

- (void)awakeFromNib {
    [NSAPP_DELEGATE setPWindow:preferencesWindow];
    
    [preferencesWindow setShowsResizeIndicator:NO];
    
    [shortcutsTab setImage:[NSImage imageNamed:@"Shortcuts.icns"]];
    [notificationsTab setImage:[NSImage imageNamed:@"Notifications.icns"]];
    [[preferencesWindow toolbar] setSelectedItemIdentifier:[generalTab itemIdentifier]];
    [self changeTab:generalTab];
    
    NSFont* boldLucidaGrande = [NSFont fontWithName:@"LucidaGrande-Bold" size:13];
    [behaviorSection setFont:boldLucidaGrande];
    [appearanceSection setFont:boldLucidaGrande];
    [bowtieIntegrationSection setFont:boldLucidaGrande];
    [globalKeyboardShortcutsSection setFont:boldLucidaGrande];
    [growlNotificationsSection setFont:boldLucidaGrande];
    
    // Giving a menu to the font size selector
    NSMenu* fontSize = [[NSMenu alloc] initWithTitle:@""];
    [fontSize addItemWithTitle:NSLocalizedString(@"Small", @"Font size: Small") action:nil keyEquivalent:@""];
    [fontSize addItemWithTitle:NSLocalizedString(@"Large", @"Font size: Large") action:nil keyEquivalent:@""];
    [fontSizeSelector setMenu:fontSize];
    
    [self initializeWithValues];
    
    // Don't feel like messing up with IB, added actions through code
    [launchOnLogin setAction:@selector(checkBoxValueChanged:)];
    [launchiTunesWhenNecessary setAction:@selector(checkBoxValueChanged:)];
    [hideOnDeactivate setAction:@selector(checkBoxValueChanged:)];
    [showDockIcon setAction:@selector(checkBoxValueChanged:)];
    [showMenubarIcon setAction:@selector(checkBoxValueChanged:)];
    [enableBowtie setAction:@selector(checkBoxValueChanged:)];
    [trackChangeNotification setAction:@selector(checkBoxValueChanged:)];
    [trackAdditionNotification setAction:@selector(checkBoxValueChanged:)];
    [shuffleNotification setAction:@selector(checkBoxValueChanged:)];
    [fontSizeSelector setAction:@selector(checkBoxValueChanged:)];
    [closeMainWindowOnEscape setAction:@selector(checkBoxValueChanged:)];
    
    [preferencesWindow center];
    [preferencesWindow makeKeyAndOrderFront:self];
}

- (void)initializeWithValues {
    [launchOnLogin setState:[LoginItem loginItemExists]];
    [launchiTunesWhenNecessary setState:[UserDefaults retrieveBoolFromUserDefaults:@"launchiTunes"]];
    [closeMainWindowOnEscape setState:[UserDefaults retrieveBoolFromUserDefaults:@"closeWindowOnEscape"]];
    [hideOnDeactivate setState:[UserDefaults retrieveBoolFromUserDefaults:@"hideOnDeactivate"]];
    [showDockIcon setState:[UserDefaults retrieveBoolFromUserDefaults:@"showDockIcon"]];
    [showMenubarIcon setState:[UserDefaults retrieveBoolFromUserDefaults:@"showMenubarIcon"]];
    
    if (![BowtieModule canBeEnabled]) {
        [enableBowtie setState:NO];
        [enableBowtie setEnabled:NO];
    }
    else
        [enableBowtie setState:[UserDefaults retrieveBoolFromUserDefaults:@"enableBowtie"]];
    
    [trackChangeNotification setState:[UserDefaults retrieveBoolFromUserDefaults:@"trackChangeNotification"]];
    [trackAdditionNotification setState:[UserDefaults retrieveBoolFromUserDefaults:@"trackAdditionNotification"]];
    [shuffleNotification setState:[UserDefaults retrieveBoolFromUserDefaults:@"shuffleNotification"]];
    
    if ([[UserDefaults retrieveFromUserDefaults:@"fontSize"] floatValue] > 12)
        [fontSizeSelector selectItemAtIndex:1];
    else
        [fontSizeSelector selectItemAtIndex:0];

    // ShortcutRecorder, uh...
    [showNextRecorder setAutosaveName:@"showNextHotkey"];
    [nextTrackRecorder setAutosaveName:@"nextTrackHotkey"];
    [shuffleOnOffRecorder setAutosaveName:@"shuffleOnOffHotkey"];
    [addSelectedTrackRecorder setAutosaveName:@"addSelectedTrackHotkey"];
    
    NSArray* shortcuts = [NSArray arrayWithObjects:showNextRecorder, nextTrackRecorder, shuffleOnOffRecorder, addSelectedTrackRecorder, nil];

    KeyCombo keyCombo;
    NSDictionary* dict;
    for (int i=0; i<4; i++) {
        keyCombo.flags = 0;
        keyCombo.code = -1;
        
        if ((dict = [UserDefaults retrieveHotKeyFromUserDefaults:[[shortcuts objectAtIndex:i] autosaveName]])) {
            keyCombo.flags = [[dict objectForKey:@"modifierFlags"] unsignedIntValue];
            keyCombo.code = [[dict objectForKey:@"keyCode"] shortValue];
        }
        
        [[shortcuts objectAtIndex:i] setKeyCombo:keyCombo];
        [[shortcuts objectAtIndex:i] setDelegate:[NSAPP_DELEGATE shortcutRecorder]];
    }
}

- (void)windowWillClose:(NSNotification*)aNotification {
    [[preferencesWindow toolbar] setSelectedItemIdentifier:@""];
    [NSAPP_DELEGATE setPWindow:nil];
}

@end
