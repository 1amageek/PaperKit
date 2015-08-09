//
//  PKContentViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/14.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKContentViewController.h"


@interface PKContentViewController ()

@end

@implementation PKContentViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void)_commonInit
{
    _isDisplayingInFullScreen = NO;
}

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
}

- (void)viewDidDisplayInFullScreen
{
    _isDisplayingInFullScreen = YES;
}

- (void)viewDidEndDisplayingInFullScreen
{
    _isDisplayingInFullScreen = NO;
}

- (void)viewControllerDidScroll:(UIScrollView *)scrollView
{
    if (self.isDisplayingInFullScreen) {
        [self viewDidEndDisplayingInFullScreen];
    }
}

@end