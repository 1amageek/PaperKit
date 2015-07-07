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
@property (nonatomic) UIButton *button;
@end

@implementation ViewController
{
    NSInteger _count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    _count = 2;
    _button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [_button addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [_button sizeToFit];
    _button.center = self.view.center;
    [self.view addSubview:_button];
    
}

- (void)tapped:(UIButton *)button
{
    PKCollectionViewController *controller = [self foregroundViewControllerAtIndex:self.selectedCategory];
    
    
    //[controller willMoveToParentViewController:self];
    //[controller.view removeFromSuperview];
    //[controller removeFromParentViewController];
    _count = 5;
    
    [controller reloadData];
    
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
    return 10;
}

- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section onCategory:(NSInteger)category
{
    return _count;
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
