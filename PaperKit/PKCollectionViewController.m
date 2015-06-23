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
    CGPoint _fromContentOffset;
    CGFloat _fromProgress;
    

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
        _collectionView.userInteractionEnabled = YES;
        _collectionView.layer.anchorPoint = CGPointMake(0, 1);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.opaque = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _scrollView = [[PKScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.delaysContentTouches = NO;
        _scrollView.userInteractionEnabled = YES;
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

- (void)animateWithProgress:(CGFloat)transtionProgress expand:(BOOL)expand
{
    [self setTranstionProgress:transtionProgress];
    CGFloat targetContentOffsetX = [self.layout targetContentOffsetForProposedContentOffset:CGPointZero].x;
    //CGFloat toContentOffsetX = ((_fromContentOffset.x + self.scrollView.bounds.size.width/2)/self.minimumZoomScale) - self.scrollView.bounds.size.width/2;
    CGFloat prgress;
    if (expand) {
        prgress = (transtionProgress - _fromProgress)/(1 - _fromProgress);
        prgress = isnan(prgress) ? 0 : prgress;
        prgress = isinf(prgress) ? 1 : prgress;
    } else {
        prgress = 1 - transtionProgress/_fromProgress;
        prgress = isnan(prgress) ? 0 : prgress;
        prgress = isinf(prgress) ? 1 : prgress;
    }
    
    CGFloat fromContentOffsetX = _fromContentOffset.x;
    //CGFloat fromContentOffsetY = _fromContentOffset.y;
    
    if (self.scrollView.contentOffset.x <= 0) {
        targetContentOffsetX = 0;
        CGFloat contentOffsetX = POPTransition(prgress, fromContentOffsetX, targetContentOffsetX);
        [self.scrollView setContentOffset:CGPointMake(contentOffsetX, self.scrollView.contentOffset.y) animated:NO];
        return;
    }

    if (expand) {
        CGFloat contentOffsetX = POPTransition(prgress, fromContentOffsetX, targetContentOffsetX);
        //CGFloat contentOffsetY = POPTransition(prgress, fromContentOffsetY, 0);
        [self.scrollView setContentOffset:CGPointMake(contentOffsetX, self.scrollView.contentOffset.y) animated:NO];
    } else {

        if ((self.collectionView.bounds.size.width * self.minimumZoomScale - self.scrollView.bounds.size.width)  <= self.scrollView.contentOffset.x) {
            
            CGFloat offsetX = self.collectionView.bounds.size.width * self.minimumZoomScale - self.scrollView.bounds.size.width;
            targetContentOffsetX = offsetX;
            CGFloat contentOffsetX = POPTransition(prgress, fromContentOffsetX, targetContentOffsetX);
            [self.scrollView setContentOffset:CGPointMake(contentOffsetX, self.scrollView.contentOffset.y) animated:NO];
        }
    }
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
    self.collectionView.selectedIndexPath = selectedIndexPath;
    self.layout.selectedIndexPath = selectedIndexPath;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    
    if (pagingEnabled) {
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    } else {
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[PKCollectionViewCell class] forCellWithReuseIdentifier:@"PKCollectionViewCell"];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.collectionView];
    
    _collectionView.frame = (CGRect){CGPointZero, [self.layout calculateSize]};
    
    _panGestureRecognizer = [[PKPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    _panGestureRecognizer.scrollDirection = PKPanGestureRecognizerDirectionVertical;
    _panGestureRecognizer.delegate = self;
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    _tapGestureRecognizer.delegate = self;
    
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
    [self.collectionView addGestureRecognizer:_tapGestureRecognizer];
    
}

- (void)viewWillLayoutSubviews
{
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
    height = MAX(0, height);
    _collectionView.layer.position = CGPointMake(self.collectionView.frame.origin.x, height);
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
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
    _transtionProgress = (self.scrollView.zoomScale - self.minimumZoomScale) / (self.maximumZoomScale - self.minimumZoomScale);

}

- (void)scrollViewWillBeginZooming:(nonnull UIScrollView *)scrollView withView:(nullable UIView *)view
{
    self.selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[self.scrollView.pinchGestureRecognizer locationInView:self.collectionView]];
}

- (void)scrollViewDidEndZooming:(nonnull UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    CGFloat threshold = (self.maximumZoomScale + self.minimumZoomScale) / 2;
    
    if (threshold < scale) {
        self.pagingEnabled = YES;
        _fromProgress = self.transtionProgress;
        _fromContentOffset = self.scrollView.contentOffset;
        [self animationTransitionExpand:YES velocity:0];
        
    } else {
        self.pagingEnabled = NO;
        _fromProgress = self.transtionProgress;
        _fromContentOffset = self.scrollView.contentOffset;
        [self animationTransitionExpand:NO velocity:0];
        
    }
    
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((PKCollectionViewCell *)cell).transtionProgress = self.transtionProgress;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PKCollectionViewCell *cell = (PKCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PKCollectionViewCell" forIndexPath:indexPath];
    NSInteger i = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    UIColor *color = [UIColor colorWithHue:(floorf(indexPath.row)/i) saturation:0.8 brightness:0.75 alpha:1.0];
    cell.backgroundColor = color;
    return cell;
    
}

- (void)collectionView:(nonnull UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}

#pragma mark - TapGestureRecognizer

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    
    if (!self.pagingEnabled) {
        self.selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]];
        _fromProgress = self.transtionProgress;
        _fromContentOffset = self.scrollView.contentOffset;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        self.pagingEnabled = YES;
        [self animationTransitionExpand:YES velocity:0];
    }
}

