//
//  PKScrollView.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKScrollView.h"

@implementation PKScrollView


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"began");
    if (!self.dragging) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"end");
    if (!self.dragging) {
        [self.nextResponder touchesEnded: touches withEvent:event];
    }
    [super touchesEnded: touches withEvent: event];
}


@end
