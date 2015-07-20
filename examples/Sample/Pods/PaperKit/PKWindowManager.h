//
//  PKWindowManager.h
//  Pods
//
//  Created by Norikazu on 2015/07/05.
//
//

#import <UIKit/UIKit.h>
#import "PKWindow.h"


@interface PKWindowManager : NSObject <PKWindowDelegate>

@property (nonatomic, readonly, weak) UIWindow *baseWindow;
@property (nonatomic, readonly) NSArray *windows;


+ (instancetype)sharedManager;
+ (void)setSharedManager:(PKWindowManager *)manager;
+ (PKWindowManager *)managerWithBaseWindow:(UIWindow *)window;

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController;
- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated;

@end
