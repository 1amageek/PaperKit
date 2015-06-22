//
//  PKPanGestureRecognizer.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKPanGestureRecognizer.h"

@implementation PKPanGestureRecognizer


- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.scrollDirection = PKPanGestureRecognizerDirectionEvery;
    }
    
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];
    
    if (self.state == UIGestureRecognizerStatePossible) {
        
        
        CGFloat x = fabs(nowPoint.x - prevPoint.x);
        CGFloat y = fabs(nowPoint.y - prevPoint.y);
        
        BOOL comp = NO;
        
        switch (self.scrollDirection) {
                
                
            case PKPanGestureRecognizerDirectionVertical:
                // 横のスクロールと判断するとFailedにする
                comp = y < x;
                break;
            case PKPanGestureRecognizerDirectionHorizontal:
                // 縦のスクロールと判断するとFailedにする
                comp = x < y;
                break;
            case PKPanGestureRecognizerDirectionEvery:
            default:
                // 全方向でFaildにしない
                break;
        }
        
        if (comp) {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
        
    }
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) return;
}

- (BOOL)canPreventGestureRecognizer:(nonnull UIGestureRecognizer *)preventedGestureRecognizer
{
    if ([preventedGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}


@end
