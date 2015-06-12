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

@protocol STPScrollViewPanGestureRecognizerDelegate;
@interface STPScrollViewPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) STPScrollViewPanGestureRecognizerDirection scrollDirection; //default STPScrollViewScrollDirectionEvery
@property (nonatomic, weak) id <STPScrollViewPanGestureRecognizerDelegate> scrollViewPanGestureRecognizerDelegate;

- (void)toFail;

@end


@protocol STPScrollViewPanGestureRecognizerDelegate <NSObject>

- (BOOL)scrollViewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (STPScrollViewPanGestureRecognizerDirection)gestureRecognizerScrollDirection;

@end