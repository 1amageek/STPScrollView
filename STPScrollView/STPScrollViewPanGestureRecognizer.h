//
//  STPScrollViewPanGestureRecognizer.h
//  STPScrollView
//
//  Created by Norikazu on 2015/03/25.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_ENUM(NSInteger, STPScrollViewPanGestureRecognizerDirection)
{
    STPScrollViewPanGestureRecognizerDirectionEvery,
    STPScrollViewPanGestureRecognizerDirectionVertical,
    STPScrollViewPanGestureRecognizerDirectionHorizontal
};

@interface STPScrollViewPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) STPScrollViewPanGestureRecognizerDirection scrollDirection; //default STPScrollViewScrollDirectionEvery

@end


@protocol STPScrollViewPanGestureRecognizerDelegate <NSObject>

- (STPScrollViewPanGestureRecognizerDirection)gestureRecognizerScrollDirection;

@end