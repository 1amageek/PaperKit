//
//  PKCollectionViewCell.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewCell.h"

@implementation PKCollectionViewCell

static CGFloat IS_CONTENTOFFSET_ZERO_THRESHOLD = 20.0f;

- (void)setTranstionProgress:(CGFloat)transtionProgress
{
    _transtionProgress = transtionProgress;
    self.viewController.transtionProgress = transtionProgress;
    
    if (1 <= transtionProgress) {
        self.viewController.view.userInteractionEnabled = YES;
    } else {
        self.viewController.view.userInteractionEnabled = NO;
    }
}

@end
