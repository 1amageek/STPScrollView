//
//  NestViewController.m
//  STPScrollView
//
//  Created by Norikazu on 2015/06/08.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "NestViewController.h"
#import "STPScrollView.h"

@interface NestViewController ()

@property (nonatomic) UIScrollView *uiScrollView1;
@property (nonatomic) STPScrollView *stpScrollView1;
@property (nonatomic) UIScrollView *uiScrollView2;
@property (nonatomic) STPScrollView *stpScrollView2;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;


@end

@implementation NestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    
    _uiScrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height/2)];
    _uiScrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, rect.size.width, rect.size.height)];
    _uiScrollView1.clipsToBounds = YES;
    
    _stpScrollView1 = [[STPScrollView alloc] initWithFrame:CGRectMake(0, rect.size.height/2, rect.size.width, rect.size.height/2)];
    _stpScrollView2 = [[STPScrollView alloc] initWithFrame:CGRectMake(10, 10, rect.size.width, rect.size.height)];
    _stpScrollView1.clipsToBounds = YES;
    
    _uiScrollView1.backgroundColor = [UIColor colorWithHue:0.5 saturation:0.8 brightness:0.8 alpha:1];
    _uiScrollView2.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.5 brightness:0.5 alpha:1];
    
    _stpScrollView1.backgroundColor = [UIColor colorWithHue:0.5 saturation:0.7 brightness:0.5 alpha:1];
    _stpScrollView2.backgroundColor = [UIColor colorWithHue:0.7 saturation:0.7 brightness:0.6 alpha:1];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 10, 10)];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 10, 10)];
    
    view1.backgroundColor = [UIColor greenColor];
    view2.backgroundColor = [UIColor greenColor];
    
    

    [self.view addSubview:_uiScrollView1];
    [self.uiScrollView1 addSubview:_uiScrollView2];
    [self.uiScrollView2 addSubview:view1];
    
    [self.view addSubview:_stpScrollView1];
    [self.stpScrollView1 addSubview:_stpScrollView2];
    [self.stpScrollView2 addSubview:view2];
    
    _uiScrollView1.contentSize = _uiScrollView2.bounds.size;
    _stpScrollView1.contentSize = _uiScrollView2.bounds.size;
    _uiScrollView2.contentSize = CGSizeMake(rect.size.width * 2, rect.size.height);
    _stpScrollView2.contentSize = CGSizeMake(rect.size.width * 2, rect.size.height);
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    /*
    NSLog(@"viewWillLayoutSubviews UI   contentsize %@", NSStringFromCGSize(_uiScrollView1.contentSize));
    NSLog(@"viewWillLayoutSubviews STP  contentsize %@", NSStringFromCGSize(_stpScrollView1.contentSize));
    
    NSLog(@"viewWillLayoutSubviews UI2  contentsize %@", NSStringFromCGSize(_uiScrollView2.contentSize));
    NSLog(@"viewWillLayoutSubviews STP2 contentsize %@", NSStringFromCGSize(_stpScrollView2.contentSize));
*/
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear UI   contentsize %@", NSStringFromCGSize(_uiScrollView1.contentSize));
    NSLog(@"viewDidAppear STP  contentsize %@", NSStringFromCGSize(_stpScrollView1.contentSize));
    
    NSLog(@"viewDidAppear UI2  contentsize %@", NSStringFromCGSize(_uiScrollView2.contentSize));
    NSLog(@"viewDidAppear STP2 contentsize %@", NSStringFromCGSize(_stpScrollView2.contentSize));
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

@end
