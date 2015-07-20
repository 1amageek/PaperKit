//
//  PKWindow.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

typedef NS_ENUM(NSInteger, PKWindowState) {
    PKWindowStateNormal = 0,
    PKWindowStateList,
    PKWindowStateOpen,
    PKWindowStateDismiss
};

@protocol PKWindowDelegate;
@interface PKWindow : UIWindow

@property (nonatomic) PKWindowState state;
@property (nonatomic, weak) id <PKWindowDelegate> manager;
@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) CGFloat globalProgress;
@property (nonatomic) CGFloat interval;
@property (nonatomic) BOOL link;

- (void)makeKeyAndVisible:(BOOL)animated;
- (void)dissmis;

@end

@protocol PKWindowDelegate <NSObject>
@required
- (void)windowWillAppear:(PKWindow *)window;
- (void)windowDidAppear:(PKWindow *)window;
- (void)windowDidDisappear:(PKWindow *)window;

- (NSArray *)windowsOnBaseWindow;

@end