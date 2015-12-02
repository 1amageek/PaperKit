//
//  PKWindowManager.m
//  Pods
//
//  Created by Norikazu on 2015/07/05.
//
//

#import "PKWindowManager.h"

@interface PKWindowManager () <POPAnimationDelegate>

@property (nonatomic, readwrite) PKWindowManagerStatus status;
@property (nonatomic, readwrite, weak) UIWindow *baseWindow;
@property (nonatomic, readwrite) NSArray <PKWindow *>*windows;

// Multiwindow status
@property (nonatomic, readwrite, getter=isSingleWindow) BOOL singleWindow;
@property (nonatomic, readwrite)                        BOOL link;
@property (nonatomic, readwrite)                        BOOL stack;
@property (nonatomic, readwrite, getter=isLinking)      BOOL linking;
@property (nonatomic, readwrite, getter=isStacking)     BOOL stacking;
@property (nonatomic, readwrite, getter=isAnimating)    BOOL animating;

// Gesture status
@property (nonatomic, readwrite, getter=isTracking)     BOOL tracking;
@property (nonatomic, readwrite, getter=isDragging)     BOOL dragging;
@property (nonatomic, readwrite, getter=isDecelerating) BOOL decelerating;
@property (nonatomic, readwrite, getter=isTouchingTopWindow) BOOL touchingTopWindow;

@property (nonatomic) NSInteger dismissIndex;
@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) CGFloat linkTransitionProgress;
@property (nonatomic) CGFloat stackTransitionProgress;
@property (nonatomic) CGFloat upperProgress;
@property (nonatomic) CGFloat lowerProgress;
@property (nonatomic) CGFloat thresholdPosition;

@end

static PKWindowManager  *sharedManager = nil;
static CGFloat interval = 60.0f;
static CGFloat confirmInterval = 100.0f;
static CGFloat translationThreshold = 20.0f;
static CGFloat statusBarHeight;
static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

@implementation PKWindowManager
{
    BOOL _lock;
    CGPoint _initialTouchPoint;
    CGPoint _initialTouchTopWindowPosition;
    CGFloat _previousProgress;
}

#pragma mark - Initialize

+ (PKWindowManager *)sharedManager
{
    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [PKWindowManager new];
        }
    }
    return sharedManager;
}

- (instancetype)init
{
    NSLog(@"Initialization must be managerWithBaseWindow:");
    abort();
    return nil;
    /*
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
     */
}

+ (PKWindowManager *)managerWithBaseWindow:(UIWindow *)window
{
    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[PKWindowManager alloc] initWithBaseWidnow:window];
        }
    }
    return sharedManager;
}

- (instancetype)initWithBaseWidnow:(UIWindow *)window
{
    if (self = [super init]) {
        _baseWindow = window;
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    _windows = @[];
    _lock = NO;
    _link = NO;
    _linking = NO;
    _stack = NO;
    _stacking = NO;
    _animating = NO;
    _tracking = NO;
    _dragging = NO;
    _decelerating = NO;
    _dismissIndex = 0;
    _transitionProgress = 0;
    _linkTransitionProgress = 0;
    _stackTransitionProgress = 0;
    _status = PKWindowManagerStatusNothing;
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (void)setStatus:(PKWindowManagerStatus)status
{
    _status = status;
    if (status == PKWindowManagerStatusDefault) {
        [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
            window.rootViewController.view.userInteractionEnabled = YES;
        }];
    } else {
        [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
            window.rootViewController.view.userInteractionEnabled = NO;
        }];
    }
}

#pragma mark - util

- (NSInteger)numberOfWindowsInManager
{
    return self.windows.count;
}

- (NSInteger)indexOfWindow:(PKWindow *)window
{
    return [self.windows indexOfObject:window];
}

- (PKWindow *)windowForIndex:(NSInteger)index
{
    return [self.windows objectAtIndex:index];
}

- (CGFloat)upperProgress
{
    return [self progressToListStatus] + 0.25;
}

- (CGFloat)lowerProgress
{
    return [self progressToListStatus];
}

- (CGFloat)thresholdPosition
{
    return confirmInterval + confirmInterval;
}

