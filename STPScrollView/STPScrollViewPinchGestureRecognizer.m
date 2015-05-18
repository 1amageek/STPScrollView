//
//  STPScrollViewPinchGestureRecognizer.m
//  STPScrollView
//
//  Created by Norikazu on 2015/05/17.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "STPScrollViewPinchGestureRecognizer.h"

@implementation STPScrollViewPinchGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateChanged) {
        if ([touches count] < 2) {
            self.state = UIGestureRecognizerStateEnded;
        }
    }
    [super touchesEnded:touches withEvent:event];
}

@end
