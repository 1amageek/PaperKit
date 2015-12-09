//
//  PKTransitionAnimator.h
//  Sample
//
//  Created by 1amageek on 2015/12/03.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

@import UIKit;

@interface PKTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic) BOOL presenting;
@property (nonatomic) BOOL confirmToCancel;
@property (nonatomic) BOOL agreeToCancel;
@property (nonatomic) CGFloat confirmViewHeight;

@end
