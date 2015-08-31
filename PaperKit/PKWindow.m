//
//  PKWindow.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKWindow.h"
#import "PKPanGestureRecognizer.h"

@class PKViewController;
@interface PKWindow () <UIGestureRecognizerDelegate>

@property (nonatomic) PKPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;


@end

@implementation PKWindow

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    
    self.backgroundColor = [UIColor blackColor];
    self.opaque = YES;
    
    self.layer.cornerRadius = 4.0f;
    /*
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.25f;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    */
    self.windowLevel = UIWindowLevelStatusBar + 1;
    self.panGestureRecognizer = [[PKPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    self.panGestureRecognizer.scrollDirection = PKPanGestureRecognizerDirectionVertical;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
}


- (void)makeKeyAndVisible:(BOOL)animated
{
    if (animated) {
        [super makeKeyAndVisible];
    }
    else {
        [super makeKeyAndVisible];
    }
}


#pragma mark - TapGestureRecognizer

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    [self.manager window:self tapGesture:recognizer];
}

#pragma mark - PanGestureRecognizer

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    [self.manager window:self panGesture:recognizer];
}

#pragma mark - Gesture delegate

- (BOOL)gestureRecognizerShouldBegin:(nonnull UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.tapGestureRecognizer) {
        if ([self.manager window:self shouldGesture:gestureRecognizer]) {
            return YES;
        }
        return NO;
    }
    return YES;
}


@end