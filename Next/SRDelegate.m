//
//  SRDelegate.m
//  Next
//
//  Created by Mahdi Bchetnia on 2/9/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "SRDelegate.h"
#import "NextAppDelegate.h"

@implementation SRDelegate

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    //Do something once the key is pressed
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	int temphotKeyId = hotKeyID.id; //Get the id, so we can know which HotKey we are handling.
    switch(temphotKeyId){
        case 1: [NSAPP_DELEGATE applicationShouldHandleReopen:nil hasVisibleWindows:NO]; break;
        case 2: [[NSNotificationCenter defaultCenter] postNotificationName:@"nextTrack" object:nil]; break;
        case 3: [[NSNotificationCenter defaultCenter] postNotificationName:@"shuffleOnOff" object:nil]; break;
        case 4: [[[[NSAPP_DELEGATE mwc] queueTableViewController] queue] addSelectediTunesTrack]; break;
    }
	return noErr;
}

- (void)registerGlobalHotKey:(NSString*)name withDictionary:(NSDictionary*)dict {
    if (dict) {
        unsigned int flags = [[dict objectForKey:@"modifiers"] unsignedIntValue];
        short code = [[dict objectForKey:@"keyCode"] shortValue];
        
        if (flags != 0 && code != -1)
        {
            [self registerGlobalHotKey:name withFlags:flags code:code recorder:nil];
        }
    }
}

- (void)registerGlobalHotKey:(NSString*)name withFlags:(unsigned int)flags code:(short)code recorder:(SRRecorderControl*)aRecorder {
    // Register the event
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, NULL, NULL);
    
    EventHotKeyID gMyHotKeyID;
    if ([name isEqualToString:@"showNextHotkey"])
    {
        UnregisterEventHotKey(showNextHotkeyRef);
        gMyHotKeyID.signature='htk1';
        gMyHotKeyID.id=1;
        RegisterEventHotKey(code, flags, gMyHotKeyID, GetApplicationEventTarget(), 0, &showNextHotkeyRef);
    }
    else if ([name isEqualToString:@"nextTrackHotkey"])
    {
        UnregisterEventHotKey(nextTrackHotkeyRef);
        gMyHotKeyID.signature='htk2';
        gMyHotKeyID.id=2;
        RegisterEventHotKey(code, flags, gMyHotKeyID, GetApplicationEventTarget(), 0, &nextTrackHotkeyRef);
    }
    else if ([name isEqualToString:@"shuffleOnOffHotkey"])
    {
        UnregisterEventHotKey(shuffleOnOffHotkeyRef);
        gMyHotKeyID.signature='htk3';
        gMyHotKeyID.id=3;
        RegisterEventHotKey(code, flags, gMyHotKeyID, GetApplicationEventTarget(), 0, &shuffleOnOffHotkeyRef);
    }
    else if ([name isEqualToString:@"addSelectedTrackHotkey"])
    {
        UnregisterEventHotKey(addSelectedTrackHotkeyRef);
        gMyHotKeyID.signature='htk4';
        gMyHotKeyID.id=4;
        RegisterEventHotKey(code, flags, gMyHotKeyID, GetApplicationEventTarget(), 0, &addSelectedTrackHotkeyRef);
    }
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(signed short)keyCode andFlagsTaken:(unsigned int)flags reason:(NSString **)aReason {
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
	if (newKeyCombo.flags != 0 && newKeyCombo.code != -1) {
		[self registerGlobalHotKey:[aRecorder autosaveName] withFlags:(unsigned int)[aRecorder cocoaToCarbonFlags:newKeyCombo.flags] code:newKeyCombo.code recorder:aRecorder];
	}
    else if (newKeyCombo.code == -1)
    {
        NSString* name = [aRecorder autosaveName];
        
        if ([name isEqualToString:@"showNextHotkey"])
        {
            UnregisterEventHotKey(showNextHotkeyRef);
        }
        else if ([name isEqualToString:@"nextTrackHotkey"])
        {
            UnregisterEventHotKey(nextTrackHotkeyRef);
        }
        else if ([name isEqualToString:@"shuffleOnOffHotkey"])
        {
            UnregisterEventHotKey(shuffleOnOffHotkeyRef);
        }
        else if ([name isEqualToString:@"addSelectedTrackHotkey"])
        {
            UnregisterEventHotKey(addSelectedTrackHotkeyRef);
        }
    }
}

@end