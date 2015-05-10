//
//  STPScrollViewPanGestureRecognizer.m
//  STPScrollView
//
//  Created by Norikazu on 2015/03/25.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "STPScrollViewPanGestureRecognizer.h"

@interface STPScrollViewPanGestureRecognizer ()

@end

@implementation STPScrollViewPanGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.scrollDirection = STPScrollViewPanGestureRecognizerDirectionEvery;
    }
    
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    

    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];

    if (self.state == UIGestureRecognizerStatePossible) {
        
        
        CGFloat x = fabs(nowPoint.x - prevPoint.x);
        CGFloat y = fabs(nowPoint.y - prevPoint.y);
        
        BOOL comp = NO;
        
        switch (self.scrollDirection) {
                
            
            case STPScrollViewPanGestureRecognizerDirectionVertical:
                // 横のスクロールと判断するとFailedにする
                comp = y < x;
                break;
            case STPScrollViewPanGestureRecognizerDirectionHorizontal:
                // 縦のスクロールと判断するとFailedにする
                comp = x < y;
                break;
            case STPScrollViewPanGestureRecognizerDirectionEvery:
            default:
                // 全方向でFaildにしない
                break;
        }
        
        if (comp) {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
        
    }
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) return;
}


@end
