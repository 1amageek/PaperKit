//
//  PKContentScrollView.m
//  Pods
//
//  Created by Norikazu on 2015/07/07.
//
//

#import "PKContentScrollView.h"

@implementation PKContentScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];

    if (self.subviews.count) {
        UIView *subView = self.subviews.firstObject;
        
        if (CGRectContainsPoint(subView.frame, point)) {
            return view;
        } else {
            return nil;
        }
    }
    return nil;
}


@end