- (CGFloat)progressToListStatus
{
    NSInteger count = self.windows.count - 1;
    CGFloat height = statusBarHeight + interval * count;
    return height / [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat)progressToConfirmStatus
{
    NSInteger count = self.windows.count - 1;
    CGFloat height = statusBarHeight + interval * count;
    return height / [UIScreen mainScreen].bounds.size.height;
}

- (PKWindow *)topWindow
{
    if (self.windows.count == 0) {
        return nil;
    }
    return [self.windows lastObject];
}

#pragma mark - add window

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController
{
    return [self showWindowWithRootViewController:rootViewController animated:YES];
}

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    if (!_lock) {

        CGRect screen = [UIScreen mainScreen].bounds;
        PKWindow *window = [[PKWindow alloc] initWithFrame:screen];
        window.windowLevel = UIWindowLevelStatusBar + self.windows.count + 1;
        window.rootViewController = rootViewController;
        window.manager = self;
        _link = NO;
        _linking = NO;
        _stack = NO;
        _stacking = NO;
        [self _addWindow:window];
        self.dismissIndex = [self indexOfWindow:window];
        [window makeKeyAndVisible:animated];
        POPLayerSetTranslationY(window.layer, screen.size.height);
        [self animation].fromValue = @(1);
        [self animationToStatus:PKWindowManagerStatusDefault];
        
        return window;
    }
    return nil;
}

- (void)_addWindow:(PKWindow *)window
{
    NSMutableArray *windows = self.windows.mutableCopy;
    [windows addObject:window];
    self.windows = windows;
}

- (void)_removeWindow:(PKWindow *)window
{
    NSMutableArray *windows = self.windows.mutableCopy;
    [windows removeObject:window];
    self.windows = windows;
}

- (BOOL)isSingleWindow
{
    if (1 < self.windows.count) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -

- (void)dismissWindow:(PKWindow *)window
{
    
}

- (void)open
{
    
}

- (void)close
{
    
}

#pragma mark - gesture

- (BOOL)window:(PKWindow *)window shouldGesture:(UIGestureRecognizer *)recognizer
{
    if (self.status == PKWindowManagerStatusSingleWindowOpen ||
        self.status == PKWindowManagerStatusMultipleWindowOpen ||
        self.status == PKWindowManagerStatusList) {
        return YES;
    }
    return NO;
}

- (void)window:(PKWindow *)window tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.status == PKWindowManagerStatusMultipleWindowOpen ||
        self.status == PKWindowManagerStatusSingleWindowOpen) {
        [self setStack:NO];
        [self animationToStatus:PKWindowManagerStatusDefault];
        return;
    }
    
    if (self.status == PKWindowManagerStatusList) {
        
        if (window == self.topWindow) {
            [self setStack:NO];
            [self animationToStatus:PKWindowManagerStatusDefault];
        } else {
            NSInteger index = [self indexOfWindow:window];
            [self setDismissIndex:index + 1];
            [self animationToStatus:PKWindowManagerStatusDismiss];
        }
    }
}

- (void)window:(PKWindow *)window panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:window];
    CGPoint translation = [recognizer translationInView:window];
    CGPoint velocity = [recognizer velocityInView:window];
    CGFloat progress = 0.0;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _tracking = YES;
            _initialTouchPoint = location;
            _initialTouchTopWindowPosition = self.topWindow.frame.origin;

            if (self.status == PKWindowManagerStatusList) {
                if (window == self.topWindow) {
                    self.touchingTopWindow = YES;
                    self.dismissIndex = [self indexOfWindow:self.topWindow];
                } else {
                    self.touchingTopWindow = NO;
                    self.dismissIndex = 0;
                }
            } else {
                self.dismissIndex = 0;
            }
        
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            _dragging = YES;
            
            CGFloat yPosition = _initialTouchTopWindowPosition.y + translation.y;
            CGFloat x = yPosition/[UIScreen mainScreen].bounds.size.height;
            CGFloat y = x;
            
            if (x < 0) {
                y = x/8;
            }
            
            if (!self.isTouchingTopWindow && self.status == PKWindowManagerStatusList) {
                [self setStack:YES];
            }
            
            if (!self.isSingleWindow && self.isTouchingTopWindow && self.isTracking) {
                CGFloat lower = self.lowerProgress;
                CGFloat upper = self.upperProgress;
                CGFloat k = 5;
                
                if (0 <= x && x < lower) {
                    y = x;
                }
                
                if (lower <= x && x < upper) {
                    y = 1/k * x + lower * (1 - 1/k);
                    [self setLink:YES];
                }
                
                if (upper <= x) {
                    y = x + (1/k - 1) * (upper - lower);
                    [self setLink:NO];
                }
            }
            
            progress = y;
            [self setTransitionProgress:progress];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _tracking = NO;
            _dragging = NO;
            _decelerating = YES;
            
            if (translationThreshold < fabs(translation.y)) {
                PKWindowManagerStatus status = [self statusForProgress:self.transitionProgress velocity:velocity.y];
                [self animationToStatus:status];
            } else {
                [self animationToStatus:self.status];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Progress

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    if (transitionProgress == 0) {
        _linkTransitionProgress = transitionProgress;
        _stackTransitionProgress = transitionProgress;
    }
    
    if (self.isLinking) {
        _linkTransitionProgress = transitionProgress;
        [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat yPosition = [self positionForWindow:window progress:transitionProgress].y;
            POPLayerSetTranslationY(window.layer, yPosition);
        }];
        return;
    }
    
    [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.dismissIndex <= idx) {
            CGFloat yPosition = [self positionForWindow:window progress:transitionProgress].y;
            POPLayerSetTranslationY(window.layer, yPosition);
        }
    }];
    
}

