//
//  PKTransitionController.m
//  Sample
//
//  Created by 1amageek on 2015/12/02.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKTransitionController.h"
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

@interface PKTransitionController ()

@property (nonatomic) id <UIViewControllerContextTransitioning> context;
@property (nonatomic, weak) UIViewController *fromViewController;
@property (nonatomic, weak) UIViewController *toViewController;
@property (nonatomic) CGFloat transitionProgress;
@end

@implementation PKTransitionController
static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _presenting = NO;
        _transitionProgress = 0;
    }
    return self;
}

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    
    UIView *view;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (self.presenting) {
        view = self.toViewController.view;
    } else {
        view = self.fromViewController.view;
    }
    
    CGFloat originY = POPTransition(transitionProgress, 0, screenSize.height);
    POPLayerSetTranslationY(view.layer, originY);
    
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.44f;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;
    
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    UIView *toView = self.toViewController.view;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    toView.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    [containerView addSubview:toView];
    
    [self animationToValue:1 velocity:CGPointZero completion:^(BOOL finished) {
        
    }];
    
}

- (void)animationToValue:(CGFloat)toValue velocity:(CGPoint)velocity completion:(void (^)(BOOL finished))completion
{
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.transitioncontroller.animation"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.transitioncontroller.animation.prop" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj transitionProgress];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setTransitionProgress:values[0]];
            };
            prop.threshold = 0.01;
        }];
        animation.property = propX;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if (completion) {
                completion(finished);
            }
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.transitioncontroller.animation"];
    }
    animation.toValue = @(toValue);
}




@end
