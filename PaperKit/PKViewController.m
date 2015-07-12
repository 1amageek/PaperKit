//
//  PKViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKViewController.h"

#pragma mark - _PKOverlayCollectionViewCell

@interface _PKOverlayCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIViewController *viewController;

@end

@implementation _PKOverlayCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end

#pragma mark - _PKOverlayCollectionView

@interface _PKOverlayCollectionView : UICollectionView

@end

@implementation _PKOverlayCollectionView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint screenPoint = [self convertPoint:point toView:self.superview];
    
    _PKOverlayCollectionViewCell *cell = (_PKOverlayCollectionViewCell *)[self cellForItemAtIndexPath:[self indexPathForItemAtPoint:point]];
    PKCollectionViewController *viewController = (PKCollectionViewController *)cell.viewController;
    if (CGRectContainsPoint(viewController.collectionView.frame, screenPoint)) {
        return view;
    }
    
    return nil;
}

@end



@interface PKViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PKCollectionViewControllerDelegate>

@property (nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic) _PKOverlayCollectionView *overlayCollectionView;

@end

@implementation PKViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _selectedCategory = 0;
}

- (UICollectionViewFlowLayout *)layout
{
    if (_layout) {
        return _layout;
    }
    
    _layout = [UICollectionViewFlowLayout new];
    _layout.minimumInteritemSpacing = 0;
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.itemSize = [UIScreen mainScreen].bounds.size;
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _layout.sectionInset = UIEdgeInsetsZero;
    
    return _layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    
    _overlayCollectionView = [[_PKOverlayCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    _overlayCollectionView.pagingEnabled = YES;
    _overlayCollectionView.delegate = self;
    _overlayCollectionView.dataSource = self;
    _overlayCollectionView.showsHorizontalScrollIndicator = NO;
    _overlayCollectionView.showsVerticalScrollIndicator = NO;
    _overlayCollectionView.alwaysBounceHorizontal = NO;
    _overlayCollectionView.alwaysBounceVertical = NO;
    _overlayCollectionView.backgroundColor = [UIColor clearColor];
    _overlayCollectionView.opaque = NO;
    _overlayCollectionView.scrollEnabled = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:self.layout];
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.alwaysBounceVertical = NO;
    
    [self.view addSubview:_collectionView];
    [self.view addSubview:_overlayCollectionView];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.overlayCollectionView registerClass:[_PKOverlayCollectionViewCell class] forCellWithReuseIdentifier:@"_PKOverlayCollectionViewCell"];
    
}

