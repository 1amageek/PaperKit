//
//  FullScreenContentViewController.m
//  Sample
//
//  Created by Norikazu on 2015/07/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "FullScreenContentViewController.h"

@interface FullScreenContentViewController ()

@end

@implementation FullScreenContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _previewView = [[PKPreviewView alloc] initWithImage:[UIImage imageNamed:@"pexels-photo-medium"]];
    [self.view addSubview:_previewView];
}

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    [super transitionProgress];
    if (transitionProgress == 1) {
        [self.previewView startMotion];
    } else {
        [self.previewView stopMotion];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
