//
//  PKCollectionViewController.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>
#import "PKScrollView.h"
#import "PKCollectionView.h"
#import "PKContentScrollView.h"
#import "PKContentCollectionView.h"
#import "PKCollectionViewCell.h"
#import "PKCollectionViewFlowLayout.h"
#import "PKPanGestureRecognizer.h"

typedef NS_ENUM(NSInteger, PKCollectionViewControllerScrollDirection)
{
    PKCollectionViewControllerScrollDirectionPrevious,
    PKCollectionViewControllerScrollDirectionNext
};

@protocol PKCollectionViewControllerDelegate;
@interface PKCollectionViewController : UIViewController

@property (nonatomic) CGFloat minimumZoomScale;
@property (nonatomic) CGFloat maximumZoomScale;

@property (nonnull, nonatomic) PKCollectionViewFlowLayout *layout;
@property (nonnull, nonatomic) PKContentScrollView *scrollView;
@property (nonnull, nonatomic) PKContentCollectionView *collectionView;
@property (nonnull, nonatomic) UIColor *collectionViewBackgroundColor;

// Gesture
@property (nonnull, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonnull, nonatomic) PKPanGestureRecognizer *panGestureRecognizer;

// transition
@property (nonatomic) CGFloat transitionProgress;

@property (nonatomic) CGFloat zoomScale;
@property (nonatomic) BOOL pagingEnabled;
@property (nonnull, nonatomic) NSIndexPath *selectedIndexPath;
@property (nullable, nonatomic, weak) id <PKCollectionViewControllerDelegate> delegate;


- (nonnull NSArray *)visibleCells;
- (nonnull NSArray *)indexPathsForVisibleItems;
- (nonnull UICollectionViewCell *)cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)reloadData;
- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

@end

@protocol PKCollectionViewControllerDelegate <NSObject>


- (void)viewController:(nonnull PKCollectionViewController *)viewController didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath;

/*
 This methods is called when the scroll view was a gesture that exceeds the contentSize.
 */
- (void)viewController:(nonnull PKCollectionViewController *)viewController didEndTransitionAnimation:(BOOL)expand;
- (void)viewController:(nonnull PKCollectionViewController *)viewController slideToAction:(PKCollectionViewControllerScrollDirection)direction;
@required
- (void)viewController:(nonnull PKCollectionViewController *)viewController didChangeTransitionProgress:(CGFloat)transitionProgress;
@end