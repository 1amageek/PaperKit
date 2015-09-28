//
//  ComposeViewController.m
//  Sample
//
//  Created by 1amageek on 2015/09/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
}

- (UITextView *)textView
{
    if (_textView) {
        return _textView;
    }
    
    _textView = [[UITextView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(20, 20, 20, 20))];
    _textView.delegate = self;
    return _textView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        
    }
}

- (PKWindowDismissTransitionStyle)preferredWindowDismissTransitionStyle
{
    return PKWindowDismissTransitionStyleUnlink;
}

@end
