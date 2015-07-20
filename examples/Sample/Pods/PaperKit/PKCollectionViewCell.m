//
//  PKCollectionViewCell.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewCell.h"
#import <POP.h>
#import <POPLayerExtras.h>

@interface PKCollectionViewCell ()

@property (nonatomic) POPAnimation *animation;

@end

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

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    if ([layoutAttributes isKindOfClass:[PKCollectionViewLayoutAttributes class]]) {
        PKCollectionViewLayoutAttributes *attr = (PKCollectionViewLayoutAttributes *)layoutAttributes;
        if (attr.animation) {
            self.animation = attr.animation;
            attr.animation.delegate = self;
            [self.layer pop_addAnimation:attr.animation forKey:@"inc.stamp.cell.update.translationX"];
        }
        [self setNeedsDisplay];
    }
}

- (void)pop_animationDidStart:(POPAnimation *)anim
{
    self.alpha = 1;
}

@end
