//
//  STPScrollView.m
//  STPScrollView
//
//  Created by Norikazu on 2015/04/26.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "STPScrollView.h"
#import <POP.h>

@interface STPScrollView () <UIGestureRecognizerDelegate, POPAnimationDelegate>
{
    CGPoint _initialTouchPoint;
    CGFloat _initialZoomScale;
    CGAffineTransform _initialTransform;
    BOOL _animating;
}

@property (nonatomic) UIView *zoomView;

@end

@implementation STPScrollView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animating = NO;
    _contentOffset = CGPointZero;
    _contentSize = CGSizeZero;
    _contentInset = UIEdgeInsetsZero;
    _directionalLockEnabled = NO;
    _bounces = YES;
    _alwaysBounceHorizontal = NO;
    _alwaysBounceVertical = NO;
    _pagingEnabled = NO;
    _scrollEnabled = YES;
    _minimumZoomScale = 1;
    _maximumZoomScale = 1;
    _zoomScale = 1;
    _bouncesZoom = YES;
    
    _zooming = NO;
    _zoomBouncing = NO;
    
    _panGestureRecognizer = [[STPScrollViewPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    _pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_pinchGestureRecognizer];
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.x"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.y"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.x"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.y"];
}

- (void)panGesture:(STPScrollViewPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    CGPoint translation = [recognizer translationInView:self];
    CGPoint velocity = [recognizer velocityInView:self];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _initialTouchPoint = location;
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.x"];
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.y"];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
                [self.delegate scrollViewWillBeginDragging:self];
            }
            
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {

            CGFloat availableOffsetX = self.bounds.size.width - self.contentSize.width;
            CGFloat availableOffsetY = self.bounds.size.height - self.contentSize.height;
            
            CGFloat translationX = translation.x;
            CGFloat translationY = translation.y;
            
            // contentSizeを超えたときの抵抗
            if (self.contentOffset.x < availableOffsetX || 0 < self.contentOffset.x) {
                translationX = translationX / 3;
            }
            
            if (self.contentOffset.y < availableOffsetY || 0 < self.contentOffset.y) {
                translationY = translationY / 3;
            }
            
            self.contentOffset = CGPointMake(self.contentOffset.x + translationX, self.contentOffset.y + translationY);
            [recognizer setTranslation:CGPointZero inView:self];
            
            
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
                [self.delegate scrollViewDidEndDragging:self willDecelerate:self.bounces];
            }
            
            
            
            if (self.bounces) {
                
                if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                    [self.delegate scrollViewDidEndDecelerating:self];
                }
                
                _animating = YES;
                POPDecayAnimation *decayAnimationX = [POPDecayAnimation animation];
                POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.decay.property.x" initializer:^(POPMutableAnimatableProperty *prop) {
                    prop.readBlock = ^(id obj, CGFloat values[]) {
                        values[0] = [obj contentOffset].x;
                    };
                    prop.writeBlock = ^(id obj, const CGFloat values[]) {
                        
                        CGPoint contentOffset = [obj contentOffset];
                        contentOffset.x = values[0];
                        [obj setContentOffset:contentOffset];
                        
                    };
                    prop.threshold = 0.01;
                }];
                decayAnimationX.property = propX;
                decayAnimationX.velocity = @(velocity.x);
                decayAnimationX.delegate = self;
                decayAnimationX.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                        [self.delegate scrollViewDidEndDecelerating:self];
                    }
                };
                [self pop_addAnimation:decayAnimationX forKey:@"stp.scrollView.animation.decay.x"];
                
                POPDecayAnimation *decayAnimationY = [POPDecayAnimation animation];
                POPAnimatableProperty *propY = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.decay.property.y" initializer:^(POPMutableAnimatableProperty *prop) {
                    prop.readBlock = ^(id obj, CGFloat values[]) {
                        values[0] = [obj contentOffset].y;
                    };
                    prop.writeBlock = ^(id obj, const CGFloat values[]) {
                        
                        CGPoint contentOffset = [obj contentOffset];
                        contentOffset.y = values[0];
                        [obj setContentOffset:contentOffset];
                        
                    };
                    
                    prop.threshold = 0.01;
                }];
                decayAnimationY.property = propY;
                decayAnimationY.velocity = @(velocity.y);
                decayAnimationY.delegate = self;
                decayAnimationY.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                        [self.delegate scrollViewDidEndDecelerating:self];
                    }
                };
                [self pop_addAnimation:decayAnimationY forKey:@"stp.scrollView.animation.decay.y"];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    
    CGFloat availableOffsetX = self.bounds.size.width - self.contentSize.width;
    CGFloat availableOffsetY = self.bounds.size.height - self.contentSize.height;
    
    CGFloat deltaX = contentOffset.x - _contentOffset.x;
    CGFloat deltaY = contentOffset.y - _contentOffset.y;
    
    if (!self.bounces) {
        if (contentOffset.x < availableOffsetX || 0 < contentOffset.x) {
            deltaX = 0;
        }
        
        if (contentOffset.y < availableOffsetY || 0 < contentOffset.y) {
            deltaY = 0;
        }
    } else {

        if (contentOffset.x < availableOffsetX || 0 < contentOffset.x) {
            
            POPSpringAnimation *animation = [self pop_animationForKey:@"stp.scrollView.animation.bounce.x"];
            POPDecayAnimation *decayAnimation = [self pop_animationForKey:@"stp.scrollView.animation.decay.x"];

            if (!animation) {
                if (decayAnimation) {
                    [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.x"];
                    
                    POPSpringAnimation *bouncsAnimation = [POPSpringAnimation animation];
                    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.spring.property" initializer:^(POPMutableAnimatableProperty *prop) {
                        
                        prop.readBlock = ^(id obj, CGFloat values[]) {
                            values[0] = [obj contentOffset].x;
                        };
                        
                        prop.writeBlock = ^(id obj, const CGFloat values[]) {
                            
                            CGPoint contentOffset = [obj contentOffset];
                            contentOffset.x = values[0];
                            [obj setContentOffset:contentOffset];
                        };
                        // dynamics threshold
                        prop.threshold = 0.01;
                    }];
                    bouncsAnimation.property = prop;
                    bouncsAnimation.velocity = decayAnimation.velocity;
                    bouncsAnimation.delegate = self;
              
                    if (0 < contentOffset.x) {
                        bouncsAnimation.toValue = @(0);
                    }
                    
                    if (contentOffset.x < availableOffsetX) {
                        bouncsAnimation.toValue = @(availableOffsetX);
                    }
                    
                    [self pop_addAnimation:bouncsAnimation forKey:@"stp.scrollView.animation.bounce.x"];
                    return;
                }
            }
        }
        
        if (contentOffset.y < availableOffsetY || 0 < contentOffset.y) {
            POPSpringAnimation *animation = [self pop_animationForKey:@"stp.scrollView.animation.bounce.y"];
            POPDecayAnimation *decayAnimation = [self pop_animationForKey:@"stp.scrollView.animation.decay.y"];
            if (!animation) {
                if (decayAnimation) {
                    [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.y"];
                    
                    POPSpringAnimation *bouncsAnimation = [POPSpringAnimation animation];
                    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.spring.property" initializer:^(POPMutableAnimatableProperty *prop) {
                        
                        prop.readBlock = ^(id obj, CGFloat values[]) {
                            values[0] = [obj contentOffset].y;
                        };
                        
                        prop.writeBlock = ^(id obj, const CGFloat values[]) {
                            
                            CGPoint contentOffset = [obj contentOffset];
                            contentOffset.y = values[0];
                            [obj setContentOffset:contentOffset];
                        };
                        // dynamics threshold
                        prop.threshold = 0.01;
                    }];
                    bouncsAnimation.property = prop;
                    bouncsAnimation.velocity = decayAnimation.velocity;
                    bouncsAnimation.delegate = self;
                    if (availableOffsetY < contentOffset.y) {
                        bouncsAnimation.toValue = @(availableOffsetY);
                    } else {
                        bouncsAnimation.toValue = @(0);
                    }

                    [self pop_addAnimation:bouncsAnimation forKey:@"stp.scrollView.animation.bounce.y"];
                    return;
                }
            }
        }
    }
    
    CGPoint deltaPoint = CGPointMake(deltaX, deltaY);
    _contentOffset = contentOffset;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.layer.position = CGPointMake(view.layer.position.x + deltaPoint.x, view.layer.position.y + deltaPoint.y);
    }];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:self];
    }

}

