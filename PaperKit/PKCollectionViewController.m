//
//  PKCollectionViewController.m
//  PaperKit
//
//  Created by Norikazu on 2015/06/13.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "PKCollectionViewController.h"

@interface PKCollectionViewController () <PKCollectionViewFlowLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    CGPoint _initialTouchLocaiton;
    CGPoint _initialTouchLocationInCollectionView;
    CGFloat _initialTouchScale;
    CGFloat _previousScale;
    CGPoint _initialTouchContentOffset;
}

@property (nonatomic) CGFloat minimumZoomScale;
@property (nonatomic) CGFloat maximumZoomScale;

@end

@implementation PKCollectionViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        _maximumZoomScale = 1.0f;
        _minimumZoomScale = 0.45f;
        _transtionProgress = 0.0f;
        _pagingEnabled = NO;
        _collectionView = [[PKCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.layer.anchorPoint = CGPointMake(0, 1);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.opaque = NO;
        _scrollView = [[PKScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.minimumZoomScale = 0.3f;
        _scrollView.maximumZoomScale = 1.5f;
        _scrollView.bouncesZoom = YES;
        _scrollView.delegate = self;
        
    }
    
    return self;
}

- (PKCollectionViewFlowLayout *)layout {
    if (_layout) {
        return _layout;
    }

    CGSize size = [UIScreen mainScreen].bounds.size;
    _layout = [PKCollectionViewFlowLayout new];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.itemSize = size;
    _layout.minimumInteritemSpacing = 5;
    _layout.minimumLineSpacing = 5;
    _layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _layout.delegate = self;
    return _layout;
    
}

- (void)setTranstionProgress:(CGFloat)transtionProgress {
    
    if (transtionProgress == _transtionProgress) {
        return;
    }
    
    _transtionProgress = transtionProgress;
    self.collectionView.transtionProgress = transtionProgress;
    CGFloat scale = POPTransition(transtionProgress, self.minimumZoomScale, self.maximumZoomScale);
    [self setZoomScale:scale];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
    self.collectionView.selectedIndexPath = selectedIndexPath;
    self.layout.selectedIndexPath = selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[PKCollectionViewCell class] forCellWithReuseIdentifier:@"PKCollectionViewCell"];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.collectionView];
    
    _collectionView.frame = (CGRect){CGPointZero, [self.layout calculateSize]};
    
    _panGestureRecognizer = [[PKPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    _panGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
    
}

- (void)viewWillLayoutSubviews
{
    //_scrollView.delaysContentTouches = NO;
    _scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)viewDidLayoutSubviews
{
    _collectionView.layer.position = CGPointMake(_collectionView.layer.position.x, [UIScreen mainScreen].bounds.size.height * (1 - self.scrollView.minimumZoomScale));
    [self setZoomScale:self.minimumZoomScale];
    
}

- (CGFloat)zoomScale
{
    return _scrollView.zoomScale;
}

- (void)setZoomScale:(CGFloat)scale
{
    [_scrollView setZoomScale:scale animated:NO];
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    _collectionView.layer.position = CGPointMake(0, height);
    [self scrollViewDidZoom:self.scrollView];
}


- (NSArray *)visibleCells
{
    
    NSArray *allCells = [self.collectionView visibleCells];
    NSMutableArray *cells = [NSMutableArray array];
    [allCells enumerateObjectsUsingBlock:^(PKCollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
        CGRect frame = [self.collectionView convertRect:cell.frame toView:nil];
        BOOL intersetsRect = CGRectIntersectsRect([UIScreen mainScreen].bounds, frame);
        if (intersetsRect) {
            [cells addObject:cell];
        }
    }];
    
    return cells;
}

- (NSArray *)indexPathsForVisibleItems
{
    NSArray *allCells = [self.collectionView visibleCells];
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [allCells enumerateObjectsUsingBlock:^(PKCollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
        CGRect frame = [cell.superview convertRect:cell.frame toView:self.view];
        BOOL intersetsRect = CGRectIntersectsRect([UIScreen mainScreen].bounds, frame);
        if (intersetsRect) {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:cell.center];
            [indexPaths addObject:indexPath];
        }
    }];
    
    return indexPaths;
}

- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (PKContentViewController *)viewControllerAtIndex:(NSInteger)index
{
    
    PKCollectionViewCell *cell = (PKCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell.viewController) {
        return (PKContentViewController *)cell.viewController;
    }
    
    PKContentViewController *viewController = [PKContentViewController new];
    return viewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - <PKCollectionViewFlowLayoutDelegate>

- (CGFloat)layoutZoomScale
{
    return self.scrollView.zoomScale;
}

#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _collectionView;
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.pagingEnabled) {
        
        CGPoint contentOffset = [self.layout targetContentOffsetForProposedContentOffset:*targetContentOffset withScrollingVelocity:velocity];
        *targetContentOffset = CGPointMake(contentOffset.x, contentOffset.y);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.pagingEnabled) {
        self.selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[self.scrollView.panGestureRecognizer locationInView:self.collectionView]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSArray *visibleCells = [self visibleCells];
    
    [visibleCells enumerateObjectsUsingBlock:^(PKCollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell.transtionProgress != self.transtionProgress) {
            cell.transtionProgress = self.transtionProgress;
        }
    }];
    
    NSArray *rengeCells = [self.collectionView visibleCells];
    
    PKCollectionViewCell *visibleFirstCell = [visibleCells firstObject];
    PKCollectionViewCell *visibleLastCell = [visibleCells lastObject];
    
    
    PKCollectionViewCell *rengeFirstCell = [rengeCells firstObject];
    PKCollectionViewCell *rengeLastCell = [rengeCells lastObject];
    
    
    if (visibleFirstCell == rengeFirstCell) {
        if ([self.collectionView indexPathForCell:visibleFirstCell].item != 0) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }
    }
    if (visibleLastCell == rengeLastCell) {
        if ([self.collectionView indexPathForCell:visibleLastCell].item != [self.collectionView numberOfItemsInSection:0] - 1) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSArray *rengeCells = [self.collectionView visibleCells];
    
    if (rengeCells.count < 2) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }

}

