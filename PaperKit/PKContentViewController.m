//
//  PKContentViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/14.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKContentViewController.h"

#define IS_CONTENTOFFSET_ZERO_THRESHOLD 20

@interface PKContentScrollView : UIScrollView

@property (nonatomic) BOOL isContentOffsetZero;

@end

@implementation PKContentScrollView

- (BOOL)gestureRecognizerShouldBegin:(nonnull UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        //CGPoint location = [panGestureRecognizer locationInView:gestureRecognizer.view];
        CGPoint translation = [panGestureRecognizer translationInView:gestureRecognizer.view];
        
        if (self.contentOffset.y < IS_CONTENTOFFSET_ZERO_THRESHOLD && translation.y > 0) {
            return NO;
        }
    }
    return YES;
}

@end

@interface PKContentViewController ()

@property (nonatomic) PKContentScrollView *scrollView;
@property (nonatomic) UIView *contentView;

@end

@implementation PKContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[PKContentScrollView alloc] initWithFrame:self.view.bounds];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 2)];
    _contentView.backgroundColor = [UIColor blueColor];
    _scrollView.contentSize = _contentView.bounds.size;
    
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_contentView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
