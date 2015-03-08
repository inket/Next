//
//  SRDelegate.h
//  Next
//
//  Created by Mahdi Bchetnia on 2/9/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRRecorderControl.h"

@interface SRDelegate : NSObject {
	EventHotKeyRef showNextHotkeyRef;
    EventHotKeyRef nextTrackHotkeyRef;
	EventHotKeyRef shuffleOnOffHotkeyRef;
	EventHotKeyRef addSelectedTrackHotkeyRef;
}

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);
- (void)registerGlobalHotKey:(NSString*)name withDictionary:(NSDictionary*)dict;
- (void)registerGlobalHotKey:(NSString*)name withFlags:(unsigned int)flags code:(short)code recorder:(SRRecorderControl*)aRecorder;
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(signed short)keyCode andFlagsTaken:(unsigned int)flags reason:(NSString **)aReason;
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo;

@end
