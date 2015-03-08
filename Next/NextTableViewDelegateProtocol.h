//
//  NextTableViewDelegateProtocol.h
//  Next
//
//  Created by Mahdi Bchetnia on 5/13/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NextTableViewDelegateProtocol <NSObject>
@optional
- (id)playlistTableView;
- (id)queueTableView;
- (id)mainWindow;
- (IBAction)removeSelectedTracks:(id)sender;
@end
