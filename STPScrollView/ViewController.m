//
//  ViewController.m
//  STPScrollView
//
//  Created by Norikazu on 2015/05/16.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate, STPScrollViewDelegate>

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;



@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.uiScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView = [[STPScrollView alloc] initWithFrame:CGRectZero];
    
    self.uiContentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.uiContentView2 = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView2 = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.uiContentView3 = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView3 = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.uiScrollView];
    [self.view addSubview:self.scrollView];
    
    [self.uiScrollView addSubview:self.uiContentView];
    [self.scrollView addSubview:self.contentView];
    
    [self.uiScrollView addSubview:self.uiContentView2];
    [self.scrollView addSubview:self.contentView2];
    
    [self.uiScrollView addSubview:self.uiContentView3];
    [self.scrollView addSubview:self.contentView3];
    
    self.uiContentView.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:0.65 alpha:1];
    self.contentView.backgroundColor = [UIColor colorWithRed:0.5 green:1 blue:0.85 alpha:1];
    
    self.uiContentView2.backgroundColor = [UIColor colorWithRed:0.3 green:0.45 blue:0.85 alpha:1];
    self.contentView2.backgroundColor = [UIColor colorWithRed:0.3 green:0.45 blue:0.85 alpha:1];
    
    self.uiContentView3.backgroundColor = [UIColor colorWithRed:0.6 green:0.45 blue:0.85 alpha:1];
    self.contentView3.backgroundColor = [UIColor colorWithRed:0.7 green:0.45 blue:0.85 alpha:1];
    
    self.uiScrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    self.uiScrollView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height/2);
    self.scrollView.frame = CGRectMake(0, rect.size.height/2, rect.size.width, rect.size.height/2);
    
    CGRect contentRect = CGRectMake(rect.size.width/2 - 100, rect.size.height/4 - 100, 200, 200);
    self.contentView.frame = contentRect;
    self.uiContentView.frame = contentRect;
    
    CGRect content2Rect = CGRectMake(rect.size.width/2 - 25, rect.size.height/4 - 25, 50, 50);
    self.contentView2.frame = content2Rect;
    self.uiContentView2.frame = content2Rect;
    
    CGRect content3Rect = CGRectMake(0, 0, 10, 10);
    self.contentView3.frame = content3Rect;
    self.uiContentView3.frame = content3Rect;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    
    self.uiScrollView.delegate = self;
    self.scrollView.delegate = self;

    
}

- (UIView *)viewForZoomingInScrollView:(UIView *)scrollView
{
    if (scrollView == self.scrollView) {
        return self.contentView;
    }
    
    if (scrollView == self.uiScrollView) {
        return self.uiContentView;
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIView *)scrollView
{
    //NSLog(@"bounds %@", NSStringFromCGRect(scrollView.bounds));
}

- (void)scrollViewDidZoom:(STPScrollView *)scrollView
{
    NSLog(@"scroll %f", scrollView.zoomScale);
}

- (void)viewWillLayoutSubviews
{
    
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
