//
//  PKCollectionViewController.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <POP.h>
#import <POP/POPLayerExtras.h>
#import "PKScrollView.h"
#import "PKCollectionView.h"
#import "PKContentScrollView.h"
#import "PKContentCollectionView.h"
#import "PKCollectionViewCell.h"
#import "PKCollectionViewFlowLayout.h"
#import "PKPanGestureRecognizer.h"

@protocol PKCollectionViewControllerDelegate;
@interface PKCollectionViewController : UIViewController

@property (nonatomic) PKContentCollectionView *collectionView;
@property (nonatomic) PKCollectionViewFlowLayout *layout;
@property (nonatomic) PKContentScrollView *scrollView;
@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) PKPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGFloat zoomScale;
@property (nonatomic) BOOL pagingEnabled;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic, weak) id <PKCollectionViewControllerDelegate> delegate;


- (NSArray *)visibleCells;
- (NSArray *)indexPathsForVisibleItems;
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;
- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

@end

@protocol PKCollectionViewControllerDelegate <NSObject>
@required
- (void)viewController:(PKCollectionViewController *)viewController didChangeTransitionProgress:(CGFloat)transitionProgress;
@end