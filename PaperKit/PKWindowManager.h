//
//  PKWindowManager.h
//  Pods
//
//  Created by Norikazu on 2015/07/05.
//
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>
#import "PKWindow.h"

typedef NS_ENUM(NSInteger, PKWindowManagerStatus) {
    PKWindowManagerStatusDefault = 0,
    PKWindowManagerStatusNothing,
    PKWindowManagerStatusList,
    PKWindowManagerStatusSingleWindowOpen,
    PKWindowManagerStatusMultipleWindowOpen,
    PKWindowManagerStatusDismiss
};

@interface PKWindowManager : NSObject <PKWindowDelegate>

@property (nonatomic, readonly) PKWindowManagerStatus status;
@property (nonatomic, readonly, weak) UIWindow *baseWindow;
@property (nonatomic, readonly) NSArray <PKWindow *>*windows;

// Multiwindow status
@property (nonatomic, readonly, getter=isSingleWindow)  BOOL singleWindow;
@property (nonatomic, readonly, getter=isLinking)       BOOL linking;
@property (nonatomic, readonly, getter=isStacking)      BOOL stacking;

// Gesture status
@property (nonatomic, readonly, getter=isTracking)      BOOL tracking;
@property (nonatomic, readonly, getter=isDragging)      BOOL dragging;
@property (nonatomic, readonly, getter=isDecelerating)  BOOL decelerating;
@property (nonatomic, readonly, getter=isTouchingTopWindow) BOOL touchingTopWindow;

+ (instancetype)sharedManager;
+ (PKWindowManager *)managerWithBaseWindow:(UIWindow *)window;

// Util
- (NSInteger)numberOfWindowsInManager;
- (NSInteger)indexOfWindow:(PKWindow *)window;
- (PKWindow *)windowForIndex:(NSInteger)index;
- (PKWindow *)topWindow;

// Add window
- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController;
- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated;

// Control
- (void)open;
- (void)close;

// Dismis window
- (void)dismissWindow:(PKWindow *)window;

@end