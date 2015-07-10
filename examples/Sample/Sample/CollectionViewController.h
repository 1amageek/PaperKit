//
//  CollectionViewController.h
//  Sample
//
//  Created by Norikazu on 2015/07/09.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewController.h"

@interface CollectionViewController : PKCollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) UIButton *insertForegroundButton;
@end
