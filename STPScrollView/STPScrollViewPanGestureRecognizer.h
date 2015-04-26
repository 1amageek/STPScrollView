//
//  STPScrollViewPanGestureRecognizer.h
//  STPScrollView
//
//  Created by Norikazu on 2015/03/25.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_ENUM(NSInteger, STPScrollViewScrollDirection)
{
    STPScrollViewScrollDirectionEvery,
    STPScrollViewScrollDirectionVertical,
    STPScrollViewScrollDirectionHorizontal
};

@interface STPScrollViewPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) STPScrollViewScrollDirection scrollDirection; //default STPScrollViewScrollDirectionEvery

@end


@protocol STPScrollViewPanGestureRecognizerDelegate <NSObject>

- (STPScrollViewScrollDirection)gestureRecognizerScrollDirection;

@end