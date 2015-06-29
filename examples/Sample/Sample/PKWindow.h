//
//  PKWindow.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaperKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

typedef NS_ENUM(NSInteger, PKWindowState) {
    PKWindowStateNormal = 0,
    PKWindowStateList,
    PKWindowStateOpen,
    PKWindowStateDismiss
};

@interface PKWindow : UIWindow

@property (nonatomic) PKWindowState state;
@property (nonatomic) CGFloat transitionProgress;

@end
