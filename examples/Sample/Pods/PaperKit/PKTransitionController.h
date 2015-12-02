//
//  PKTransitionController.h
//  Sample
//
//  Created by 1amageek on 2015/12/02.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

@import UIKit;

@interface PKTransitionController : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic) BOOL presenting;

@end
