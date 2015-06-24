//
//  PKContentViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/14.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKContentViewController.h"


@interface PKContentViewController ()

@property (nonatomic) PKScrollView *scrollView;
@property (nonatomic) UIView *contentView;

@end

@implementation PKContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[PKScrollView alloc] initWithFrame:self.view.bounds];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 2)];
    _contentView.backgroundColor = [UIColor blueColor];
    _scrollView.contentSize = _contentView.bounds.size;
    
    [self.view addSubview:_scrollView];
    [_scrollView addSubview:_contentView];
    
}

- (void)setTranstionProgress:(CGFloat)transtionProgress
{
    _transtionProgress = transtionProgress;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
