//
//  PKTransitionAnimator.m
//  Sample
//
//  Created by 1amageek on 2015/12/03.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKTransitionAnimator.h"
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

@interface PKTransitionAnimator ()

@property (nonatomic) id <UIViewControllerContextTransitioning> context;
@property (nonatomic, weak) UIViewController *fromViewController;
@property (nonatomic, weak) UIViewController *toViewController;
@property (nonatomic, weak) UIViewController *presentedViewController;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGFloat transitionProgress;

@end

@implementation PKTransitionAnimator
{
    CGFloat _previousProgress;
}

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _presenting = NO;
        _transitionProgress = 0;
        _previousProgress = 0;
    }
    return self;
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_panGestureRecognizer) {
        return _panGestureRecognizer;
    }
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    return _panGestureRecognizer;
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:nil];
    CGPoint velocity = [recognizer velocityInView:nil];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            
            [self pop_removeAllAnimations];
            _previousProgress = self.transitionProgress;
            if (!self.context) {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGFloat delta = translation.y / [UIScreen mainScreen].bounds.size.height;
            if (self.transitionProgress <= 0 || self.transitionProgress >= 1) {
                delta = delta / 5;
            }
            [self setTransitionProgress:_previousProgress - delta];
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:{
            
            [self endInteractiveTransition:(self.presenting ? (velocity.y <= 0) : (velocity.y >= 0)) velocity:velocity];
            
            break;
        }
        default:
            break;
    }
}

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    
    if (!self.context) {
        return;
    }
    
    UIView *view;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (self.presenting) {
        view = self.toViewController.view;
    } else {
        view = self.fromViewController.view;
    }
    
    CGFloat originY = POPTransition(transitionProgress, screenSize.height, 0);
    if (view) {
        view.frame = CGRectMake(0, originY, view.bounds.size.width, view.bounds.size.height);
    }
}

- (void)endInteractiveTransition:(BOOL)didComplete velocity:(CGPoint)velocity
{
    if (didComplete) {
        [self animationToValue:self.presenting velocity:velocity completion:^(BOOL finished) {
            if (finished) {
                [self.context finishInteractiveTransition];
                [self.context completeTransition:YES];
                self.context = nil;
            }
        }];
    } else {
        [self animationToValue:!self.presenting velocity:velocity completion:^(BOOL finished) {
            if (finished) {
                [self.context cancelInteractiveTransition];
                [self.context completeTransition:NO];
                self.context = nil;
            }
        }];
    }
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
    
    if (self.presenting) {
        self.presentedViewController = self.toViewController;
        [toView addGestureRecognizer:self.panGestureRecognizer];
        [containerView addSubview:toView];
        toView.frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
        [self animationToValue:1 velocity:CGPointZero completion:^(BOOL finished) {
            if (finished) {
                [transitionContext finishInteractiveTransition];
                [transitionContext completeTransition:YES];
                self.context = nil;
            }
        }];
    }
}

- (void)animationToValue:(CGFloat)toValue velocity:(CGPoint)velocity completion:(void (^)(BOOL finished))completion
{
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.transition.animator.animation"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.transition.animator.animation.prop" initializer:^(POPMutableAnimatableProperty *prop) {
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
        [self pop_addAnimation:animation forKey:@"inc.stamp.transition.animator.animation"];
    }
    animation.toValue = @(toValue);
}


@end
