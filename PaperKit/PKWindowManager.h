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
    PKWindowManagerStatusConfirm,
    PKWindowManagerStatusSingleWindowOpen,
    PKWindowManagerStatusMultipleWindowOpen,
    PKWindowManagerStatusDismiss
};

@interface PKWindowManager : NSObject <PKWindowDelegate>

@property (nonatomic) PKWindowManagerStatus status;
@property (nonatomic, readonly, weak) UIWindow *baseWindow;
@property (nonatomic, readonly) NSArray <PKWindow *>*windows;

@property(nonatomic,readonly,getter=isSingle)       BOOL single;
@property(nonatomic,readonly,getter=isLinking)      BOOL linking;
@property(nonatomic,readonly,getter=isTracking)     BOOL tracking;
@property(nonatomic,readonly,getter=isDragging)     BOOL dragging;
@property(nonatomic,readonly,getter=isDecelerating) BOOL decelerating;

+ (instancetype)sharedManager;
+ (PKWindowManager *)managerWithBaseWindow:(UIWindow *)window;

// Util
- (NSInteger)numberOfWindowsInManager;
- (NSInteger)indexOfWindow:(PKWindow *)window;
- (PKWindow *)windowForIndex:(NSInteger)index;
- (PKWindow *)topWindow;
- (PKWindowDismissTransitionStyle)topWindowDismissTranstionStyle;

// Add window
- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController;
- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated;

// Dismis window
- (void)dismissWindow:(PKWindow *)window;

@end