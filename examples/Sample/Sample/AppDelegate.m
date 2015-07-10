//
//  AppDelegate.m
//  Sample
//
//  Created by Norikazu on 2015/06/27.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //BackgroundViewController *viewController = [BackgroundViewController new];
    CollectionViewController *viewController = [CollectionViewController new];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    [PKWindowManager managerWithBaseWindow:self.window];
        
    return YES;
}

@end
