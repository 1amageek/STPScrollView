//
//  ViewController.m
//  STPScrollView
//
//  Created by Norikazu on 2015/03/18.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <STPScrollViewDelegate, UIScrollViewDelegate>

@property (nonatomic) UIView *contentView;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    

    _scrollView = [[STPScrollView alloc] initWithFrame:screenRect];
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.4;
    _scrollView.maximumZoomScale = 1;
    _scrollView.contentSize = CGSizeMake(500, 500);
    
    _contentView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(1000, [UIScreen mainScreen].bounds.size.height)}];
    _contentView.backgroundColor = [UIColor greenColor];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];

    [self.scrollView addGestureRecognizer:self.tapGestureRecognizer];
    

    [self.view addSubview:_scrollView];
    [self.scrollView addSubview:_contentView];
    
    for (NSInteger i = 0; i < 15; i++) {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(80 * i, 30 * i, 100, 100)];
        aView.backgroundColor = [UIColor redColor];
        [self.scrollView addSubview:aView];
    }
    
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    [self.scrollView setZoomScale:0.5 animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _contentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
