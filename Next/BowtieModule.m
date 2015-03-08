//
//  BowtieModule.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/17/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "BowtieModule.h"


@implementation BowtieModule

@synthesize isEnabled;

+ (BOOL)canBeEnabled {
    BOOL isDir;
    
    if ([[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.13bold.Bowtie"]
        && [[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Bowtie" stringByExpandingTildeInPath] isDirectory:&isDir] && isDir && [BowtieModule selectedThemeIsNextEnabled]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)startModule {
    if ([BowtieModule canBeEnabled]) {
        isEnabled = YES;
        return YES;
    }
    
    return NO;
}

- (void)stopModule {
    [self writeJSFile:[NSNotification notificationWithName:@"" object:nil]];
    isEnabled = NO;
}

- (void)writeJSFile:(NSNotification*)notification {
    if (isEnabled)
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Next" stringByExpandingTildeInPath]])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Application Support/Next" stringByExpandingTildeInPath] withIntermediateDirectories:NO attributes:nil error:nil];
        }
            
        NSString* newFile;
        
        if ([[[notification userInfo] objectForKey:@"track"] objectForKey:@"Name"])
        {
            NSString* artist = ([[[notification userInfo] objectForKey:@"track"] objectForKey:@"Artist"])?[[[notification userInfo] objectForKey:@"track"] objectForKey:@"Artist"]:@"";
            
            NSString* name = ([[[notification userInfo] objectForKey:@"track"] objectForKey:@"Name"])?[[[notification userInfo] objectForKey:@"track"] objectForKey:@"Name"]:@"";
            
            NSString* album = ([[[notification userInfo] objectForKey:@"track"] objectForKey:@"Album"])?[[[notification userInfo] objectForKey:@"track"] objectForKey:@"Album"]:@"";
            
            // Escaping the character '
            artist = [artist stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            album = [album stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            
            newFile = [NSString stringWithFormat:
                       @"showNext();document.getElementById('nextArtist').innerHTML = '%@';document.getElementById('nextTitle').innerHTML = '%@';document.getElementById('nextAlbum').innerHTML = '%@';",
                       artist,
                       name,
                       album
                       ];
        }
        else
        {
            newFile = [NSString stringWithFormat:@"hideNext();"];
        }
    
        [newFile writeToFile:jsFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (NSDictionary*)themesList {
    NSString* pathToThemesFolder = [@"~/Library/Application Support/Bowtie/" stringByExpandingTildeInPath];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/find"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: pathToThemesFolder, @"-iname", @"info.plist", nil];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSArray* lines = [string componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    NSMutableDictionary* list = [NSMutableDictionary dictionary];
    
    for (NSString* line in lines) {
        if ([[NSDictionary dictionaryWithContentsOfFile:line] objectForKey:@"BTThemeIdentifier"]) {
            [list setObject:line forKey:[[NSDictionary dictionaryWithContentsOfFile:line] objectForKey:@"BTThemeIdentifier"]];
        }
    }
    
    return list;
}

+ (NSString*)pathToSelectedTheme {
    NSString* selectedThemeBundleIdentifier = [[NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.13bold.Bowtie.plist" stringByExpandingTildeInPath]] objectForKey:@"selectedTheme"];
    
    NSDictionary* themesList = [self themesList];
    
    return [NSString stringWithFormat:@"%@/", [[themesList objectForKey:selectedThemeBundleIdentifier] stringByDeletingLastPathComponent]];
}

+ (BOOL)selectedThemeIsNextEnabled {
    NSString* path = [self pathToSelectedTheme];
    NSString* infoPath = [NSString stringWithFormat:@"%@Info.plist", path];
    
    NSString* mainFilePath = [NSString stringWithFormat:@"%@%@", path, [[NSDictionary dictionaryWithContentsOfFile:infoPath] objectForKey:@"BTMainFile"]];
    NSString* mainFile = [NSString stringWithContentsOfFile:mainFilePath encoding:NSUTF8StringEncoding error:nil];
        
    if (mainFile == nil) {
        return NO;
    }

    if ([mainFile rangeOfString:@"<!-- enable next -->" options:NSCaseInsensitiveSearch].location != NSNotFound
        || [mainFile rangeOfString:@"<!-- enable next-->" options:NSCaseInsensitiveSearch].location != NSNotFound
        || [mainFile rangeOfString:@"<!--enable next-->" options:NSCaseInsensitiveSearch].location != NSNotFound
        || [mainFile rangeOfString:@"<!--enable next -->" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        isEnabled = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeJSFile:) name:@"updateBowtie" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopModule) name:@"willTerminate" object:nil];
        jsFilePath = [@"~/Library/Application Support/Next/bowtie.js" stringByExpandingTildeInPath];
    }
    
    return self;
}

@end
