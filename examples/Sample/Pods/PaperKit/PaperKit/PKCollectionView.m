//
//  PKCollectionView.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionView.h"

@implementation PKCollectionView

static CGFloat IS_CONTENTOFFSET_ZERO_THRESHOLD = 20.0f;

- (BOOL)gestureRecognizerShouldBegin:(nonnull UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        //CGPoint location = [panGestureRecognizer locationInView:gestureRecognizer.view];
        CGPoint translation = [panGestureRecognizer translationInView:gestureRecognizer.view];
        
        if (self.contentOffset.y < IS_CONTENTOFFSET_ZERO_THRESHOLD && translation.y > 0) {
            return NO;
        }
    }
    return YES;
}

@end
