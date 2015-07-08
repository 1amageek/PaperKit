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
@property (nonatomic) UIButton *reloadForegroundButton;
@property (nonatomic) UIButton *reloadbackgroundButton;
@property (nonatomic) NSArray *backgroundData;
@property (nonatomic) NSArray *foregroundData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backgroundData = @[@"0"];
    _foregroundData = @[@"0",@"1",@"2",@"3",@"4"];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    _reloadForegroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_reloadForegroundButton setTitle:@"reload foreground" forState:UIControlStateNormal];
    [_reloadForegroundButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_reloadForegroundButton sizeToFit];
    _reloadForegroundButton.center = CGPointMake(self.view.center.x, self.view.center.x - 30);
    [self.view addSubview:_reloadForegroundButton];
    
    _reloadbackgroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_reloadbackgroundButton setTitle:@"reload background" forState:UIControlStateNormal];
    [_reloadbackgroundButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_reloadbackgroundButton sizeToFit];
    _reloadbackgroundButton.center = CGPointMake(self.view.center.x, self.view.center.x + 30);
    [self.view addSubview:_reloadbackgroundButton];
    
}

- (void)tapped:(UIButton *)button
{
    if (button == _reloadbackgroundButton) {
        _backgroundData = @[@"0",@"1",@"2"];
        [self reloadBackgroundData];
    }
    
    if (button == _reloadForegroundButton) {
        _foregroundData = @[@"0",@"1",@"2"];
        [self reloadForegroundDataOnCategory:self.selectedCategory];
    }
    
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
    return _backgroundData.count;
}

- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section onCategory:(NSInteger)category
{
    return _foregroundData.count;
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
