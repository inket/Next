//
//  NextQueueDelegateProtocol.h
//  Next
//
//  Created by Mahdi Bchetnia on 4/6/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Library.h"

@protocol NextQueueDelegateProtocol <NSObject>
@optional

- (id)delegate;
- (Library*)library;

@end
