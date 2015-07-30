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


@interface PKPreviewView ()
@property (nonatomic) CMMotionManager *motionManger;
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation PKPreviewView
{
    CGFloat _previousValue;
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
    
    
    // scrollView
    self.maximumZoomScale = 2;
    self.bouncesZoom = YES;
    self.backgroundColor = [UIColor blackColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    _contentMode = PKPreviewViewContentModeScaleAspectFill;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
    [self addSubview:self.imageView];
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
        
        self.contentSize = self.imageView.bounds.size;
        CGFloat contentOffsetX = self.imageView.bounds.size.width/2 - self.bounds.size.width/2;
        self.contentOffset = CGPointMake(contentOffsetX, 0);
        
        [self.imageView setNeedsDisplay];
    }
}

#pragma mark - GestureRecognizer

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    
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
    if (!self.motionManger.deviceMotionActive) {
        if (self.motionManger.deviceMotionAvailable) {
            self.motionManger.deviceMotionUpdateInterval = 0.01;
            
            [self.motionManger startDeviceMotionUpdatesToQueue:self.operationQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                if (error) {
                    return;
                }
                if (motion) {
                    
                    // FIXME
                    CGFloat rotationRateY = floorf(motion.rotationRate.y * 1000)/80;
                    CGFloat translation = [self lowPassFilter:(rotationRateY)];
                    CGFloat offsetX = (self.contentOffset.x + translation);
                    CGFloat maxOffsetX = (self.contentSize.width - self.bounds.size.width);
                    offsetX = offsetX < 0 ? 0 : offsetX;
                    offsetX = maxOffsetX < offsetX ? maxOffsetX : offsetX;
                    
                    CGPoint contentOffset = CGPointMake(offsetX, self.contentOffset.y);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setContentOffset:contentOffset];
                    });
                }
            }];
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
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.previewView.contentOffset"];
    if (!animation) {
        animation = [POPSpringAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.previewView.contentOffset"];
    }
    CGFloat contentOffsetX = self.imageView.bounds.size.width/2 - self.bounds.size.width/2;
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(contentOffsetX, 0)];
    
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
