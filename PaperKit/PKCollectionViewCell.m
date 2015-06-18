//
//  PKCollectionViewCell.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewCell.h"

@implementation PKCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.transtionProgress = 0;
    }
    return self;
}

- (void)setTranstionProgress:(CGFloat)transtionProgress
{
    _transtionProgress = transtionProgress;
    if (transtionProgress == 1) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
}

@end