- (void)setLinkTransitionProgress:(CGFloat)linkTransitionProgress
{
    _linkTransitionProgress = linkTransitionProgress;
    if (!self.isLinking) {
        if (self.transitionProgress < linkTransitionProgress) {
            [self pop_removeAnimationForKey:@"inc.stamp.pk.window.link"];
            [self linkAnimationFinished];
        }
        
        [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < self.dismissIndex) {
                CGFloat yPosition = [self positionForWindow:window progress:linkTransitionProgress].y;
                POPLayerSetTranslationY(window.layer, yPosition);
            }
        }];
    }
}

- (void)setStackTransitionProgress:(CGFloat)stackTransitionProgress
{
    _stackTransitionProgress = stackTransitionProgress;
    [self setTransitionProgress:self.transitionProgress];
}

- (void)setLink:(BOOL)link
{
    if (_link != link) {
        _link = link;
        
        if (!link) {
            self.linking = NO;
        }
        
        self.animating = YES;
        [self pop_removeAnimationForKey:@"inc.stamp.pk.window.link"];
        [self linkAnimation].toValue = link ? @(self.transitionProgress) : @(0);
    }
}

- (void)setStack:(BOOL)stack
{
    if (_stack != stack) {
        _stack = stack;
        if (!stack) {
            self.stacking = NO;
        }
        [self pop_removeAnimationForKey:@"inc.stamp.pk.window.stack"];
        [self stackAnimation].toValue = stack ? @(1) : @(0);
    }
}

- (void)setStacking:(BOOL)stacking
{
    _stacking = stacking;
    if (stacking) {
        _stackTransitionProgress = 1;
    } else {
        _stackTransitionProgress = 0;
    }
}

- (PKWindowManagerStatus)statusForProgress:(CGFloat)transitionProgress velocity:(CGFloat)velocity
{
    PKWindowManagerStatus status = self.status;
    switch (self.status) {
        case PKWindowManagerStatusList:
        {
            if (0 < velocity) {
                if (self.upperProgress < transitionProgress) {
                    if (self.isSingleWindow) {
                        status = PKWindowManagerStatusSingleWindowOpen;
                    } else {
                        if (!self.isTouchingTopWindow) {
                            status = PKWindowManagerStatusMultipleWindowOpen;
                        } else {
                            status = PKWindowManagerStatusDismiss;
                        }
                    }
                } else {
                    if (!self.isTouchingTopWindow) {
                        status = PKWindowManagerStatusDefault;
                    } else {
                        status = PKWindowManagerStatusList;
                    }
                }
            } else {
                if (self.isTouchingTopWindow) {
                    if (self.lowerProgress < transitionProgress) {
                        status = PKWindowManagerStatusList;
                    } else {
                        status = PKWindowManagerStatusDefault;
                    }
                } else {
                    [self setStack:NO];
                    status = PKWindowManagerStatusDefault;
                }
            }
            break;
        }
        case PKWindowManagerStatusMultipleWindowOpen:
        case PKWindowManagerStatusSingleWindowOpen:
        {
            if (velocity < 0) {
                status = PKWindowManagerStatusDefault;
            }
            break;
        }
        case PKWindowManagerStatusDismiss:
        {
         
            break;
        }
        case PKWindowManagerStatusNothing:
        case PKWindowManagerStatusDefault:
        default:
        {
            if (0 < velocity) {
                if (self.upperProgress < transitionProgress) {
                    if (self.isTouchingTopWindow) {
                        status = PKWindowManagerStatusMultipleWindowOpen;
                    } else {
                        status = PKWindowManagerStatusDismiss;
                    }
                } else {
                    status = PKWindowManagerStatusList;
                }
                
                if (self.isSingleWindow) {
                    status = PKWindowManagerStatusSingleWindowOpen;
                }
                
            } else {
                status = PKWindowManagerStatusDefault;
            }
            break;
        }
    }
    
    return status;
}

