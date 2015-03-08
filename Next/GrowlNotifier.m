//
//  GrowlNotifier.m
//  Next
//
//  Created by Mahdi Bchetnia on 4/10/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "GrowlNotifier.h"


@implementation GrowlNotifier

- (NSDictionary*)registrationDictionaryForGrowl {
    NSArray* notifications = [NSArray arrayWithObjects:@"Track Change Notification", @"Track Added to the Queue", @"Shuffle Status Change", nil];
    NSDictionary* growl = [NSDictionary dictionaryWithObjectsAndKeys:notifications, GROWL_NOTIFICATIONS_ALL, notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return growl;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