#pragma mark - Pinch Gesture

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _initialTouchPoint = location;
            _initialTransform = self.zoomView.layer.affineTransform;
            NSLog(@"zoom Scale %f", recognizer.scale);
            //[recognizer setScale:self.zoomScale];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            /*
            CGFloat scale = recognizer.scale;
            self.zoomView.layer.affineTransform = CGAffineTransformConcat(_initialTransform, CGAffineTransformMakeScale(scale, scale));
            CGFloat zoomScale = self.zoomView.frame.size.height / self.zoomView.bounds.size.height;
             */
            
            //CGFloat zoomScale = recognizer.scale * self.zoomScale;
            
            
            [recognizer setScale:self.zoomScale];
            [self setZoomScale:recognizer.scale];
            

        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
}


- (UIView *)zoomView
{
    if ([self.delegate viewForZoomingInScrollView:self]) {
        return [self.delegate viewForZoomingInScrollView:self];
    }
    return nil;
}

- (void)setZoomScale:(CGFloat)zoomScale
{
    if (zoomScale == _zoomScale) {
        return;
    }
    _zoomScale = zoomScale;
    
    if (zoomScale < self.minimumZoomScale) {
        zoomScale = self.minimumZoomScale;
    }
    
    if (self.maximumZoomScale < zoomScale) {
        zoomScale = self.maximumZoomScale;
    }
    NSLog(@"zoom %f", zoomScale);
    self.zoomView.layer.affineTransform = CGAffineTransformMakeScale(zoomScale, zoomScale);
}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated
{
    _zoomScale = scale;
    
    if (animated) {
        
        _animating = YES;
        /*
        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(scale, scale)];
        anim.delegate = self;
        [self.zoomView.layer pop_addAnimation:anim forKey:@"stp.scrollView.animation.zoom"];
        */
        
        POPBasicAnimation *zoomAnimation = [POPBasicAnimation animation];
        POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.zoom.property" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj zoomScale];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setZoomScale:values[0]];
            };
            // dynamics threshold
            prop.threshold = 0.01;
        }];
        zoomAnimation.property = prop;
        zoomAnimation.toValue = @(scale);
        
        [self pop_addAnimation:zoomAnimation forKey:@"stp.scrollView.animation.zoom"];

        
    } else {
        [self setZoomScale:scale];
    }
    
}

#pragma mark - <UIGestureRecognizerDelegate>

 - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidStart:(POPAnimation *)anim
{
    _animating = YES;
    
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if (![[self pop_animationKeys] count]) {
        _animating = NO;
    }
    
    
    
}



#pragma mark - POP

static inline CGFloat POPTransition(CGFloat progress, CGFloat startValue, CGFloat endValue) {
    return startValue + (progress * (endValue - startValue));
}

@end
