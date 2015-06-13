//
//  PKCollectionViewFlowLayout.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PKCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes


@end


typedef NS_ENUM(NSUInteger, PKCollectionSection) {
    PKCollectionViewSectionMaster = 0,
    PKCollectionViewSectionStock = 0,
    PKCollectionViewSectionContent
};

typedef NS_ENUM(NSInteger, PKCollectionViewLayoutDirection) {
    PKCollectionViewLayoutDirectionNext,
    PKCollectionViewLayoutDirectionPrevious,
    PKCollectionViewLayoutDirectionCreate
};

@protocol PKCollectionViewFlowLayoutDelegate;

@interface PKCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) NSIndexPath *selectedIndexPath;
@property (nonatomic) PKCollectionViewLayoutDirection direction;
@property (nonatomic) CGFloat zoomScale;
@property (nonatomic) id <PKCollectionViewFlowLayoutDelegate> delegate;

- (CGSize)calculateSize;

@end


@protocol PKCollectionViewFlowLayoutDelegate <NSObject>

- (CGFloat)layoutZoomScale;

@end