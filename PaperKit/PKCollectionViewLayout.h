//
//  PKCollectionViewLayout.h
//  PaperKit
//
//  Created by Norikazu on 2015/06/15.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKCollectionViewFlowLayout.h"

@interface PKCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) NSIndexPath *selectedIndexPath;
@property (nonatomic) CGFloat zoomScale;
@property (nonatomic) CGRect rengeRect;

- (CGSize)calculateSize;


@end
