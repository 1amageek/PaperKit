//
//  PKContentCollectionView.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/25.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKContentCollectionView : UICollectionView

@property (nonatomic) CGFloat transitionProgress;
@property (nonatomic) CGFloat collectionViewScale;
@property (nonatomic) NSIndexPath *selectedIndexPath;


@end
