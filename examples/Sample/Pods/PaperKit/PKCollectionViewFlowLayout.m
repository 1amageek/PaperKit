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
        _rengeRect = [UIScreen mainScreen].bounds;
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
    
    CGRect rengeRect = [UIScreen mainScreen].bounds;
    rengeRect.origin.x -= self.itemSize.width;
    rengeRect.size.width += (self.itemSize.width * 2);
    self.rengeRect = rengeRect;
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
    
    for (NSInteger section = 0; section < sections; section ++) {
        
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < items; item ++) {
            
            UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            CGRect frame = [self.collectionView convertRect:attribute.frame toView:nil];
            BOOL intersetsRect = CGRectIntersectsRect(self.rengeRect, frame);
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
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:(indexPath.item == 0) ? 0 : indexPath.item - 1 inSection:indexPath.section];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:(indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] -1 ) ? indexPath.item : indexPath.item + 1 inSection:indexPath.section];
    
    if (velocity.x < 0) {
        indexPath = previousIndexPath;
    } else if (0 < velocity.x) {
        indexPath = nextIndexPath;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return CGPointMake(cell.frame.origin.x, cell.frame.origin.y);
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
        
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.insertPaths.count -1 inSection:itemIndexPath.section]];
        CGFloat translationX = -layoutAttributes.frame.origin.x - layoutAttributes.frame.size.width;
        
        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationX];
        animation.beginTime = CACurrentMediaTime() + 0.13 * (self.insertPaths.count - itemIndexPath.item);
        animation.fromValue = @(translationX);
        animation.toValue = @(0);
        attributes.animation = animation;
        attributes.transform3D = CATransform3DMakeTranslation(translationX, 0, 0);
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.deletePaths containsObject:itemIndexPath]) {
        
        CGPoint endPoint;
        
        switch (self.direction) {
            case PKCollectionViewLayoutDirectionCreate:
                endPoint = CGPointMake(attributes.center.x, attributes.center.y + [UIScreen mainScreen].bounds.size.height);
                break;
            case PKCollectionViewLayoutDirectionNext:
                endPoint = CGPointMake(-attributes.size.width/2, attributes.center.y);
                break;
            case PKCollectionViewLayoutDirectionPrevious:
            default:
                endPoint = CGPointMake(self.collectionViewContentSize.width + attributes.size.width/2, attributes.center.y);
                break;
        }
        
        attributes.center = endPoint;
    }
    return attributes;
}

- (void)finalizeCollectionViewUpdates
{
    
    for (NSIndexPath *indexPath in self.insertPaths) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.alpha = 0;
    }
    
    self.insertPaths = nil;
    self.deletePaths = nil;
    [super finalizeCollectionViewUpdates];
}

@end
