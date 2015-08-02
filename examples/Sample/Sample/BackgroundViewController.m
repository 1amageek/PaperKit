//
//  BackgroundViewController.m
//  Sample
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "BackgroundViewController.h"
#import "ViewController.h"
#import "FullScreenContentViewController.h"

@interface BackgroundViewController ()

@property (nonatomic) UIButton *addButton;

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

    
}

- (void)addTapped:(UIButton *)button
{
    ViewController *nextViewController = [ViewController new];
    [[PKWindowManager sharedManager] showWindowWithRootViewController:nextViewController];
}


@end
