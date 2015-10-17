//
//  PKTransitionController.m
//  Sample
//
//  Created by 1amageek on 2015/09/30.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKTransitionController.h"
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

@interface PKTransitionController ()

@property (nonatomic) id context;
@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) UIView *fromView;
@property (nonatomic) UIView *toView;

@end

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}


@implementation PKTransitionController
{
    CGFloat _initialTouchProgress;
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        _transitionProgress = 0;
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

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    
    CGFloat alpha = POPTransition(transitionProgress, 1, 0);
    self.fromView.alpha = alpha;
    
    CGFloat scale = POPTransition(transitionProgress, 1, 0.95);
    POPLayerSetScaleXY(self.fromView.layer, CGPointMake(scale, scale));
    
    CGFloat translation = POPTransition(transitionProgress, [UIScreen mainScreen].bounds.size.height, 0);
    POPLayerSetTranslationY(self.toView.layer, translation);
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.33f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;
    self.fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    self.toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    [self.fromView addGestureRecognizer:self.panGestureRecognizer];

    [[transitionContext containerView] addSubview:self.fromView];
    [[transitionContext containerView] addSubview:self.toView];

    //POPLayerSetTranslationY(self.toView.layer, 0);
    
    POPBasicAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.transition.controller"];
    if (!animation) {
        animation = [POPBasicAnimation easeOutAnimation];
        animation.duration = [self transitionDuration:transitionContext];
        animation.property = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.transition.controller.prop" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj transitionProgress];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setTransitionProgress:values[0]];
            };
            prop.threshold = 0.01;
        }];
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if (finished) {
                //[self stackAnimationFinished];
            }
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.transition.controller"];
    }
    animation.toValue = @(1);
    
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
}

#pragma mark - UIPanGestureRecognizer

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:nil];
    CGPoint translation = [recognizer translationInView:nil];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [self pop_removeAnimationForKey:@"inc.stamp.pk.transition.controller"];
            _initialTouchProgress = self.transitionProgress;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            
            CGFloat progress = _initialTouchProgress + (translation.y) / [UIScreen mainScreen].bounds.size.height;
            [self setTransitionProgress:progress];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            
            break;
        }
        default:
            break;
    }
}

@end
