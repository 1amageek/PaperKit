//
//  PKToolbar.m
//  Sample
//
//  Created by Norikazu on 2015/07/12.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKToolbar.h"

@implementation PKToolbar

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
        [self setBackgroundColor:[UIColor clearColor]];
        self.tintColor = [UIColor whiteColor];
    }
    return self;
}

@end
