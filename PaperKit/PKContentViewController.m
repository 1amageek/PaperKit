//
//  PKContentViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/14.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKContentViewController.h"

@interface PKContentViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *contentView;

@end

@implementation PKContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 900);
    _scrollView.bounces = NO;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_contentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
