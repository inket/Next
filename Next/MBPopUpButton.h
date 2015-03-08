//
//  MBPopUpButton.h
//  Next
//
//  Created by Mahdi Bchetnia on 24/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MBPopUpButtonDelegate.h"

@interface MBPopUpButton : NSButton {
    NSMenu* menu;
    id <MBPopUpButtonDelegate> delegate;
}

@property (strong) id <MBPopUpButtonDelegate> delegate;

@property (retain) NSMenu* menu;

- (NSMenuItem*)itemWithTitle:(NSString*)title;

- (void)selectItemWithTitle:(NSString*)title;

- (void)selectItemAtIndex:(NSInteger)idx;

- (void)selectItem:(NSMenuItem*)item;

- (NSMenuItem*)selectedItem;

- (NSString*)titleOfSelectedItem;

- (void)theAction;

@end
