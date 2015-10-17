//
//  PKTransitionController.h
//  Sample
//
//  Created by 1amageek on 2015/09/30.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

@import UIKit;

@interface PKTransitionController : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

- (instancetype)initWithView:(UIView *)view;

@end
