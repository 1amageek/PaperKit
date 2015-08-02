//
//  PKPreviewView.m
//  PaperKit
//
//  Created by Norikazu on 2015/07/28.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKPreviewView.h"
#import <CoreMotion/CoreMotion.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>
#define LOWPASS_FILTER_ALPHA 0.9


@interface PKPreviewView () <UIScrollViewDelegate>
@property (nonatomic) CMMotionManager *motionManger;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) CGFloat zoomScaleProgress;
@end

@implementation PKPreviewView
{
    CGFloat _previousValue;
    CGPoint _fromPoisition;
    CGFloat _fromZoomScale;
}


- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nonnull instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self _commonInit];
        [self setImage:image];
    }
    return self;
}

- (void)_commonInit
{
    
    _previousValue = 0;
    _zoomScaleProgress = 0;
    _zoomScale = 1;
    _maximumZoomScale = 2;
    _minimumZoomScale = 1;

    _contentMode = PKPreviewViewContentModeScaleAspectFill;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    self.clipsToBounds = YES;
    [self addGestureRecognizer:_tapGestureRecognizer];
    [self addSubview:self.imageView];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(nonnull UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - ImageView

- (UIImageView *)imageView
{
    if (_imageView) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = NO;
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (image) {
        
        CGSize fillSize = [self sizeThatSize:image.size contentMode:PKPreviewViewContentModeScaleAspectFill];
        CGSize fitSize = [self sizeThatSize:image.size contentMode:PKPreviewViewContentModeScaleAspectFit];
        
        self.minimumZoomScale = fitSize.width/fillSize.width;

        self.imageView.frame = (CGRect){CGPointZero, fillSize};
        self.imageView.image = image;
        self.imageView.center = self.center;
        
        [self.imageView setNeedsDisplay];
    }
}

#pragma mark - GestureRecognizer

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{

    NSValue *toProgress;
    switch (self.contentMode) {
        case PKPreviewViewContentModeScaleAspectFit:
            self.contentMode = PKPreviewViewContentModeScaleAspectFill;
            _fromZoomScale = 1;
            _fromPoisition = self.center;
            toProgress = @(0);
            break;
        case PKPreviewViewContentModeScaleAspectFill:
        default:
            self.contentMode = PKPreviewViewContentModeScaleAspectFit;
            _fromZoomScale = self.zoomScale;
            _fromPoisition = self.imageView.layer.position;
            toProgress = @(1);
            if (self.motionManger.deviceMotionActive) {
                [self.motionManger stopDeviceMotionUpdates];
            }
            break;
    }

    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.previewView.zoom"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.previewView.zoom.property" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj zoomScaleProgress];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setZoomScaleProgress:values[0]];
            };
            prop.threshold = 0.01;
        }];
        
        animation.property = propX;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            if (finished) {
                if (self.contentMode == PKPreviewViewContentModeScaleAspectFill) {
                    [self startMotion];
                }
            }
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.previewView.zoom"];
    }
    animation.toValue = toProgress;
}

- (void)setZoomScaleProgress:(CGFloat)zoomScaleProgress
{
    _zoomScaleProgress = zoomScaleProgress;
    
    CGFloat scale = POPTransition(zoomScaleProgress, _fromZoomScale, self.minimumZoomScale);
    POPLayerSetScaleXY(self.imageView.layer, CGPointMake(scale, scale));
    [self setZoomScale:scale];
    
    CGFloat positionX = POPTransition(zoomScaleProgress, _fromPoisition.x, self.center.x);
    self.imageView.layer.position = CGPointMake(positionX, self.imageView.layer.position.y);
    
}

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

#pragma mark - MotionManager

- (CMMotionManager *)motionManger
{
    if (_motionManger) {
        return _motionManger;
    }
    
    _motionManger = [CMMotionManager new];
    return _motionManger;
}

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue) {
        return _operationQueue;
    }
    _operationQueue = [NSOperationQueue new];
    return _operationQueue;
}

