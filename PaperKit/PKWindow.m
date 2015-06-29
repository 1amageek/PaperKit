//
//  PKWindow.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKWindow.h"

@interface PKWindow () <UIGestureRecognizerDelegate>

@property (nonatomic) PKPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) CGFloat statusBarHeight;

@end

@implementation PKWindow
{
    CGPoint _initialTouchPoint;
    CGPoint _initialTouchPosition;
}

static CGFloat windowTopHeight = 60;

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _state = PKWindowStateNormal;
    _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 5;
    
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    self.layer.cornerRadius = 4.0f;
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //self.alpha = 0.3;
    self.windowLevel = UIWindowLevelStatusBar + 1;
    self.panGestureRecognizer = [[PKPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    self.panGestureRecognizer.scrollDirection = PKPanGestureRecognizerDirectionVertical;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (BOOL)hasManyWindows
{
    return 2 < [UIApplication sharedApplication].windows.count;
}

- (NSArray *)childWindows
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    NSMutableArray *childWindows = @[].mutableCopy;
    [windows enumerateObjectsUsingBlock:^(UIWindow *window, NSUInteger idx, BOOL * __nonnull stop) {
        if (window.windowLevel > self.windowLevel) {
            [childWindows addObject:window];
        }
    }];
    return childWindows;
}

- (UIWindow *)superWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    NSInteger index = [windows indexOfObject:self];
    if (index) {
        
        UIWindow *superWindow = nil;
        
        while (superWindow == nil) {
            UIWindow *window = windows[index - 1];
            if (window.windowLevel == UIWindowLevelNormal) {
                superWindow = window;
            }
            index --;
        }
        
        return superWindow;
    }
    return nil;
}

- (NSArray *)_windows
{
    NSMutableArray *windows = (NSMutableArray *)[UIApplication sharedApplication].windows;
    [windows removeObject:windows.firstObject];
    return windows;
}

- (CGFloat)progressToListState
{
    NSInteger count = [UIApplication sharedApplication].windows.count - 2;
    CGFloat height = _statusBarHeight + windowTopHeight * count;
    return height / [UIScreen mainScreen].bounds.size.height;
}

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    
    CGFloat yPosition = POPTransition(transitionProgress, 0, [UIScreen mainScreen].bounds.size.height);
    POPLayerSetTranslationY(self.layer, yPosition);
    
    
    NSArray *windows = [self _windows];
    
    for (NSUInteger i = 0; i < windows.count; i++) {
        CGFloat height = _statusBarHeight + windowTopHeight * i;
        CGFloat yPosition = POPTransition(transitionProgress, 0, height);
        UIWindow *window = windows[i];
        POPLayerSetTranslationY(window.layer, yPosition);
        
        NSLog(@"%lu %f", (unsigned long)i, height);
    }
    
}

#pragma mark - TapGestureRecognizer

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    [self animationTransitionState:PKWindowStateNormal velocity:0];
}

#pragma mark - PanGestureRecognizer

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self];
    CGPoint translation = [recognizer translationInView:self];
    CGPoint velocity = [recognizer velocityInView:self];
    
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            _initialTouchPoint = location;
            _initialTouchPosition = self.frame.origin;
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat yPosition = _initialTouchPosition.y + translation.y;
            CGFloat progress = yPosition/[UIScreen mainScreen].bounds.size.height;
            
            if (progress < 0) {
                progress = progress / 4;
            }
            if (1 < progress) {
                CGFloat deltaProgress = progress - 1;
                progress = 1 + deltaProgress / 4;
            }
            
            [self setTransitionProgress:progress];
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
    
            PKWindowState state = PKWindowStateNormal;
            if (velocity.y > 0) {
                if ([self hasManyWindows]) {
                    
                    if ([self progressToListState] < self.transitionProgress) {
                        state = PKWindowStateDismiss;
                    } else {
                        state = PKWindowStateList;
                    }
                    
                } else {
                    state = PKWindowStateOpen;
                }
            } else {
                if ([self hasManyWindows]) {
                    if ([self progressToListState] < self.transitionProgress) {
                        state = PKWindowStateList;
                    } else {
                        state = PKWindowStateNormal;
                    }
                } else {
                    state = PKWindowStateNormal;
                }
            }
            
            [self animationTransitionState:state velocity:velocity.y];
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - Animation

- (void)animationTransitionState:(PKWindowState)state velocity:(CGFloat)velocity
{
    _state = state;
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.window.progress"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.scrollView.progress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj transitionProgress];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                //[obj animateWithProgress:values[0] expand:expand];
                [obj setTransitionProgress:values[0]];
            };
            prop.threshold = 0.01;
        }];
        animation.velocity = @(velocity/1000);
        animation.property = propX;
        animation.springSpeed = 8;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.window.progress"];
    }
    
    switch (state) {
        case PKWindowStateList:
            animation.toValue = @([self progressToListState]);
            break;
        case PKWindowStateOpen:
            animation.toValue = @(0.9);
            break;
        case PKWindowStateDismiss:
            animation.toValue = @(1);
            break;
        
        case PKWindowStateNormal:
        default:
            animation.toValue = @(0);
            break;
    }
    
}

- (BOOL)gestureRecognizer:(nonnull UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(nonnull UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.tapGestureRecognizer) {
        if (self.state == PKWindowStateOpen) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Utilities

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

static inline CGFloat POPDegreesToRadians(CGFloat degrees) {
    return M_PI * (degrees / 180.0);
}

static inline CGFloat POPPixelsToPoints(CGFloat pixels) {
    static CGFloat scale = -1;
    if (scale < 0) {
        scale = [UIScreen mainScreen].scale;
    }
    return pixels / scale;
}

@end
