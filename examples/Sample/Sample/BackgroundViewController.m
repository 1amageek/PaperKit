//
//  BackgroundViewController.m
//  Sample
//
//  Created by Norikazu on 2015/06/29.
//  Copyright © 2015年 Stamp inc. All rights reserved.
//

#import "BackgroundViewController.h"
#import "ViewController.h"
#import "ComposeViewController.h"


@interface BackgroundViewController ()

@property (nonatomic) UIButton *addButton;
@property (nonatomic) NSArray *menu;

@end

@implementation BackgroundViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menu = @[@"Account", @"Create Post"];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = self.view.bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"london"];
    [self.view addSubview:imageView];
    [self.view addSubview:blurView];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}


- (UITableView *)tableView
{
    if (_tableView) {
        return _tableView;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.menu[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ViewController *nextViewController = [ViewController new];
        [[PKWindowManager sharedManager] showWindowWithRootViewController:nextViewController];
    } else if (indexPath.row == 1) {
        ComposeViewController *nextViewController = [ComposeViewController new];
        [[[PKWindowManager sharedManager] topWindow].rootViewController presentViewController:nextViewController animated:YES completion:nil];
    }
    
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


@end
