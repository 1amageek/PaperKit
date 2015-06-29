//
//  PKCollectionViewCell.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewCell.h"

@implementation PKCollectionViewCell

- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    _transitionProgress = transitionProgress;
    self.viewController.transitionProgress = transitionProgress;
    
    if (1 <= transitionProgress) {
        self.viewController.view.userInteractionEnabled = YES;
    } else {
        self.viewController.view.userInteractionEnabled = NO;
    }
}

@end
