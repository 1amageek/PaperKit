//
//  BackgroundViewController.h
//  Sample
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaperKit.h>

@interface BackgroundViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) PKWindow *window;
@property (nonatomic) UITableView *tableView;

@end