- (CGRect)zoomRectForScrollView:(UIView *)scrollView withScale:(CGFloat)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

#pragma mark - <UICollectionViewDelegate>


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((PKCollectionViewCell *)cell).transtionProgress = self.transtionProgress;
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    PKContentViewController *viewController = (PKContentViewController *)((PKCollectionViewCell *)cell).viewController;
    [viewController willMoveToParentViewController:self];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PKCollectionViewCell *cell = (PKCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PKCollectionViewCell" forIndexPath:indexPath];
    PKContentViewController *viewController = [self viewControllerAtIndex:indexPath.item];
    [self addChildViewController:viewController];
    [cell addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    ((PKCollectionViewCell *)cell).viewController = viewController;
    
    
    NSInteger i = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    UIColor *color = [UIColor colorWithHue:(floorf(indexPath.row)/i) saturation:0.8 brightness:0.75 alpha:1.0];
    //cell.backgroundColor = color;
    cell.viewController.view.backgroundColor = color;
    
    
    
    return cell;
    
}

#pragma mark - PanGestureRecognizer

- (void)_view:(UIView *)view convertAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint _anchorPoint = view.layer.anchorPoint;
    CGFloat _pointXFromZero = view.bounds.size.width * _anchorPoint.x;
    CGFloat pointXFromZero = view.bounds.size.width * anchorPoint.x;
    CGFloat delta = pointXFromZero - _pointXFromZero;
    
    view.layer.anchorPoint = anchorPoint;
    view.layer.position = CGPointMake(view.layer.position.x - pointXFromZero, 1);
    
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self.scrollView];
    CGPoint translation = [recognizer translationInView:self.scrollView];
    CGPoint velocity = [recognizer velocityInView:self.scrollView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            self.scrollView.panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
            self.pagingEnabled = NO;
            self.scrollView.bounces = NO;
            [self pop_removeAnimationForKey:@"inc.stamp.pk.scrollView.zoom"];
            
            _initialTouchLocaiton = location;
            _initialTouchLocationInCollectionView = [recognizer locationInView:self.collectionView];
            _initialTouchScale = self.zoomScale;
            _previousScale = _initialTouchScale;
            _initialTouchContentOffset = self.scrollView.contentOffset;
            
            
            self.selectedIndexPath = [_collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]];
            

            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat initialDistance = self.view.bounds.size.height - _initialTouchLocaiton.y;
            CGFloat currentDistance = self.view.bounds.size.height - location.y;
        
            CGFloat scale = (currentDistance / initialDistance) * _initialTouchScale;
            
            if (scale < self.minimumZoomScale) {
                CGFloat deltaZoomScale = self.minimumZoomScale - scale;
                scale = self.minimumZoomScale - deltaZoomScale / 4;
            }
            if (self.maximumZoomScale < scale) {
                CGFloat deltaZoomScale = scale - self.maximumZoomScale;
                scale = self.maximumZoomScale + deltaZoomScale / 4;
            }
            
            CGFloat progress = (scale - self.minimumZoomScale) / (self.maximumZoomScale - self.minimumZoomScale);
            
            CGFloat diff = _initialTouchLocationInCollectionView.x * scale - _initialTouchLocationInCollectionView.x * _previousScale;
            
            if (self.scrollView.maximumZoomScale <= scale) {
                diff = 0;
            }
            
            CGFloat width = [recognizer locationInView:self.collectionView].x * _previousScale;
            CGFloat offsetX = width * (scale/_previousScale) - location.x;
            NSLog(@"ss %f %f %f %f %f", width, scale ,_previousScale, scale/_previousScale, offsetX);
            [self setTranstionProgress:progress];
            
            //self.scrollView.contentOffset = CGPointMake(contentOffset.x - translation.x + diff, contentOffset.y);
            //self.scrollView.contentOffset = contentOffset;
            
            if (self.scrollView.contentOffset.x <= 0) {
                CGPoint position = self.collectionView.layer.position;
                position.x += translation.x;
                CGAffineTransform transform = self.collectionView.transform;
                self.collectionView.transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(translation.x, 0));
            } else {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x - translation.x, 0) animated:NO];
            }
            [recognizer setTranslation:CGPointZero inView:self.scrollView];
            _previousScale = self.zoomScale;
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            self.scrollView.bounces = YES;
            if (velocity.y < 0) {
                self.pagingEnabled = YES;
                CGPoint contentOffset = [self.layout targetContentOffsetForProposedContentOffset:CGPointZero];
                
                [self animationTransitionProgress:1 velocity:velocity.y];
                [self animationContentOffset:contentOffset velocity:velocity.x];
                self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
                
            } else {
                self.pagingEnabled = NO;
                [self animationTransitionProgress:0 velocity:velocity.y];
                if (self.scrollView.contentOffset.x < 0) {
                    [self animationContentOffset:CGPointZero velocity:velocity.x];
                }
                
                if ((self.scrollView.contentSize.width - self.scrollView.bounds.size.width) < self.scrollView.contentOffset.x) {
                    CGFloat offsetX = self.collectionView.bounds.size.width * self.minimumZoomScale - self.scrollView.bounds.size.width;
                    [self animationContentOffset:CGPointMake(-offsetX, 0) velocity:velocity.x];
                }
                
                self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
            }
            
            break;
        }
            
        default:
            break;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    if (otherGestureRecognizer.view == self.scrollView) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan && otherGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            gestureRecognizer.state = UIGestureRecognizerStateFailed;
            return YES;
        }
        return YES;
    } else {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
            //NSLog(@" stat %ld  %ld", (long)gestureRecognizer.state, (long)otherGestureRecognizer.state);
            //NSLog(@" scroll %@", otherGestureRecognizer.view);
            //NSLog(@"a a%f", [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:gestureRecognizer.view].x);
            if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
                if (scrollView.contentOffset.y == 0) {
                    //otherGestureRecognizer.state = UIGestureRecognizerStateFailed;
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

#pragma mark - Animation

- (void)animationTransitionProgress:(CGFloat)progress contentOffset:(CGPoint)contentOffset velocity:(CGFloat)velocity
{
    
}

- (void)setTranstionProgress:(CGFloat)transtionProgress contentOffset:(CGPoint)contentOffset
{
    
    if (transtionProgress == _transtionProgress) {
        return;
    }
    
    _transtionProgress = transtionProgress;
    self.collectionView.transtionProgress = transtionProgress;
    CGFloat scale = POPTransition(transtionProgress, self.minimumZoomScale, self.maximumZoomScale);
    [self setZoomScale:scale];

}

- (void)animationTransitionProgress:(CGFloat)progress velocity:(CGFloat)velocity
{
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.scrollView.progress"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.scrollView.progress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj transtionProgress];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setTranstionProgress:values[0]];
            };
            prop.threshold = 0.01;
        }];
        
        animation.property = propX;
        animation.springSpeed = 8;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.scrollView.progress"];
    }
    animation.toValue = @(progress);
}

- (void)animationZoomScale:(CGFloat)targetScale velocity:(CGFloat)velocity
{
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.scrollView.zoom"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.scrollView.zoom" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj zoomScale];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setZoomScale:values[0]];
            };
            prop.threshold = 0.01;
        }];
        
        animation.property = propX;
        animation.springSpeed = 8;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.scrollView.zoom"];
    }
    animation.toValue = @(targetScale);
}

- (void)animationContentOffset:(CGPoint)contentOffset velocity:(CGFloat)velocity
{
    POPBasicAnimation *animation = [self.scrollView pop_animationForKey:@"inc.stamp.pk.scrollView.offset"];
    if (!animation) {
        animation = [POPBasicAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.scrollView.offset" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj contentOffset].x;
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                
                CGPoint contentOffset = [obj contentOffset];
                contentOffset.x = values[0];
                [obj setContentOffset:contentOffset];
            };
            
            prop.threshold = 0.01;
        }];
        
        animation.property = propX;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
        };
        [self.scrollView pop_addAnimation:animation forKey:@"inc.stamp.pk.scrollView.offset"];
    }
    animation.toValue = @(-contentOffset.x);
}

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

@end
