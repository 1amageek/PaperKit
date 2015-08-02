//
//  PKContentViewController.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/14.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKScrollView.h"

@interface PKContentViewController : UIViewController

@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic, readonly) BOOL isDisplayingInFullScreen;

- (void)viewDidDisplayInFullScreen; // Called after the animation end of scrollView of PKCollectionViewController. Do not call directly
- (void)viewDidEndDisplayingInFullScreen;   // Called when view is no longer in full-screen display. Do not call directly
- (void)viewControllerDidScroll:(UIScrollView *)scrollView; //PKCollectionViewController any offset changes.

@end
