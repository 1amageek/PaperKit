//
//  ComposeViewController.m
//  Sample
//
//  Created by 1amageek on 2015/09/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "ComposeViewController.h"
#import "PKTransitionController.h"

@interface ComposeViewController ()
@property (nonatomic) PKTransitionController *transitionController;
@end

@implementation ComposeViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
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

#pragma 

- (PKTransitionController *)transitionController
{
    if (_transitionController) {
        return _transitionController;
    }
    
    _transitionController = [[PKTransitionController alloc] initWithView:self.view];
    return _transitionController;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionController;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.transitionController;
}
/*
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return [PKTransitionController new];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return [PKTransitionController new];
}*/


@end
