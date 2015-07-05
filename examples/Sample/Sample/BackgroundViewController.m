//
//  BackgroundViewController.m
//  Sample
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "BackgroundViewController.h"
#import "ViewController.h"

@interface BackgroundViewController ()

@property (nonatomic) UIButton *addButton;
@property (nonatomic) UIButton *removeButton;

@end

@implementation BackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_addButton setTitle:@"add new window" forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_addButton sizeToFit];
    _addButton.center = self.view.center;
    [self.view addSubview:_addButton];
    
    _removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_removeButton setTitle:@"remove last window" forState:UIControlStateNormal];
    [_removeButton addTarget:self action:@selector(removeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_removeButton sizeToFit];
    _removeButton.center = CGPointMake(self.view.center.x, 60);
    [self.view addSubview:_removeButton];
    
}

- (void)addTapped:(UIButton *)button
{
    PKViewController *viewController = (PKViewController *)[UIApplication sharedApplication].windows.lastObject.rootViewController;
    ViewController *nextViewController = [ViewController new];
    [viewController showNextWindowWithRootViewController:nextViewController];
}

- (void)removeTapped:(UIButton *)button
{
    
    NSLog(@"%d", (int)CFGetRetainCount((__bridge CFTypeRef)self.window));
    NSLog(@"%d", (int)CFGetRetainCount((__bridge CFTypeRef)[UIApplication sharedApplication].windows.lastObject));
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    NSLog(@"%d", (int)CFGetRetainCount((__bridge CFTypeRef)window));
    NSLog(@"%d", (int)CFGetRetainCount((__bridge CFTypeRef)self.window));
    self.window = nil;
    NSLog(@"window %@", window);
    NSLog(@"self %@", self.window);
    
    
}

@end
