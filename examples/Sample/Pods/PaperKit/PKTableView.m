//
//  PKTableView.m
//  Pods
//
//  Created by Norikazu on 2015/06/28.
//
//

#import "PKTableView.h"

@implementation PKTableView

static CGFloat IS_CONTENTOFFSET_ZERO_THRESHOLD = 20.0f;
- (BOOL)gestureRecognizerShouldBegin:(nonnull UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [panGestureRecognizer translationInView:gestureRecognizer.view];
        
        if (self.contentOffset.y < IS_CONTENTOFFSET_ZERO_THRESHOLD && translation.y > 0) {
            return NO;
        }
    }
    return YES;
}
@end
