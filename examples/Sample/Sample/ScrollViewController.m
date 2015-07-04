//
//  ScrollViewController.m
//  Sample
//
//  Created by Norikazu on 2015/07/02.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "ScrollViewController.h"

@interface ScrollViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *myView;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 2)];
    _myView.backgroundColor = [UIColor blueColor];
    
    _scrollView.contentSize = _myView.bounds.size;
    
    [self.view addSubview:_scrollView];
    [self.scrollView addSubview:_myView];

}

- (BOOL)gestureRecognizerShouldBegin:(nonnull UIGestureRecognizer *)gestureRecognizer
{
        NSLog(@"%@", [self nextResponder]);
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