- (void)startMotion
{
    if (self.contentMode == PKPreviewViewContentModeScaleAspectFill) {
        if (!self.motionManger.deviceMotionActive) {
            if (self.motionManger.deviceMotionAvailable) {
                self.motionManger.deviceMotionUpdateInterval = 0.01;
                
                [self.motionManger startDeviceMotionUpdatesToQueue:self.operationQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                    if (error) {
                        return;
                    }
                    if (motion) {
                        
                        CGFloat rotationRateY = floorf(motion.rotationRate.y * 1000)/100;
                        CGFloat translationX = [self lowPassFilter:(rotationRateY)];
                        CGFloat pointX = self.imageView.center.x + translationX;
                        
                        pointX = (CGRectGetMidX(self.imageView.bounds) < pointX) ? CGRectGetMidX(self.imageView.bounds) : pointX;
                        pointX = (pointX < self.bounds.size.width - CGRectGetMidX(self.imageView.bounds)) ? self.bounds.size.width - CGRectGetMidX(self.imageView.bounds) : pointX;
                        
                        CGPoint translation = CGPointMake(pointX, self.imageView.center.y);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.center = translation;
                        });
                    }
                }];
            }
        }
    }
}

- (void)stopMotion
{
    if (self.motionManger.deviceMotionActive) {
        [self.motionManger stopDeviceMotionUpdates];
    }
    [self resetOffset];
}

- (void)resetOffset
{
    
    if (self.contentMode == PKPreviewViewContentModeScaleAspectFill) {
        POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.previewView.resetOffset"];
        if (!animation) {
            animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
            [self.imageView.layer pop_addAnimation:animation forKey:@"inc.stamp.pk.previewView.resetOffset"];
        }
        animation.toValue = @(self.center.x);
    }
    
    if (self.contentMode == PKPreviewViewContentModeScaleAspectFit) {
        self.contentMode = PKPreviewViewContentModeScaleAspectFill;
        _fromZoomScale = 1;
        _fromPoisition = self.center;
        POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.previewView.zoom"];
        if (!animation) {
            animation = [POPSpringAnimation animation];
            POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.previewView.zoom.property" initializer:^(POPMutableAnimatableProperty *prop) {
                prop.readBlock = ^(id obj, CGFloat values[]) {
                    values[0] = [obj zoomScaleProgress];
                };
                prop.writeBlock = ^(id obj, const CGFloat values[]) {
                    [obj setZoomScaleProgress:values[0]];
                };
                prop.threshold = 0.01;
            }];
            
            animation.property = propX;
            [self pop_addAnimation:animation forKey:@"inc.stamp.pk.previewView.zoom"];
        }
        animation.toValue = @(0);
    }
    
}

#pragma mark - util

- (CGFloat)lowPassFilter:(CGFloat)value
{
    CGFloat currentValue = _previousValue * LOWPASS_FILTER_ALPHA;
    currentValue += (1 - LOWPASS_FILTER_ALPHA) * value;
    _previousValue = currentValue;
    return currentValue;
}

- (CGSize)sizeThatSize:(CGSize)size contentMode:(PKPreviewViewContentMode)contentMode
{
    CGSize imageViewSize;
    CGSize viewSize = self.bounds.size;
    CGFloat aspectRatio = size.width/size.height;
    CGFloat _aspectRatio = viewSize.width/viewSize.height;
    
    switch (contentMode) {
        case PKPreviewViewContentModeScaleAspectFit:
            
            if (aspectRatio < _aspectRatio) {
                imageViewSize = CGSizeMake(viewSize.height * aspectRatio, viewSize.height);
            } else {
                imageViewSize = CGSizeMake(viewSize.width, viewSize.width / aspectRatio);
            }
            
            break;
        case PKPreviewViewContentModeScaleAspectFill:
        default:
            
            if (aspectRatio < _aspectRatio) {
                imageViewSize = CGSizeMake(viewSize.width, viewSize.width / aspectRatio);
            } else {
                imageViewSize = CGSizeMake(viewSize.height * aspectRatio, viewSize.height);
            }
            
            break;
    }
    
    if (viewSize.height < imageViewSize.height) {
        imageViewSize = CGSizeMake(viewSize.height * aspectRatio, viewSize.height);
    }
    
    return imageViewSize;
}


@end
