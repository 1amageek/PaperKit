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
@property (nonatomic) UIButton *reloadBackgroundButton;
@property (nonatomic) UIButton *insertForegroundButton;

@property (nonatomic) NSArray *backgroundData;
@property (nonatomic) NSArray *foregroundData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backgroundData = @[@"0",@"1",@"2"];
    _foregroundData = @[@"0",@"1",@"2",@"3",@"4",@"5"];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    _reloadForegroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_reloadForegroundButton setTitle:@"reload foreground" forState:UIControlStateNormal];
    [_reloadForegroundButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_reloadForegroundButton sizeToFit];
    _reloadForegroundButton.center = CGPointMake(self.view.center.x, self.view.center.x - 60);
    [self.view addSubview:_reloadForegroundButton];
    
    _reloadBackgroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_reloadBackgroundButton setTitle:@"reload background" forState:UIControlStateNormal];
    [_reloadBackgroundButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_reloadBackgroundButton sizeToFit];
    _reloadBackgroundButton.center = CGPointMake(self.view.center.x, self.view.center.x - 30);
    [self.view addSubview:_reloadBackgroundButton];
    
    _insertForegroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_insertForegroundButton setTitle:@"insert foreground" forState:UIControlStateNormal];
    [_insertForegroundButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_insertForegroundButton sizeToFit];
    _insertForegroundButton.center = CGPointMake(self.view.center.x, self.view.center.x);
    [self.view addSubview:_insertForegroundButton];
    
}

- (void)tapped:(UIButton *)button
{
    if (button == _reloadBackgroundButton) {
        _backgroundData = @[@"0",@"1",@"2"];
        [self reloadBackgroundData];
    }
    
    if (button == _reloadForegroundButton) {
        _foregroundData = @[@"0",@"1",@"2",@"3",@"4"];
        [self reloadForegroundDataOnCategory:self.selectedCategory];
    }
    
    if (button == _insertForegroundButton) {
        
        NSMutableArray *dataSource = [NSMutableArray arrayWithArray:_foregroundData];
        [dataSource addObject:@"insert"];
        [dataSource addObject:@"insert"];
        [dataSource addObject:@"insert"];
        [dataSource addObject:@"insert"];
        _foregroundData = dataSource;
        
        NSMutableArray *insertIndexPaths = @[].mutableCopy;
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:1 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:2 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:3 inSection:0]];

        
        
        [self foregroundCollectionViewOnCategory:self.selectedCategory performBatchUpdates:^(PKCollectionViewController *controller){
            [controller.collectionView insertItemsAtIndexPaths:insertIndexPaths];
        } completion:^(BOOL finished) {
            [self.view setNeedsLayout];
        }];
        
    }
    
}

- (void)insertForegroundData:(NSArray *)array
{
    
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
