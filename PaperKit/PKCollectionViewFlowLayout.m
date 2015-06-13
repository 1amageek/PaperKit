//
//  PKCollectionViewFlowLayout.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewFlowLayout.h"

@implementation PKCollectionViewLayoutAttributes


@end


@interface PKCollectionViewFlowLayout ()

@property (nonatomic) NSMutableArray *insertPaths;
@property (nonatomic) NSMutableArray *deletePaths;

@end

@implementation PKCollectionViewFlowLayout
{
    CGSize _myCollectionViewSize;
    NSMutableDictionary *_attributes;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    [_attributes removeAllObjects];
    
    CGFloat contentSizeWidth = 0;
    CGFloat contentSizeHeight = 0;
    CGFloat originX = 0;
    CGFloat originY = 0;
    
    contentSizeHeight = self.sectionInset.top + self.sectionInset.bottom + self.itemSize.height;
    contentSizeWidth = self.sectionInset.right;
    
    originX += self.sectionInset.left;
    originY += self.sectionInset.top;
    
    NSInteger sections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section ++) {
        
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < items; item ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            PKCollectionViewLayoutAttributes *attr = [PKCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
            
            originX += self.itemSize.width;
            originX += self.minimumInteritemSpacing;
            originY += 0;
            
            _attributes[indexPath] = attr;
            
        }
    }
    
    contentSizeWidth += (originX - self.minimumInteritemSpacing);
    _myCollectionViewSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
    _zoomScale = [self.delegate layoutZoomScale];
    
    //self.collectionView.frame = (CGRect){self.collectionView.frame.origin, CGSizeMake(ceilf(_myCollectionViewSize.width * _zoomScale), _myCollectionViewSize.height)};
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _attributes[indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSMutableArray *attributes = [NSMutableArray array];
    NSInteger sections = [self.collectionView numberOfSections];
    
    UIView *scrollView = self.collectionView.superview;
    
    for (NSInteger section = 0; section < sections; section ++) {
        
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < items; item ++) {
            
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            
            
            //CollectionViewが重い場合はVisibleCellの最適化が必要。
            //今のところここをいじるScrollViewにあるVisibleCellの処理でフレームオチを回避している
            
            CGRect frameOnScrollView = [self.collectionView convertRect:attribute.frame toView:scrollView];
            CGRect frame = [scrollView convertRect:frameOnScrollView fromView:scrollView.superview];
            CGRect rengeRect = [UIScreen mainScreen].bounds;
            //rengeRect.origin.x -= [UIScreen mainScreen].bounds.size.width;
            //rengeRect.size.width += ([UIScreen mainScreen].bounds.size.width * 2);
            
            BOOL intersetsRect = CGRectIntersectsRect(rengeRect, frame);
            if (intersetsRect) {
                [attributes addObject:attribute];
            }
            
            //[attributes addObject:attribute];
            
        }
        
    }
    return attributes;
}


- (CGSize)collectionViewContentSize
{
    return _myCollectionViewSize;
}

- (CGSize)calculateSize
{
    CGSize size;
    
    CGFloat contentSizeWidth = 0;
    CGFloat contentSizeHeight = 0;
    CGFloat originX = 0;
    CGFloat originY = 0;
    
    contentSizeHeight = self.sectionInset.top + self.sectionInset.bottom + self.itemSize.height;
    contentSizeWidth = self.sectionInset.right;
    
    originX += self.sectionInset.left;
    originY += self.sectionInset.top;
    
    NSInteger sections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section ++) {
        
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < items; item ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
            
            originX += self.itemSize.width;
            originX += self.minimumInteritemSpacing;
            originY += 0;
            
            _attributes[indexPath] = attr;
            
        }
    }
    
    contentSizeWidth += (originX - self.minimumInteritemSpacing);
    size = CGSizeMake(contentSizeWidth, contentSizeHeight);
    
    return size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    CGPoint point = [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
    
    if (self.selectedIndexPath) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width + self.minimumInteritemSpacing;
        CGFloat horizontal = 0;
        for (NSUInteger section = 0; section < self.selectedIndexPath.section; section++) {
            horizontal -= (width * [self.collectionView numberOfItemsInSection:section]);
        }
        
        horizontal -= (self.selectedIndexPath.item * width) + self.sectionInset.left;
        
        return CGPointMake(horizontal, point.y);
    }
    
    return point;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    
    NSIndexPath *previousIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(proposedContentOffset.x - self.itemSize.width, proposedContentOffset.y)];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:proposedContentOffset];
    NSIndexPath *nextIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(proposedContentOffset.x + self.itemSize.width, proposedContentOffset.y)];
    
    if (!previousIndexPath) {
        previousIndexPath = indexPath;
    }
    
    if (!nextIndexPath) {
        nextIndexPath = indexPath;
    }
    
    
    CGFloat thresholdX = fabs(velocity.x);
    
    if (100 < thresholdX) {
        if (velocity.x < 0) {
            indexPath = nextIndexPath;
        } else {
            indexPath = previousIndexPath;
        }
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    return CGPointMake(-cell.frame.origin.x, -cell.frame.origin.y);
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    
    [super prepareForCollectionViewUpdates:updateItems];
    self.insertPaths = @[].mutableCopy;
    self.deletePaths = @[].mutableCopy;
    
    for (UICollectionViewUpdateItem *item in updateItems) {
        if (item.updateAction == UICollectionUpdateActionInsert) {
            [self.insertPaths addObject:item.indexPathAfterUpdate];
        } else if (item.updateAction == UICollectionUpdateActionDelete) {
            [self.deletePaths addObject:item.indexPathBeforeUpdate];
        }
    }
    
}


@end
