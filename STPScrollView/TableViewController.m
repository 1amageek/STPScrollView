//
//  TableViewController.m
//  STPScrollView
//
//  Created by Norikazu on 2015/05/16.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"

@interface TableViewController ()
@property (nonatomic) NSArray *testItems;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testItems = @[@[
                           @"サイズを指定しないスクロール",
                           @"サイズを指定したスクロール contentSizeがview.boundsより小さい",
                           @"サイズを指定したスクロール contentSizeがview.boundsより大きいX",
                           @"サイズを指定したスクロール contentSizeがview.boundsより大きいY",
                           @"サイズを指定したスクロール contentSizeがview.boundsより大きいXY",
                           @"スクロール　directionalLockEnabled YES",
                           @"サイズを指定しないスクロール alwaysBounceHorizontal",
                           @"サイズを指定しないスクロール alwaysBounceVertical",
                           @"contentSizeがview.boundsより小さい alwaysBounceHorizontal",
                           @"contentSizeがview.boundsより小さい alwaysBounceVertical",
                           @"contentSizeがview.boundsと同じ bounces = NO", //10
                           @"contentSizeがview.boundsと同じ bounces = YES",
                           @"contentSizeがview.boundsと大きい bounces = NO",
                           @"contentSizeがview.boundsと大きい bounces = YES",
                           @"bounces = NO alwaysBounceHorizontal = YES alwaysBounceVertical = YES",
                           @"decelerationRate = STPScrollViewDecelerationRateFast"
                           ],
                       @[
                           @"zoom min = 1 max = 1",
                           @"zoom min = 0.5 max = 1",
                           @"zoom min = 0.5 max = 2",
                           ]
                       ];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.testItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.testItems objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.testItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *viewController = [ViewController new];
    //[self.navigationController pushViewController:viewController animated:YES];
    
    [self presentViewController:viewController animated:YES completion:^{
        CGRect contentRect = CGRectZero;
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                
            }
            
            if (indexPath.row == 1) {
                
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
                
            }
            
            if (indexPath.row == 2) {
                
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, 100);
                
            }
            
            if (indexPath.row == 3) {
                
                contentRect = CGRectMake(0, 0, 100, [UIScreen mainScreen].bounds.size.height * 2);
                
            }
            
            if (indexPath.row == 4) {
                
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
                
            }
            
            if (indexPath.row == 5) {
                
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
                viewController.uiScrollView.directionalLockEnabled = YES;
                viewController.scrollView.directionalLockEnabled = YES;
                
            }
            
            if (indexPath.row == 6) {
                viewController.uiScrollView.alwaysBounceHorizontal = YES;
                viewController.scrollView.alwaysBounceHorizontal = YES;
            }
            
            if (indexPath.row == 7) {
                viewController.uiScrollView.alwaysBounceVertical = YES;
                viewController.scrollView.alwaysBounceVertical = YES;
            }
            
            if (indexPath.row == 8) {
                viewController.uiScrollView.alwaysBounceHorizontal = YES;
                viewController.scrollView.alwaysBounceHorizontal = YES;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
            }
            
            if (indexPath.row == 9) {
                viewController.uiScrollView.alwaysBounceVertical = YES;
                viewController.scrollView.alwaysBounceVertical = YES;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
            }
            
            if (indexPath.row == 10) {
                //viewController.uiScrollView.bounces = YES;
                //viewController.scrollView.bounces = YES;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
            }
            
            if (indexPath.row == 11) {
                viewController.uiScrollView.bounces = YES;
                viewController.scrollView.bounces = YES;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
            }
            
            if (indexPath.row == 12) {
                viewController.uiScrollView.bounces = NO;
                viewController.scrollView.bounces = NO;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
            }
            
            if (indexPath.row == 13) {
                viewController.uiScrollView.bounces = YES;
                viewController.scrollView.bounces = YES;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
            }
            
            if (indexPath.row == 14) {
                viewController.uiScrollView.bounces = NO;
                viewController.scrollView.bounces = NO;
                viewController.uiScrollView.alwaysBounceVertical = YES;
                viewController.scrollView.alwaysBounceVertical = YES;
                viewController.uiScrollView.alwaysBounceHorizontal = YES;
                viewController.scrollView.alwaysBounceHorizontal = YES;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
            }
            
            if (indexPath.row == 15) {
                viewController.uiScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
                viewController.scrollView.decelerationRate = STPScrollViewDecelerationRateFast;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
            }

        }
        
        
        // zoom
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                viewController.uiScrollView.minimumZoomScale = 1;
                viewController.uiScrollView.maximumZoomScale = 1;
                viewController.scrollView.minimumZoomScale = 1;
                viewController.scrollView.maximumZoomScale = 1;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2);
            }
            
            if (indexPath.row == 1) {
                viewController.uiScrollView.minimumZoomScale = .5f;
                viewController.uiScrollView.maximumZoomScale = 1;
                viewController.scrollView.minimumZoomScale = .5f;
                viewController.scrollView.maximumZoomScale = 1;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 2);
            }
            
            if (indexPath.row == 2) {
                viewController.uiScrollView.minimumZoomScale = 0.5;
                viewController.uiScrollView.maximumZoomScale = 2;
                viewController.scrollView.minimumZoomScale = 0.5;
                viewController.scrollView.maximumZoomScale = 2;
                contentRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            }
        }
        
        
        
        [self setRect:contentRect viewController:viewController];
    }];
    
    
    
    
    
}

- (void)setRect:(CGRect)rect viewController:(ViewController *)viewController
{
    viewController.uiContentView.frame = rect;
    viewController.uiScrollView.contentSize = rect.size;
    viewController.contentView.frame = rect;
    viewController.scrollView.contentSize = rect.size;
}

@end
