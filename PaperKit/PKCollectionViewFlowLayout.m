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
}

- (PKCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _attributes[indexPath];
}

- (CGSize)rengeSize
{
    return [self.delegate sizeOfRengeInCollectionView:self.collectionView];
}

- (CGRect)preheatRect
{
    CGRect preheatRect = [UIScreen mainScreen].bounds;
    preheatRect = CGRectInset(preheatRect, -2.0f * CGRectGetWidth(preheatRect), 0);
    return preheatRect;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    NSInteger sections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sections; section ++) {
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < items; item ++) {
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            UIView *view = self.collectionView.superview.superview;
            CGRect frame = [self.collectionView convertRect:attribute.frame toView:view];
            BOOL intersetsRect = CGRectIntersectsRect([self preheatRect], frame);
            if (intersetsRect) {
                [attributes addObject:attribute];
            }
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
    
    NSInteger sections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSInteger section = 0; section < sections; section ++) {
        NSInteger items = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < items; item ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
            
            originX += self.itemSize.width;
            originX += self.minimumInteritemSpacing;
            originY += 0;
        }
    }
    
    contentSizeWidth += (originX - self.minimumInteritemSpacing);
    size = CGSizeMake(contentSizeWidth, contentSizeHeight);
    
    return size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    CGPoint point = [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
    
    if (self.selectedIndexPath) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width + self.minimumInteritemSpacing;
        CGFloat horizontal = 0;
        for (NSUInteger section = 0; section < self.selectedIndexPath.section; section++) {
            horizontal += (width * [self.collectionView numberOfItemsInSection:section]);
        }
        horizontal += (self.selectedIndexPath.item * width) + self.sectionInset.left;
        return CGPointMake(horizontal, point.y);
    }
    
    return point;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    
    NSIndexPath *indexPath = self.selectedIndexPath;
    NSIndexPath *previousIndexPath = [self _previousIndexPath];
    NSIndexPath *nextIndexPath = [self _nextIndexPath];
    
    if (velocity.x < 0) {
        indexPath = previousIndexPath;
    } else if (0 < velocity.x) {
        indexPath = nextIndexPath;
    }
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return CGPointMake(cell.frame.origin.x, cell.frame.origin.y);
}

- (NSIndexPath *)_previousIndexPath
{
    if (self.selectedIndexPath.item == 0) {
        if (self.selectedIndexPath.section == 0) {
            return self.selectedIndexPath;
        } else {
            NSInteger section = self.selectedIndexPath.section - 1;
            NSInteger numberOfItem = [self.collectionView numberOfItemsInSection:section];
            return [NSIndexPath indexPathForItem:numberOfItem - 1 inSection:section];
        }
        
    } else {
        return [NSIndexPath indexPathForItem:self.selectedIndexPath.item - 1 inSection:self.selectedIndexPath.section];
    }
}

- (NSIndexPath *)_nextIndexPath
{
    NSInteger numberOfItem = [self.collectionView numberOfItemsInSection:self.selectedIndexPath.section];
    NSInteger numberOfSection = [self.collectionView numberOfSections];
    if ((numberOfItem - 1) == self.selectedIndexPath.item) {
        if ((numberOfSection - 1) == self.selectedIndexPath.section) {
            return self.selectedIndexPath;
        } else {
             NSInteger section = self.selectedIndexPath.section + 1;
            return [NSIndexPath indexPathForItem:0 inSection:section];
        }
    } else {
        return [NSIndexPath indexPathForItem:self.selectedIndexPath.item + 1 inSection:self.selectedIndexPath.section];
    }
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

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    PKCollectionViewLayoutAttributes *attributes = (PKCollectionViewLayoutAttributes *)[super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertPaths containsObject:itemIndexPath]) {
        CGFloat translationX = - (attributes.frame.origin.x + attributes.frame.size.width * 2);
        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationX];
        animation.beginTime = CACurrentMediaTime() + 0.15 * (self.insertPaths.count - 1 - itemIndexPath.item);
        animation.fromValue = @(translationX);
        animation.toValue = @(0);
        attributes.animation = animation;
        attributes.frame = CGRectMake(-attributes.size.width, attributes.frame.origin.y, attributes.size.width, attributes.size.height);
        attributes.alpha = 0;
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    return attributes;
}

- (void)finalizeCollectionViewUpdates
{
    for (NSIndexPath *indexPath in self.insertPaths) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.alpha = 0;
    }

    [super finalizeCollectionViewUpdates];
    [self.collectionView setNeedsDisplay];
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    self.insertPaths = nil;
    self.deletePaths = nil;
}


@end