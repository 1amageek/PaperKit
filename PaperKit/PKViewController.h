//
//  PKViewController.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKToolbar.h"
#import "PKContentViewController.h"
#import "PKCollectionViewController.h"
#import "PKPanGestureRecognizer.h"

@interface PKViewController : UIViewController

/*
 Collection View Zoom scale
 */

@property (nonatomic) CGFloat minimumZoomScale;     // default 0.45
@property (nonatomic) CGFloat maximumZoomScale;     // default 1

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic, readonly) NSUInteger selectedCategory;
@property (nonatomic) PKToolbar *toolbar;


- (void)categoryWillSet:(NSUInteger)currentCategory nextCategory:(NSUInteger)nextCategory;
- (void)categoryDidSet:(NSUInteger)category;

- (PKCollectionViewController *)foregroundViewControllerAtIndex:(NSInteger)category;

// background Collection View
- (NSInteger)numberOfSectionsInBackgroundCollectionView:(UICollectionView *)collectionView;
- (NSInteger)backgroundCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)backgroundCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// foreground Collection View
- (NSInteger)numberOfSectionsInForegroundCollectionView:(UICollectionView *)collectionView onCategory:(NSInteger)category;
- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section onCategory:(NSInteger)category;
- (PKContentViewController *)foregroundCollectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath onCategory:(NSUInteger)category;


// action
- (void)scrollView:(UIScrollView *)scrollView slideToAction:(PKCollectionViewControllerScrollDirection)direction;


// reload
- (void)reloadBackgroundData;
- (void)reloadForegroundDataOnCategory:(NSInteger)category;

- (void)foregroundCollectionViewOnCategory:(NSInteger)category performBatchUpdates:(void (^)(PKCollectionViewController *controller))updates completion:(void (^)(BOOL finished))completion;

@end
