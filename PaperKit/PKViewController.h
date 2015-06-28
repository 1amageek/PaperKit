//
//  PKViewController.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKContentViewController.h"
#import "PKCollectionViewController.h"
#import "PKPanGestureRecognizer.h"

@interface PKViewController : UIViewController

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic, readonly) NSUInteger selectedCategory;


- (void)categoryWillSet:(NSUInteger)currentCategory nextCategory:(NSUInteger)nextCategory;
- (void)categoryDidSet:(NSUInteger)category;

// background Collection View
- (NSInteger)backgroundCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)backgroundCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

// foreground Collection View
- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (PKContentViewController *)foregroundCollectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath onCategory:(NSUInteger)category;

@end
