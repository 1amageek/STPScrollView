//
//  ViewController.h
//  STPScrollView
//
//  Created by Norikazu on 2015/03/18.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPScrollView.h"

@interface ScrollView : UIScrollView

@end


@interface ViewController : UIViewController

@property (nonatomic) ScrollView *scrollView;
@property (nonatomic) UIScrollView *sllView;

@end

