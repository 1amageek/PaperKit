//
//  CollectionViewController.m
//  Sample
//
//  Created by Norikazu on 2015/07/09.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "CollectionViewController.h"


@interface CollectionViewController ()

@property (nonatomic) NSMutableArray *dataSource;

@end

@implementation CollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataSource = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""].mutableCopy;
    
    
    _insertForegroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_insertForegroundButton setTitle:@"insert foreground" forState:UIControlStateNormal];
    [_insertForegroundButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_insertForegroundButton sizeToFit];
    _insertForegroundButton.center = CGPointMake(self.view.center.x, self.view.center.x);
    [self.view addSubview:_insertForegroundButton];
    [self reloadData];
}

- (void)tapped:(UIButton *)button
{

    
    if (button == _insertForegroundButton) {
        
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        [_dataSource addObject:@"insert"];
        
        NSMutableArray *insertIndexPaths = @[].mutableCopy;
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:1 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:2 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:3 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:4 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:5 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:6 inSection:0]];
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:7 inSection:0]];
        
        

        [self performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
        } completion:^(BOOL finished) {
        
        }];
        
    }
    
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PKCollectionViewCell *cell = (PKCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PKCollectionViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
    
}

@end
