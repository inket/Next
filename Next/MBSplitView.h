//
//  MBSplitView.h
//  Next
//
//  Created by Mahdi Bchetnia on 3/29/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDefaults.h"

@interface MBSplitView : NSSplitView <NSSplitViewDelegate> {
@private
    BOOL collapsed;
    BOOL preFullScreenCollapseStatus;
    BOOL isAnimating;
    CGFloat oldRightWidth;
    int animations;
}

@property (nonatomic, readwrite, assign) BOOL collapsed;
@property (readonly) BOOL preFullScreenCollapseStatus;

- (void)collapse;

@end
