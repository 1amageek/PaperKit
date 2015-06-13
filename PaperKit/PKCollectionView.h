//
//  PKCollectionView.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKCollectionView : UICollectionView

@property (nonatomic) CGFloat transtionProgress;
@property (nonatomic) CGFloat collectionViewScale;
@property (nonatomic) NSIndexPath *selectedIndexPath;

@end
