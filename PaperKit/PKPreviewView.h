//
//  PKPreviewView.h
//  PaperKit
//
//  Created by Norikazu on 2015/07/28.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PKPreviewViewContentMode)
{
    PKPreviewViewContentModeScaleAspectFit = 0,
    PKPreviewViewContentModeScaleAspectFill
};

@interface PKPreviewView : UIScrollView

@property (nonatomic) PKPreviewViewContentMode contentMode; // default PKPreviewViewContentModeScaleAspectFill
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImageView *imageView;

- (nonnull instancetype)initWithImage:(UIImage *)image;

@end
