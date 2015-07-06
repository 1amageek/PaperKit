//
//  ViewController.m
//  Sample
//
//  Created by Norikazu on 2015/06/27.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)categoryWillSet:(NSUInteger)currentCategory nextCategory:(NSUInteger)nextCategory
{
    
}

- (void)categoryDidSet:(NSUInteger)category
{
    
}

- (NSInteger)backgroundCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 15;
}

- (UICollectionViewCell *)backgroundCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CGFloat color = floorf(indexPath.item)/[self backgroundCollectionView:collectionView numberOfItemsInSection:indexPath.section];

    CGFloat saturation = floorf([[UIApplication sharedApplication].windows indexOfObject:(UIWindow *)self.view.superview])/[UIApplication sharedApplication].windows.count;
    cell.backgroundColor = [UIColor colorWithHue:color saturation:saturation brightness:1 alpha:1];
    return cell;
}

- (PKContentViewController *)foregroundCollectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath onCategory:(NSUInteger)category
{
    //NSLog(@"indexPaht %@ cateogry %lu",indexPath, (unsigned long)category);
    return [ContentViewController new];
}


@end
