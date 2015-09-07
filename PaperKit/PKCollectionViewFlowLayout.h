//
//  PKCollectionViewFlowLayout.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>
#import <pop/POPLayerExtras.h>

@interface PKCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic) POPAnimation *animation;

@end

@protocol PKCollectionViewFlowLayoutDelegate;

@interface PKCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) NSIndexPath *selectedIndexPath;
@property (nonatomic) CGFloat zoomScale;
@property (nonatomic, readonly) CGSize rengeSize;
@property (nonatomic, readonly) CGRect rengeRect;
@property (nonatomic) id <PKCollectionViewFlowLayoutDelegate> delegate;

- (CGSize)calculateSize;


@end


@protocol PKCollectionViewFlowLayoutDelegate <NSObject>

- (CGFloat)layoutZoomScale;
- (CGSize)sizeOfRengeInCollectionView:(nonnull UICollectionView *)collectionView;

@end