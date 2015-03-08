//
//  UserDefaults.h
//  Next
//
//  Created by Mahdi Bchetnia on 2/9/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UserDefaults : NSObject {

}

+ (void)saveToUserDefaults:(float)value forKey:(NSString*)key;
+ (NSNumber*)retrieveFromUserDefaults:(NSString*)key;

+ (void)removeFromUserDefaults:(NSString*)key;

+ (void)saveBoolToUserDefaults:(BOOL)value forKey:(NSString*)key;
+ (BOOL)retrieveBoolFromUserDefaults:(NSString*)key;

+ (NSDictionary*)retrieveHotKeyFromUserDefaults:(NSString*)hotkey;

+ (void)saveStringToUserDefaults:(NSString*)value forKey:(NSString*)key;
+ (NSString*)retrieveStringFromUserDefaults:(NSString*)key;

+ (void)setObject:(id)obj forKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key;

@end
