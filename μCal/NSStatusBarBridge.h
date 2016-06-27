//
//  NSStatusBar.h
//  μCal
//
//  Created by Jeff Chen on 6/27/16.
//  Copyright © 2016 Jeff Chen. All rights reserved.
//

#ifndef NSStatusBar_h
#define NSStatusBar_h

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, NSStatusBarItemPriority) {
    NSStatusBarItemPriorityDefault = 1000,
    NSStatusBarItemPrioritySystem = 2147483645,
    NSStatusBarItemPrioritySpotlight = 2147483646,
    NSStatusBarItemPriorityNotificationCenter = 2147483647,
};

typedef NS_ENUM(NSInteger, NSStatusBarItemOrderingMode) {
    NSStatusBarItemOrderingModeBefore = -1,
    NSStatusBarItemOrderingModeAfter = 0,
};

@interface NSStatusBar (Private)
- (NSStatusItem *)statusItemWithLength:(CGFloat)length positioned:(NSStatusBarItemOrderingMode)orderingMode relativeTo:(NSStatusBarItemPriority)priority;
- (NSStatusItem *)statusItemWithLength:(CGFloat)length priority:(NSStatusBarItemPriority)priority;
@end



#endif /* NSStatusBar_h */
