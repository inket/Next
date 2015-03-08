//
//  MBPopUpButton.m
//  Next
//
//  Created by Mahdi Bchetnia on 24/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MBPopUpButton.h"

@interface MBPopUpButton(Private)
- (void)deselectAllItems;
@end

@implementation MBPopUpButton

@synthesize menu;
@synthesize delegate;

- (id)init {
    self = [super init];
    
    if (self)
    {
        menu = nil;
    }
    
    return self;
}

- (void)theAction {
    for (NSMenuItem* item in [menu itemArray]) {
        [item setAction:@selector(menuItemAction:)];
        [item setTarget:delegate];
    }
        
    NSPoint location = NSMakePoint([self frame].origin.x, [self frame].origin.y+[self frame].size.height);
    [menu popUpMenuPositioningItem:[self selectedItem] atLocation:location inView:[[[self window] contentView] superview]];
}

- (NSMenuItem*)itemWithTitle:(NSString*)title {
    return [menu itemWithTitle:title];
}

- (void)selectItemWithTitle:(NSString*)title {
    [self deselectAllItems];
    
    [[self itemWithTitle:title] setState:NSOnState];
    [self setTitle:[self titleOfSelectedItem]];
}

- (void)selectItemAtIndex:(NSInteger)idx {
    [self deselectAllItems];
    
    [[menu itemAtIndex:idx] setState:NSOnState];
    [self setTitle:[[menu itemAtIndex:idx] title]];
}

- (void)selectItem:(NSMenuItem*)item {
    [self deselectAllItems];
    
    [item setState:NSOnState];
    [self setTitle:[item title]];
}
   
- (void)deselectAllItems {
    for (NSMenuItem* item in [menu itemArray]) {
        [item setState:NSOffState];
    }
}

- (NSMenuItem*)selectedItem {
    for (NSMenuItem* item in [menu itemArray]) {
        if ([item state] == NSOnState)
            return item;
    }
    
    return nil;
}

- (NSString*)titleOfSelectedItem {
    for (NSMenuItem* item in [menu itemArray]) {
        if ([item state] == NSOnState)
            return [item title];
    }
    
    return nil;
}


@end














