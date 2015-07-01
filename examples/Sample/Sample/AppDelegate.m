//
//  AppDelegate.m
//  Sample
//
//  Created by Norikazu on 2015/06/27.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic) PKWindow *window1;
@property (nonatomic) PKWindow *window2;
@property (nonatomic) PKWindow *window3;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window1 = [[PKWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *viewController1 = [ViewController new];
    
    _window1.rootViewController = viewController1;
    _window1.backgroundColor = [UIColor grayColor];
    [_window1 makeKeyAndVisible];
    
    _window2 = [[PKWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *viewController2 = [ViewController new];
    
    _window2.rootViewController = viewController2;
    _window2.backgroundColor = [UIColor grayColor];
    [_window2 makeKeyAndVisible];
    
    /*
    _window3 = [[PKWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *viewController3 = [ViewController new];
    
    _window3.rootViewController = viewController3;
    _window3.backgroundColor = [UIColor grayColor];
    [_window3 makeKeyAndVisible];
    */
    return YES;
}


@end
