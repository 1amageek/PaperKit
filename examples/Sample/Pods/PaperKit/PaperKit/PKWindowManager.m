//
//  PKWindowManager.m
//  Pods
//
//  Created by Norikazu on 2015/07/05.
//
//

#import "PKWindowManager.h"


static PKWindowManager  *sharedManager = nil;

@implementation PKWindowManager

#pragma mark - Initialize

+ (instancetype)sharedManager
{
    return sharedManager;
}

+ (void)setSharedManager:(PKWindowManager *)manager
{
    sharedManager = manager;
}

+ (PKWindowManager *)managerWithBaseWindow:(UIWindow *)window
{
    PKWindowManager *manager = [[PKWindowManager alloc] initWithBaseWidnow:window];
    return manager;
}

- (instancetype)initWithBaseWidnow:(UIWindow *)window
{
    if (self = [super init]) {
        _baseWindow = window;
        _windows = @[];
        if (nil == sharedManager) {
            [PKWindowManager setSharedManager:self];
        }
    }
    
    return self;
}

#pragma mark - method

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController
{
    return[self showWindowWithRootViewController:rootViewController animated:YES];
}

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    PKWindow *window = [[PKWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelStatusBar + self.windows.count + 1;
    window.rootViewController = rootViewController;
    window.manager = self;
    NSMutableArray *windows = [NSMutableArray arrayWithArray:self.windows];
    [windows addObject:window];
    _windows = windows;
    [window makeKeyAndVisible:animated];
    return window;
}

#pragma mark - PKWindowDelegate

- (NSArray *)windowsOnBaseWindow
{
    return self.windows;
}

- (void)windowWillAppear:(PKWindow *)window
{
    //self.baseWindow.userInteractionEnabled = NO;
}

- (void)windowDidAppear:(PKWindow *)window
{
    //self.baseWindow.userInteractionEnabled = YES;
}

- (void)windowDidDisappear:(PKWindow *)window
{
    NSMutableArray *windows = [NSMutableArray arrayWithArray:self.windows];
    [windows removeObject:window];
    _windows = windows;
    window = nil;
    [self.windows.lastObject makeKeyWindow];
}


@end
