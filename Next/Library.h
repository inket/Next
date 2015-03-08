//
//  Library.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/12/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Library : NSObject {
@private
    NSString *libraryFile;
    NSMutableArray* playlistNames;
    NSMutableDictionary* playlists;
    NSString* selectedPlaylist;
    NSDictionary* allTracks;
    NSMutableDictionary* allTracksLocations;
    
    NSMutableArray* selectedPlaylistArray;
    
    NSString* searchString;
    NSMutableArray* searchResult;
    
    NSString* lastSortField;
    BOOL lastSortOrder;
}

@property (nonatomic, readonly) NSMutableArray* playlistNames;
@property (nonatomic, readwrite, strong) NSString* selectedPlaylist;
@property (nonatomic, readonly) NSMutableDictionary* playlists;
@property (nonatomic, readonly) NSDictionary* allTracks;
@property (nonatomic, readonly) NSMutableDictionary* allTracksLocations;
@property (nonatomic, readwrite, strong) NSMutableArray* selectedPlaylistArray;
@property (nonatomic, readwrite, strong) NSString* searchString;
@property (nonatomic, readwrite, strong) NSString* searchBounds;

- (NSString*)findLibrary;
- (void)loadLibrary;
- (void)load;

- (void)setSearchString:(NSString*)theString justARefresh:(BOOL)refresh;
- (NSMenu*)playlistsAsMenu;
- (NSInteger)numberOfTracksInSelectedPlaylist;
- (void)sortSelectedPlaylist:(NSString*)field order:(BOOL)order;

- (NSDictionary*)trackDictionaryFromID:(NSString*)trackID;

@end
