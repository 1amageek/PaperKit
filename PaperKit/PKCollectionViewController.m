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
    CGFloat _initialTouchScale;
}



@end

@implementation PKCollectionViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        _transtionProgress = 0.0f;
        _pagingEnabled = NO;
        _collectionView = [[PKCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.layer.anchorPoint = CGPointMake(0, 1);
        //_collectionView.userInteractionEnabled = NO;
        _scrollView = [[PKScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.minimumZoomScale = 0.45;
        _scrollView.maximumZoomScale = 1;
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
    _transtionProgress = transtionProgress;
    self.collectionView.transtionProgress = transtionProgress;
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
    [self setZoomScale:self.scrollView.minimumZoomScale];
    
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

#pragma mark - PanGestureRecognizer

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self.scrollView];
    CGPoint translation = [recognizer translationInView:self.scrollView];
    CGPoint velocity = [recognizer velocityInView:self.scrollView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.pagingEnabled = NO;
            
            [self pop_removeAnimationForKey:@"inc.stamp.pk.scrollView.zoom"];
            
            _initialTouchLocaiton = location;
            _initialTouchScale = self.zoomScale;
            self.selectedIndexPath = [_collectionView indexPathForItemAtPoint:[recognizer locationInView:self.collectionView]];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat initialDistance = self.view.bounds.size.height - _initialTouchLocaiton.y;
            CGFloat currentDistance = self.view.bounds.size.height - location.y;
        
            CGFloat scale = (currentDistance / initialDistance) * _initialTouchScale;
            
            [self setZoomScale:scale];
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            if (velocity.y < 0) {
                self.pagingEnabled = YES;
                CGPoint contentOffset = [self.layout targetContentOffsetForProposedContentOffset:CGPointZero];
                
                [self animationZoomScale:self.scrollView.maximumZoomScale velocity:velocity.y];
                [self animationContentOffset:contentOffset velocity:velocity.x];
                //self.scrollView.pagingEnabled = YES;
                
                self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
                
            } else {
                self.pagingEnabled = NO;
                [self animationZoomScale:self.scrollView.minimumZoomScale velocity:velocity.y];
                //self.scrollView.pagingEnabled = NO;
                
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
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && otherGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        gestureRecognizer.state = UIGestureRecognizerStateFailed;
    }
    return YES;
}

#pragma mark - Animation

- (void)animationZoomScale:(CGFloat)targetScale velocity:(CGFloat)velocity
{
    POPSpringAnimation *animation = [POPSpringAnimation animation];
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
    //animation.velocity = @(velocity);
    animation.toValue = @(targetScale);
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
    };
    [self pop_addAnimation:animation forKey:@"inc.stamp.pk.scrollView.zoom"];
}

- (void)animationContentOffset:(CGPoint)contentOffset velocity:(CGFloat)velocity
{
    POPBasicAnimation *animation = [POPBasicAnimation animation];
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
    animation.toValue = @(-contentOffset.x);
    animation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
    };
    [self.scrollView pop_addAnimation:animation forKey:@"inc.stamp.pk.scrollView.offset"];
}

@end
