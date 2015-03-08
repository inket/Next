//
//  Library.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/12/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "Library.h"
#import "NextAppDelegate.h"

@implementation Library

@synthesize playlists;
@synthesize playlistNames;
@synthesize selectedPlaylist;
@synthesize allTracks;
@synthesize allTracksLocations;
@synthesize selectedPlaylistArray;
@synthesize searchString;
@synthesize searchBounds;

- (void)setSearchString:(NSString *)theString justARefresh:(BOOL)refresh {
    if (!refresh) { // Don't free the searchString if it's the passed parameter; We just want to refresh the results
        searchString = [theString copy];
    }
    
    NSMutableArray* searchResultTwo = [[NSMutableArray alloc] init];
    
    NSMutableArray* words = [NSMutableArray arrayWithArray:[searchString componentsSeparatedByString:@" "]];
    
    for (int i=0; i<[words count]; i++)
        if ([[words objectAtIndex:i] isEqualToString:@" "] || [[words objectAtIndex:i] isEqualToString:@""])
        {
            [words removeObjectAtIndex:i];
            i--;
        }
        
    for (NSDictionary* track in selectedPlaylistArray) {
        NSUInteger found = [words count];
        
        for (NSString* part in words) {
            if (!searchBounds)
            {
                BOOL foundInName = ([[track objectForKey:@"Name"] rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound
                                    && [track objectForKey:@"Name"]);
                BOOL foundInArtist = ([[track objectForKey:@"Artist"] rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound
                                      && [track objectForKey:@"Artist"]);
                BOOL foundInAlbum = ([[track objectForKey:@"Album"] rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound
                                     && [track objectForKey:@"Album"]);
                BOOL foundInAlbumArtist = ([[track objectForKey:@"Album Artist"] rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound && [track objectForKey:@"Album Artist"]);
                
                if (foundInName || foundInArtist || foundInAlbum || foundInAlbumArtist)
                    found--;
            }
            else if ([track objectForKey:searchBounds])
            {
                if ([[track objectForKey:searchBounds] rangeOfString:part options:NSCaseInsensitiveSearch].location != NSNotFound)
                    found--;
            }
        }
                
        if (found == 0)
            [searchResultTwo addObject:track];
    }

    searchResult = searchResultTwo;
    
    [[[NSAPP_DELEGATE mwc] playlistTableView] reloadData];
}

- (void)setSelectedPlaylist:(NSString *)theSelectedPlaylist {
    if (selectedPlaylist != theSelectedPlaylist) {
        selectedPlaylist = nil;
        searchString = nil;
    }
    
    BOOL found = NO;
    for (NSString* name in playlistNames) {
        if ([name isEqualToString:theSelectedPlaylist]) {
            selectedPlaylist = [theSelectedPlaylist copy];
            found = YES; break;
        }
    }
    
    if (!found) {
        selectedPlaylist = [playlistNames objectAtIndex:0];
    }
    
    selectedPlaylistArray = [NSMutableArray array];
    for (NSDictionary* track in [playlists objectForKey:selectedPlaylist]) {
        if ([allTracks objectForKey:[[track objectForKey:@"Track ID"] stringValue]]) {
            [selectedPlaylistArray addObject:[allTracks objectForKey:[[track objectForKey:@"Track ID"] stringValue]]];
        }
    }
}

- (void)refreshPlaylist {
    BOOL found = NO;
    for (NSString* name in playlistNames) {
        if ([name isEqualToString:selectedPlaylist]) {
            found = YES; break;
        }
    }
    
    if (!found) {
        selectedPlaylist = [playlistNames objectAtIndex:0];
    }
    
    selectedPlaylistArray = [NSMutableArray array];
    for (NSDictionary* track in [playlists objectForKey:selectedPlaylist]) {
        if ([allTracks objectForKey:[[track objectForKey:@"Track ID"] stringValue]]) {
            [selectedPlaylistArray addObject:[allTracks objectForKey:[[track objectForKey:@"Track ID"] stringValue]]];
        }
    }
}

- (NSInteger)numberOfTracksInSelectedPlaylist {
    if ((searchString != nil) && (![searchString isEqualToString:@""])) {
        return [searchResult count];
    }
    else
    {
        return [selectedPlaylistArray count];
    }
}

- (NSArray*)selectedPlaylistArray {
    if (searchString != nil && ![searchString isEqualToString:@""])
        return searchResult;
    else
        return selectedPlaylistArray;
}

- (void)sortSelectedPlaylist:(NSString*)field order:(BOOL)order {
    lastSortField = field;
    lastSortOrder = order;
    NSMutableArray* arraysToSort = [NSMutableArray arrayWithObject:selectedPlaylistArray];
    if ((searchString != nil) && (![searchString isEqualToString:@""]))
        [arraysToSort addObject:searchResult];
    
    for (NSMutableArray* array in arraysToSort) {
        [array sortUsingComparator:^(id obj1, id obj2){
            if (!order)
                if ([obj1 objectForKey:field] && [obj2 objectForKey:field])
                    return (NSComparisonResult)[[obj1 objectForKey:field] compare:[obj2 objectForKey:field] options:NSCaseInsensitiveSearch];
                else if ([obj1 objectForKey:field] && ![obj2 objectForKey:field])
                    return (NSComparisonResult)NSOrderedAscending;
                else if (![obj1 objectForKey:field] && [obj2 objectForKey:field])
                    return (NSComparisonResult)NSOrderedDescending;
                else
                    return (NSComparisonResult)NSOrderedSame;
                else
                    if ([obj1 objectForKey:field] && [obj2 objectForKey:field])
                        return (NSComparisonResult)[[obj2 objectForKey:field] compare:[obj1 objectForKey:field] options:NSCaseInsensitiveSearch];
                    else if ([obj1 objectForKey:field] && ![obj2 objectForKey:field])
                        return (NSComparisonResult)NSOrderedDescending;
                    else if (![obj1 objectForKey:field] && [obj2 objectForKey:field])
                        return (NSComparisonResult)NSOrderedAscending;
                    else
                        return (NSComparisonResult)NSOrderedSame;
        }];
    }
}

- (void)recreateLibrary
{
    @autoreleasepool {
        /* Load and parse iTunes public Library */
        NSDictionary *library = [NSDictionary dictionaryWithContentsOfFile:libraryFile];
        
        allTracks = [library objectForKey:@"Tracks"];
        allTracksLocations = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary* track in [allTracks objectEnumerator]) {
            if (![track objectForKey:@"Has Video"] && [track objectForKey:@"Location"])
                [allTracksLocations setObject:[track objectForKey:@"Track ID"] forKey:[track objectForKey:@"Location"]];
        }
        
        /* Playlists - Skip Library, and Specials */
        NSEnumerator *allPlaylistsEnum = [[library objectForKey:@"Playlists"] objectEnumerator];
        
        
        playlistNames = [[NSMutableArray alloc] init];
        
        
        playlists = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *playlist in allPlaylistsEnum)
        {
            if ([[playlist objectForKey:@"Distinguished Kind"] intValue] == 4 || [[playlist objectForKey:@"Distinguished Kind"] intValue] == 10 || (![playlist objectForKey:@"Distinguished Kind"] && ![playlist objectForKey:@"Master"]))
            {
                [playlistNames addObject:[playlist objectForKey:@"Name"]];
                if ([playlist objectForKey:@"Playlist Items"] != nil) {
                    [playlists setObject:[playlist objectForKey:@"Playlist Items"] forKey:[playlist objectForKey:@"Name"]];
                }
                else
                    [playlists setObject:[NSDictionary dictionary] forKey:[playlist objectForKey:@"Name"]];
            }
        }
        
        [[NSAPP_DELEGATE mwc] libraryLoaded];
    }
}

- (void)updateLibrary {
    NSDictionary *library = [NSDictionary dictionaryWithContentsOfFile:libraryFile];
    
    allTracks = [library objectForKey:@"Tracks"];
    
    NSEnumerator *allPlaylistsEnum = [[library objectForKey:@"Playlists"] objectEnumerator];
    
    
    NSMutableArray* playlistNamesTemp = [[NSMutableArray alloc] init];
    
    NSMutableDictionary* playlistsTemp = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *playlist in allPlaylistsEnum)
    {
        if ([[playlist objectForKey:@"Distinguished Kind"] intValue] == 4 || [[playlist objectForKey:@"Distinguished Kind"] intValue] == 10 || (![playlist objectForKey:@"Distinguished Kind"] && ![playlist objectForKey:@"Master"]))
        {
            [playlistNamesTemp addObject:[playlist objectForKey:@"Name"]];
            if ([playlist objectForKey:@"Playlist Items"] != nil) {
                [playlistsTemp setObject:[playlist objectForKey:@"Playlist Items"] forKey:[playlist objectForKey:@"Name"]];
            }
            else
                [playlistsTemp setObject:[NSDictionary dictionary] forKey:[playlist objectForKey:@"Name"]];
        }
    }
    
    playlistNames = playlistNamesTemp;
    playlists = playlistsTemp;
    
    [self refreshPlaylist];
    [self setSearchString:searchString justARefresh:YES];
    [self sortSelectedPlaylist:lastSortField order:lastSortOrder];

    [[NSAPP_DELEGATE mwc] libraryUpdated];
}

- (NSMenu*)playlistsAsMenu {
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@"Playlists"];
    
    [menu setAutoenablesItems:NO];
    [menu setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    
    NSUInteger i = 0;
    for (NSString* title in playlistNames) {
        i++;
        [menu addItemWithTitle:title action:nil keyEquivalent:[NSString stringWithFormat:@"%ld", i]];
    }
    
    return menu;
}

- (NSDictionary*)trackDictionaryFromID:(NSString*)trackID {
    return [allTracks objectForKey:trackID];
}

- (void)load
{
    // Find & Load iTunes Library
    libraryFile = [self findLibrary];
    
    if (libraryFile)
        [self loadLibrary];
}

- (void)loadLibrary
{
    if (!libraryFile)
        return;
    
    [NSThread detachNewThreadSelector:@selector(recreateLibrary) 
                             toTarget:self
                           withObject:nil];
}

- (NSString*)findLibrary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Look For Current Database in Defaults
    NSArray *databases = [[[NSUserDefaults standardUserDefaults] 
                           persistentDomainForName:@"com.apple.iApps"]
                          objectForKey:@"iTunesRecentDatabases"];
    
    NSURL *url = [NSURL URLWithString:[databases objectAtIndex:0]];
    
    NSString* path = [url path];
    
    // Fallback on default location if not found
    if ((!path) || (![fileManager fileExistsAtPath:path]))
    {
        path = [@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath];
        
        // Check by old name if not found
        if (![fileManager fileExistsAtPath:path])
            path = [@"~/Music/iTunes/iTunes Library.xml" stringByExpandingTildeInPath];
    }
    
    // No Library Found! This should not happen
    if (![fileManager fileExistsAtPath:path])
    {
        NSLog(@"Couldn't find Library file.");
        [NSApp terminate:self];
    }
    else
    {
        NSLog(@"Library found: %@", path);
    }
    
    return path;
}

- (id)init
{
    self = [super init];
    if (self) {
        searchResult = [[NSMutableArray alloc] init];
        searchString = [[NSString alloc] init];
        searchBounds = nil;
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(updateLibrary)
                                                                name:@"com.apple.iTunes.sourceSaved"
                                                              object:@"com.apple.iTunes.sources"];
    }
    
    return self;
}

- (void)dealloc
{
    searchResult = nil;
    searchString = nil;
}

@end
