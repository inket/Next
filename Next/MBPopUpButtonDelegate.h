//
//  MBPopUpButtonDelegate.h
//  Next
//
//  Created by Mahdi Bchetnia on 27/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBPopUpButtonDelegate <NSObject>
@optional
- (void)menuItemAction:(id)sender;
@end
