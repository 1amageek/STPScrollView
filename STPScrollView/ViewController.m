//
//  ViewController.m
//  UIScrollView
//
//  Created by Norikazu on 2015/03/18.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionView *contentView;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    

    _scrollView = [[STPScrollView alloc] initWithFrame:screenRect];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.4;
    _scrollView.maximumZoomScale = 40;
    _scrollView.bouncesZoom = YES;
    _scrollView.contentSize = CGSizeMake(500, 500);
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width/7, [UIScreen mainScreen].bounds.size.height/10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _contentView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    _contentView.delegate = self;
    _contentView.dataSource = self;
    _contentView.userInteractionEnabled = NO;
    [_contentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];

    [self.scrollView addGestureRecognizer:self.tapGestureRecognizer];
    

    [self.view addSubview:_scrollView];
    [self.scrollView addSubview:_contentView];
    
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    //[self.scrollView setZoomScale:0.5 animated:YES];
    CGRect rect = [self zoomRectForScrollView:self.scrollView withScale:4 withCenter:[recognizer locationInView:self.contentView]];
    rect.size.width = 200;
    NSLog(@"rect %@", NSStringFromCGRect(rect));
    
    [self.scrollView zoomToRect:rect animated:YES];
    
}

- (CGRect)zoomRectForScrollView:(STPScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _contentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 90;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    cell.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:label];
    
    return cell;
}

@end
