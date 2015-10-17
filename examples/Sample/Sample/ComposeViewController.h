//
//  ComposeViewController.h
//  Sample
//
//  Created by 1amageek on 2015/09/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKViewController.h"
#import "PKWindow.h"

@interface ComposeViewController : PKContentViewController <UITextViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) UITextView *textView;

@end
