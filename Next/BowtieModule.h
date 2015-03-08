//
//  BowtieModule.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/17/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BowtieModule : NSObject {
@private
    BOOL isEnabled;
    NSString* jsFilePath;
}

@property (nonatomic, assign) BOOL isEnabled;

// Class methods
+ (BOOL)canBeEnabled;

// Instance methods
// Called from outside
- (BOOL)startModule;
- (void)stopModule;

// Called from inside
- (void)writeJSFile:(NSNotification*)notification;
+ (BOOL)selectedThemeIsNextEnabled;

@end