- (PKToolbar *)toolbar
{
    if (_toolbar) {
        return _toolbar;
    }
    
    _toolbar = [[PKToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    [_toolbar setBackgroundImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny
                      barMetrics:UIBarMetricsDefault];
    [_toolbar setBackgroundColor:[UIColor clearColor]];
    return _toolbar;
}

- (void)setSelectedCategory:(NSUInteger)selectedCategory
{
    
    [self categoryWillSet:_selectedCategory nextCategory:selectedCategory];
    _selectedCategory = selectedCategory;
    
    if (self.overlayCollectionView) {
        [self.overlayCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedCategory inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    [self categoryDidSet:selectedCategory];
}

- (void)categoryWillSet:(NSUInteger)currentCategory nextCategory:(NSUInteger)nextCategory
{
    // override method
}

- (void)categoryDidSet:(NSUInteger)category
{
    // override method
}

- (void)viewWillLayoutSubviews
{
    _collectionView.contentInset = UIEdgeInsetsZero;
    _overlayCollectionView.contentInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PKCollectionViewController *)viewControllerAtIndex:(NSInteger)index
{
    _PKOverlayCollectionViewCell *cell = (_PKOverlayCollectionViewCell *)[self.overlayCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell.viewController) {
        return (PKCollectionViewController *)cell.viewController;
    }
    
    
    PKCollectionViewController *viewController = [PKCollectionViewController new];
    viewController.collectionView.delegate = self;
    viewController.collectionView.dataSource = self;
    [self regisiterCellToCollectionView:(PKCollectionView *)viewController.collectionView];
    
    return viewController;
}

- (void)regisiterCellToCollectionView:(PKCollectionView *)collectionView
{
    //override method
}

- (PKCollectionViewController *)foregroundViewControllerAtIndex:(NSInteger)category
{
    _PKOverlayCollectionViewCell *cell = (_PKOverlayCollectionViewCell *)[self.overlayCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:category inSection:0]];
    return (PKCollectionViewController *)cell.viewController;
}

- (PKCollectionViewController *)foregroundViewControllerAtCollectionView:(UICollectionView *)collectionView
{
    NSArray *cells = [self.overlayCollectionView visibleCells];
    __block PKCollectionViewController *controller = nil;
    [cells enumerateObjectsUsingBlock:^(_PKOverlayCollectionViewCell *cell, NSUInteger idx, BOOL * __nonnull stop) {
        PKCollectionViewController *viewController = (PKCollectionViewController *)cell.viewController;
        if (viewController.collectionView == collectionView) {
            controller = viewController;
            *stop = YES;
        }
    }];
    
    return controller;
}

- (NSUInteger)indexAtCollectionView:(UICollectionView *)collectionView
{
    NSArray *cells = [self.overlayCollectionView visibleCells];
    __block NSUInteger index = 0;
    [cells enumerateObjectsUsingBlock:^(_PKOverlayCollectionViewCell *cell, NSUInteger idx, BOOL * __nonnull stop) {
        PKCollectionViewController *viewController = (PKCollectionViewController *)cell.viewController;
        if (viewController.collectionView == collectionView) {
            index = [self.overlayCollectionView indexPathForCell:cell].item;
            *stop = YES;
        }
    }];
    return index;
}

- (PKContentViewController *)_collectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath
                                  onCategory:(NSUInteger)category {
    
    PKCollectionViewCell *cell = (PKCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.viewController) {
        return (PKContentViewController *)cell.viewController;
    }
    PKContentViewController *viewController = [self foregroundCollectionView:collectionView contentViewControllerForAtIndexPath:indexPath onCategory:category];
    NSAssert(viewController != nil, @"require foreground cell ViewController at %@", indexPath);
    return viewController;
}

- (PKContentViewController *)foregroundCollectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:(NSIndexPath *)indexPath onCategory:(NSUInteger)category
{
    //override method
    PKContentViewController *viewController = [PKContentViewController new];
    return viewController;
}

- (void)scrollViewWillEndDragging:(nonnull UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout nonnull CGPoint *)targetContentOffset
{
    if (scrollView == self.collectionView) {
        CGFloat x = targetContentOffset->x;
        CGFloat y = targetContentOffset->y;
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(x, y)];
        if (self.selectedCategory != indexPath.item) {
            self.selectedCategory = indexPath.item;
        }
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.collectionView == collectionView || self.overlayCollectionView == collectionView) {
        return [self numberOfSectionsInBackgroundCollectionView:collectionView];
    }
    return [self numberOfSectionsInForegroundCollectionView:collectionView onCategory:self.selectedCategory];
}

- (NSInteger)numberOfSectionsInBackgroundCollectionView:(UICollectionView *)collectionView
{
    // override method
    return 1;
}

- (NSInteger)numberOfSectionsInForegroundCollectionView:(UICollectionView *)collectionView onCategory:(NSInteger)category
{
    // override method
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.collectionView == collectionView || self.overlayCollectionView == collectionView) {
        return [self backgroundCollectionView:collectionView numberOfItemsInSection:section];
    }
    
    return [self foregroundCollectionVew:collectionView numberOfItemsInSection:section onCategory:self.selectedCategory];
}

- (NSInteger)backgroundCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // override method
    return 10;
}

- (NSInteger)foregroundCollectionVew:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section onCategory:(NSInteger)category
{
    // override method
    return 10;
}

