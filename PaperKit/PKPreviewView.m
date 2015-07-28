//
//  PKPreviewView.m
//  PaperKit
//
//  Created by Norikazu on 2015/07/28.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKPreviewView.h"
#import <CoreMotion/CoreMotion.h>

@implementation PKPreviewView


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
    _contentMode = PKPreviewViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
}

- (UIImageView *)imageView
{
    if (_imageView) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    CGSize size = [self sizeThatSize:image.size contentMode:self.contentMode];
    self.imageView.frame = (CGRect){CGPointZero, size};
    self.imageView.image = image;
    [self.imageView setNeedsDisplay];
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
