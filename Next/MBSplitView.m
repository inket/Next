//
//  MBSplitView.m
//  Next
//
//  Created by Mahdi Bchetnia on 3/29/11.
//  Copyright 2011 Mahdi Bchetnia. All rights reserved.
//

#import "MBSplitView.h"
#import "NextAppDelegate.h"

@implementation MBSplitView

@synthesize collapsed;
@synthesize preFullScreenCollapseStatus;

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCollapseStatus) name:@"willTerminate" object:nil];
    
    collapsed = [UserDefaults retrieveBoolFromUserDefaults:@"queueCollapsed"];
    if (collapsed && [UserDefaults retrieveFromUserDefaults:@"oldQueueWidth"])
        oldRightWidth = [[UserDefaults retrieveFromUserDefaults:@"oldQueueWidth"] floatValue];
    else
        oldRightWidth = 0;

    isAnimating = NO;
    animations = 0;
}

- (NSColor*)dividerColor {
    return [NSColor colorWithDeviceRed:0.26 green:0.26 blue:0.26 alpha:1];
    //return [NSColor colorWithDeviceRed:0.38 green:0.38 blue:0.38 alpha:1];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat fullWidth = [splitView frame].size.width;
    
    if (collapsed)
        return fullWidth;
    else
        return fullWidth/3;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat fullWidth = [splitView frame].size.width;
    
    if (collapsed)
        return fullWidth;
    else
        return fullWidth-(fullWidth/3);
}

- (void)collapse {
    NSView* rightSubview = [[self subviews] objectAtIndex:1];
    NSView* leftSubview = [[self subviews] objectAtIndex:0];

    if (!collapsed && !isAnimating)
        oldRightWidth = [rightSubview frame].size.width / [self frame].size.width;
    
    collapsed = !collapsed;
    
    if (!([[NSAPP_DELEGATE mWindow] styleMask] & NSFullScreenWindowMask))
        preFullScreenCollapseStatus = collapsed;
    
    NSSize newSize = [rightSubview frame].size;
    
    if (collapsed)
    {
        newSize.width = 0;
        [[rightSubview animator] setFrameSize:newSize];
    }
    else
    {
        newSize.width = [self frame].size.width * oldRightWidth;
        [[rightSubview animator] setFrameSize:newSize];
        
        NSSize newLeftieSize = [leftSubview frame].size;
        newLeftieSize.width = [self frame].size.width - newSize.width;
        
        [[leftSubview animator] setFrameSize:newLeftieSize];
    }
    
    isAnimating = YES; animations++;
    [self performSelector:@selector(animationFinished) withObject:nil afterDelay:[[NSAnimationContext currentContext] duration]+0.01];
}

- (void)animationFinished {
    if (animations == 1)
        isAnimating = NO;
    
    animations--;
}

- (void)saveCollapseStatus {
    [UserDefaults saveBoolToUserDefaults:preFullScreenCollapseStatus forKey:@"queueCollapsed"];
    [UserDefaults saveToUserDefaults:oldRightWidth forKey:@"oldQueueWidth"];
}

@end
