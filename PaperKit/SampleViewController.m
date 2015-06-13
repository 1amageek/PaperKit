//
//  SampleViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *contentView;

@end

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _scrollView.contentSize = CGSizeMake(500, 500);
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_contentView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