- (void)reloadBackgroundData
{
    // TODO Block when a user is touching
    [self.collectionView reloadData];
    [self.overlayCollectionView reloadData];
}

- (void)reloadForegroundDataOnCategory:(NSInteger)category
{
    // TODO　Block when a user is touching
    [[self foregroundViewControllerAtIndex:category] reloadData];
}

- (void)foregroundCollectionViewOnCategory:(NSInteger)category performBatchUpdates:(void (^)(PKCollectionViewController *controller))updates completion:(void (^)(BOOL finished))completion
{
    // TODO　Block when a user is touching
    PKCollectionViewController *viewController = [self foregroundViewControllerAtIndex:category];
    [viewController performBatchUpdates:^(){
        updates(viewController);
    } completion:completion];
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // background
    
    if (self.collectionView == collectionView) {
        return;
    }
    
    // overlay
    if (self.overlayCollectionView == collectionView) {
        return;
    }
    
    // foreground
    if (self.collectionView == collectionView) {
        return;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // background
    if (self.collectionView == collectionView) {
        return [self backgroundCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    // overlay
    if (self.overlayCollectionView == collectionView) {
        _PKOverlayCollectionViewCell *cell = (_PKOverlayCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"_PKOverlayCollectionViewCell" forIndexPath:indexPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PKCollectionViewController *viewController = [self viewControllerAtIndex:indexPath.item];
            if (![self.childViewControllers containsObject:viewController]) {
                viewController.delegate = self;
                [self addChildViewController:viewController];
                [cell addSubview:viewController.view];
                [viewController didMoveToParentViewController:self];
                ((_PKOverlayCollectionViewCell *)cell).viewController = viewController;
            }
        });
        return cell;
    }
    
    // foreground
    
    PKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PKCollectionViewCell" forIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PKCollectionViewController *parentViewController = [self foregroundViewControllerAtCollectionView:collectionView];
        NSUInteger index = [self indexAtCollectionView:collectionView];
        PKContentViewController *viewController = [self _collectionView:(PKCollectionView *)collectionView contentViewControllerForAtIndexPath:indexPath onCategory:index];
        
        if (![parentViewController.childViewControllers containsObject:viewController]) {
            [parentViewController addChildViewController:viewController];
            [cell addSubview:viewController.view];
            [parentViewController didMoveToParentViewController:self];
            ((PKCollectionViewCell *)cell).viewController = viewController;
        }
        cell.transitionProgress = parentViewController.transitionProgress;
    });

    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // background
    if (self.collectionView == collectionView) {
        return;
    }
    
    // overlay
    if (self.overlayCollectionView == collectionView) {
        PKCollectionViewController *viewController = (PKCollectionViewController *)((_PKOverlayCollectionViewCell *)cell).viewController;
        if ([self.childViewControllers containsObject:viewController]) {
            [viewController willMoveToParentViewController:self];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    
    // foreground
    PKContentViewController *viewController = (PKContentViewController *)((PKCollectionViewCell *)cell).viewController;
    if ([self.childViewControllers containsObject:viewController]) {
        _PKOverlayCollectionViewCell *overlayCell = (_PKOverlayCollectionViewCell *)[self.overlayCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedCategory inSection:0]];
        
        [viewController willMoveToParentViewController:overlayCell.viewController];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

- (UICollectionViewCell *)backgroundCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // override
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    return cell;
}

- (void)viewController:(PKCollectionViewController *)viewController didChangeTransitionProgress:(CGFloat)transitionProgress
{
    UICollectionViewCell *cell = [self.collectionView visibleCells][0];
    
    if (cell) {
        CGFloat scale = POPTransition(transitionProgress, 1, 0.95);
        cell.transform = CGAffineTransformMakeScale(scale, scale);
        
        CGFloat alpha = POPTransition(transitionProgress, 1, 0);
        cell.alpha = alpha;
    }
    
}

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}


@end
