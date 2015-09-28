//
//  PKWindow.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PKWindowDelegate;
@interface PKWindow : UIWindow

@property (nonatomic, weak) id <PKWindowDelegate> manager;
@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) CGFloat globalProgress;
@property (nonatomic) CGFloat interval;

- (void)makeKeyAndVisible:(BOOL)animated;

@end

@protocol PKWindowDelegate <NSObject>

- (BOOL)window:(PKWindow *)window shouldGesture:(UIGestureRecognizer *)recognizer;
- (void)window:(PKWindow *)window tapGesture:(UITapGestureRecognizer *)recognizer;
- (void)window:(PKWindow *)window panGesture:(UIPanGestureRecognizer *)recognizer;

- (void)windowWillAppear;
- (void)windowDidAppear;
- (void)windowWillDisappear;
- (void)windowDidDisappear;

@end