#pragma mark - PanGestureRecognizer

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self.scrollView];
    CGPoint translation = [recognizer translationInView:self.scrollView];
    CGPoint velocity = [recognizer velocityInView:self.scrollView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.pagingEnabled = NO;
            self.scrollView.panGestureRecognizer.state = UIGestureRecognizerStateFailed;
            [self pop_removeAnimationForKey:@"inc.stamp.pk.scrollView.progress"];
            
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

            scale = MIN(self.scrollView.maximumZoomScale, scale);
            scale = MAX(self.scrollView.minimumZoomScale, scale);
            
            CGFloat offsetX = (_initialTouchContentOffset.x + self.scrollView.bounds.size.width/2) * (scale/_initialTouchScale) - self.scrollView.bounds.size.width/2;
            CGFloat progress = (scale - self.minimumZoomScale) / (self.maximumZoomScale - self.minimumZoomScale);
     
            [self setTranstionProgress:progress];
            [self.scrollView setContentOffset:CGPointMake(offsetX - translation.x, 0) animated:NO];

            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (velocity.y < 0) {
                self.pagingEnabled = YES;
                _fromProgress = self.transtionProgress;
                _fromContentOffset = self.scrollView.contentOffset;
                [self animationTransitionExpand:YES velocity:velocity.y];
                
            } else {
                self.pagingEnabled = NO;
                _fromProgress = self.transtionProgress;
                _fromContentOffset = self.scrollView.contentOffset;
                [self animationTransitionExpand:NO velocity:velocity.y];

            }
            
            break;
        }
            
        default:
            break;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    if (gestureRecognizer == self.panGestureRecognizer && otherGestureRecognizer == self.scrollView.panGestureRecognizer) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Animation

- (void)animationTransitionExpand:(BOOL)expand velocity:(CGFloat)velocity
{
    POPSpringAnimation *animation = [self pop_animationForKey:@"inc.stamp.pk.scrollView.progress"];
    if (!animation) {
        animation = [POPSpringAnimation animation];
        POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"inc.stamp.pk.property.scrollView.progress" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj transtionProgress];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj animateWithProgress:values[0] expand:expand];
            };
            prop.threshold = 0.01;
        }];
        
        animation.property = propX;
        animation.springSpeed = 8;
        animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
        };
        [self pop_addAnimation:animation forKey:@"inc.stamp.pk.scrollView.progress"];
    }
    animation.toValue = expand ? @(1) : @(0);
}

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

@end
