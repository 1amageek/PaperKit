//
//  PKPanGestureRecognizer.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_ENUM(NSInteger, PKPanGestureRecognizerDirection)
{
    PKPanGestureRecognizerDirectionEvery,
    PKPanGestureRecognizerDirectionVertical,
    PKPanGestureRecognizerDirectionHorizontal
};

@interface PKPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) PKPanGestureRecognizerDirection scrollDirection; //default PKPanGestureRecognizerDirectionEvery

@end
