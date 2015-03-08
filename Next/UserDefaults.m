//
//  UserDefaults.m
//  Next
//
//  Created by Mahdi Bchetnia on 2/9/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

+ (void)saveToUserDefaults:(float)value forKey:(NSString*)key {
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:[NSNumber numberWithFloat:value] forKey:key];
		[standardUserDefaults synchronize];
	}
	
}

+ (NSNumber*)retrieveFromUserDefaults:(NSString*)key {
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSNumber *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:key];
	
	return val;
	
}

+ (void)removeFromUserDefaults:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

+ (void)saveBoolToUserDefaults:(BOOL)value forKey:(NSString*)key {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setBool:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

+ (BOOL)retrieveBoolFromUserDefaults:(NSString*)key {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	BOOL val = NO;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults boolForKey:key];
	
	return val;
}

+ (NSDictionary*)retrieveHotKeyFromUserDefaults:(NSString*)hotkey {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"ShortcutRecorder %@", hotkey]];
    
    return val;
}

+ (void)saveStringToUserDefaults:(NSString*)value forKey:(NSString*)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

+ (NSString*)retrieveStringFromUserDefaults:(NSString*)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString* val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:key];
	
    if (![val isKindOfClass:[NSString class]]) return @"";
	return val;
}

+ (void)setObject:(id)obj forKey:(NSString*)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:obj forKey:key];
		[standardUserDefaults synchronize];
	}
}

+ (id)objectForKey:(NSString*)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	id val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:key];
	
	return val;
}

@end