- (void)animationToStatus:(PKWindowManagerStatus)status
{
    self.status = status;
    switch (status) {
        case PKWindowManagerStatusDismiss:
        {
            [self setLink:NO];
            [self setStack:YES];
            [self animation].toValue = @(1);
            break;
        }
        case PKWindowManagerStatusList:
        {
            [self animation].toValue = @([self progressToListStatus]);
            if (!self.isLinking) {
                [self setLink:YES];
                [self linkAnimation].toValue = @([self progressToListStatus]);
            }
            break;
        }
        case PKWindowManagerStatusMultipleWindowOpen:
        case PKWindowManagerStatusSingleWindowOpen:
        {
            [self animation].toValue = @(0.9);
            break;
        }
        case PKWindowManagerStatusNothing:
        case PKWindowManagerStatusDefault:
        default:
        {
            [self animation].toValue = @(0);
            break;
        }
    }
}

- (CGPoint)positionForWindow:(PKWindow *)window progress:(CGFloat)transitionProgress
{
    NSUInteger i = [self indexOfWindow:window];
    CGFloat progress = transitionProgress/[self progressToListStatus];
    CGFloat stackProgress = (self.dismissIndex <= i) ? self.stackTransitionProgress : 0;
    CGFloat toInterval = POPTransition((1 - stackProgress), 0, interval);
    CGFloat height = POPTransition(transitionProgress, 0, [UIScreen mainScreen].bounds.size.height)
    - POPTransition(progress, 0, toInterval * (self.numberOfWindowsInManager - 1 - i));
    return CGPointMake(0, height);
}

#pragma mark - Animation

- (POPBasicAnimation *)animation
{
    POPBasicAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.window.progress"];
    if (!animation) {
        animation = [POPBasicAnimation easeOutAnimation];
        animation.duration = 0.28f;
        animation.property = self.animatableProperty;
        animation.delegate = self;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if (finished) {
                [self animationFinished];
            }
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.window.progress"];
    }
    return animation;
}

- (POPAnimatableProperty *)animatableProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.window.progress" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj transitionProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setTransitionProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    return prop;
}

- (void)animationFinished
{
    switch (self.status) {
        case PKWindowManagerStatusDismiss:
        {
            
            NSUInteger count = self.windows.count;
            NSMutableArray *windows = self.windows.mutableCopy;
            [windows removeObjectsInRange:NSMakeRange(self.dismissIndex, count - self.dismissIndex)];
            self.windows = windows;
            self.status = PKWindowManagerStatusDefault;

            _link = YES;
            _linking = YES;
            _stack = NO;
            self.stacking = NO;
            break;
        }
        case PKWindowManagerStatusList:
        {
            [self setStack:NO];
            break;
        }
        case PKWindowManagerStatusMultipleWindowOpen:
        case PKWindowManagerStatusSingleWindowOpen:
        {

            break;
        }
        case PKWindowManagerStatusNothing:
        case PKWindowManagerStatusDefault:
        default:
        {
            _link = YES;
            _linking = YES;
            _stack = NO;
            _stacking = NO;
            [self setTransitionProgress:0];
            break;
        }
    }
}

- (POPBasicAnimation *)linkAnimation
{
    POPBasicAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.window.link"];
    if (!animation) {
        animation = [POPBasicAnimation easeOutAnimation];
        animation.duration = 0.32f;
        animation.property = self.linkAnimatableProperty;
        animation.delegate = self;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if (finished) {
                [self linkAnimationFinished];
            }
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.window.link"];
    }
    return animation;
}

- (POPAnimatableProperty *)linkAnimatableProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.window.link" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj linkTransitionProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setLinkTransitionProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    return prop;
}

- (void)linkAnimationFinished
{
    self.animating = NO;
    self.linking = self.link;
}

- (POPBasicAnimation *)stackAnimation
{
    POPBasicAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.window.stack"];
    if (!animation) {
        animation = [POPBasicAnimation easeOutAnimation];
        animation.duration = 0.28f;
        animation.property = self.stackAnimatableProperty;
        animation.delegate = self;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if (finished) {
                [self stackAnimationFinished];
            }
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.window.stack"];
    }
    return animation;
}

- (POPAnimatableProperty *)stackAnimatableProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.window.stack" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj stackTransitionProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setStackTransitionProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    return prop;
}

- (void)stackAnimationFinished
{
    self.stacking = self.stack;
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    _decelerating = NO;
}

@end
