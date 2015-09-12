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
@property (nonatomic, readwrite, getter=isLinking)      BOOL linking;
@property (nonatomic, readwrite, getter=isStacking)     BOOL stacking;

// Gesture status
@property (nonatomic, readwrite, getter=isTracking)     BOOL tracking;
@property (nonatomic, readwrite, getter=isDragging)     BOOL dragging;
@property (nonatomic, readwrite, getter=isDecelerating) BOOL decelerating;
@property (nonatomic, readwrite, getter=isTouchingTopWindow) BOOL touchingTopWindow;

@property (nonatomic) NSMutableArray *operationToWindows;
@property (nonatomic) NSMutableArray *springToWidnows;
@property (nonatomic) NSMutableArray *stackWindows;
@property (nonatomic) NSMutableArray *dismissWindows;


@property (nonatomic)POPAnimatableProperty *animatableProperty;

@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) CGFloat linkTransitionProgress;
@property (nonatomic) CGFloat unitTransitionProgress;
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
    _operationToWindows = @[].mutableCopy;
    _springToWidnows = @[].mutableCopy;
    _stackWindows = @[].mutableCopy;
    _dismissWindows = @[].mutableCopy;
    _lock = NO;
    _linking = NO;
    _stacking = NO;
    _tracking = NO;
    _dragging = NO;
    _decelerating = NO;
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
    if (index < self.numberOfWindowsInManager) {
        return [self.windows objectAtIndex:index];
    }
    return nil;
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

- (PKWindowDismissTransitionStyle)topWindowDismissTranstionStyle
{
    return self.topWindow.dismissTransitionStyle;
}

#pragma mark - add window

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController
{
    return [self showWindowWithRootViewController:rootViewController animated:YES];
}

- (PKWindow *)showWindowWithRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    if (!_lock) {
        self.status = PKWindowManagerStatusDefault;
        CGRect screen = [UIScreen mainScreen].bounds;
        PKWindow *window = [[PKWindow alloc] initWithFrame:screen];
        window.windowLevel = UIWindowLevelStatusBar + self.windows.count + 1;
        window.rootViewController = rootViewController;
        window.manager = self;
        [self _addWindow:window];
        
        [window makeKeyAndVisible:animated];
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

- (void)setWindows:(NSArray<PKWindow *> *)windows
{
    _windows = windows;
    if (1 < windows.count) {
        _singleWindow = NO;
    } else {
        _singleWindow = YES;
    }
}

#pragma mark - dismiss window

- (void)dismissWindow:(PKWindow *)window
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
    
}

- (void)showWindowAtIndex:(NSInteger)index
{
    //[self dismissAnimationSelectIndex:index].toValue = @(1);
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
            
            if (window == self.topWindow) {
                self.touchingTopWindow = YES;
            } else {
                self.touchingTopWindow = NO;
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
            
            if (!self.isSingleWindow && self.isTouchingTopWindow && !self.isTracking) {
                CGFloat lower = self.lowerProgress;
                CGFloat upper = self.topWindowDismissTranstionStyle == PKWindowDismissTransitionStyleRequireConfirm ? CGFLOAT_MAX : self.upperProgress;
                CGFloat k = self.topWindowDismissTranstionStyle == PKWindowDismissTransitionStyleRequireConfirm ? 10 : 5;
                
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

#pragma mark - Animation

- (void)setStack:(BOOL)stack
{
    
}

- (void)setLink:(BOOL)link
{
    
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
                if (self.lowerProgress < transitionProgress) {
                    status = PKWindowManagerStatusList;
                } else {
                    status = PKWindowManagerStatusDefault;
                }
            }
            break;
        }
        case PKWindowManagerStatusConfirm:
        {
            status = PKWindowManagerStatusDefault;
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
                
                if (self.topWindowDismissTranstionStyle == PKWindowDismissTransitionStyleRequireConfirm) {
                    status = PKWindowManagerStatusConfirm;
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
            [self animation].toValue = @(0);
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
        case PKWindowManagerStatusConfirm:
        {
            
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
    CGFloat height = POPTransition(transitionProgress, 0, [UIScreen mainScreen].bounds.size.height) - POPTransition(progress, 0, interval * (self.numberOfWindowsInManager - 1 - i));
    return CGPointMake(0, height);
}

- (CGPoint)positionForWindow:(PKWindow *)window progress:(CGFloat)transitionProgress unitProgress:(CGFloat)unitProgress
{
    NSUInteger i = [self indexOfWindow:window];
    CGFloat progress = transitionProgress/[self progressToListStatus];
    CGFloat intervalToProgress = POPTransition((1 - unitProgress), 0, interval);
    CGFloat height = POPTransition(transitionProgress, 0, [UIScreen mainScreen].bounds.size.height) - POPTransition(progress, 0, intervalToProgress * (self.numberOfWindowsInManager - 1 - i));
    return CGPointMake(0, height);
}

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    
    [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat yPosition = [self positionForWindow:window progress:transitionProgress].y;
        POPLayerSetTranslationY(window.layer, yPosition);
    }];
    
    /*
    
    if (self.status == PKWindowManagerStatusDismiss) {
        PKWindow *window = self.topWindow;
        CGFloat yPosition = [self positionForWindow:window progress:(1 - transitionProgress)].y;
        POPLayerSetTranslationY(window.layer, yPosition);
        return;
    }
    
    if (self.stacking) {
        PKWindow *window = self.topWindow;
        CGFloat yPosition = [self positionForWindow:window progress:transitionProgress].y;
        [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
            POPLayerSetTranslationY(window.layer, yPosition);
        }];
        return;
    }
    
    if (self.isAnimating) {
        PKWindow *window = self.topWindow;
        CGFloat yPosition = [self positionForWindow:window progress:transitionProgress].y;
        POPLayerSetTranslationY(window.layer, yPosition);
    } else {
        [self setLinkTransitionProgress:transitionProgress];
        [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat yPosition = [self positionForWindow:window progress:transitionProgress].y;
            POPLayerSetTranslationY(window.layer, yPosition);
        }];
    }
     */
}


- (void)setTransitionProgress:(CGFloat)transitionProgress selectIndex:(NSInteger)index
{
    _transitionProgress = transitionProgress;
    
    [self.windows enumerateObjectsUsingBlock:^(PKWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat progressToListStatus = [self progressToListStatus];
        CGFloat progress = (index < idx) ? transitionProgress :  POPTransition(transitionProgress, progressToListStatus, 0);
        CGFloat yPosition = [self positionForWindow:window progress:progress].y;
        POPLayerSetTranslationY(window.layer, yPosition);
    }];
}

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
            [self animation].toValue = @(0);
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
        case PKWindowManagerStatusConfirm:
        {
            
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

- (POPBasicAnimation *)unitAnimation
{
    POPBasicAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.window.unit"];
    if (!animation) {
        animation = [POPBasicAnimation easeOutAnimation];
        animation.duration = 0.32f;
        animation.property = self.unitAnimatableProperty;
        animation.delegate = self;
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.window.unit"];
    }
    return animation;
}

- (POPAnimatableProperty *)unitAnimatableProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.window.unit" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj unitTransitionProgress];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            //[obj setStackTransitionProgress:values[0]];
        };
        prop.threshold = 0.01;
    }];
    return prop;
}
- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    _decelerating = NO;
    if (finished) {
        
    }
}

@end
