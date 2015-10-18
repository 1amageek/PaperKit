//
//  PKCollectionViewCell.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>
#import "PKCollectionViewFlowLayout.h"
#import "PKContentViewController.h"

@interface PKCollectionViewCell : UICollectionViewCell <POPAnimationDelegate>

@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic, weak, nullable) PKContentViewController *viewController;

@end
