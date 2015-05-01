//
//  STPScrollView.m
//  STPScrollView
//
//  Created by Norikazu on 2015/04/26.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "STPScrollView.h"
#import <POP.h>

#define RESISTANCE_INTERACTIVE 3



const CGFloat STPScrollViewDecelerationRateNormal = 0.997;
const CGFloat STPScrollViewDecelerationRateFast = 0.985;


@interface STPScrollView () <UIGestureRecognizerDelegate, POPAnimationDelegate>
{
    CGPoint _initialTouchPoint;
    CGFloat _initialZoomScale;
    CGAffineTransform _initialTransform;
    BOOL _animating;
    BOOL _deceleratingX;
    BOOL _deceleratingY;
    BOOL _lock;
    BOOL _directionalLockVertical;
    BOOL _directionalLockHorizontal;
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
    _deceleratingX = NO;
    _deceleratingY = NO;
    
    _lock = NO;
    _directionalLockVertical = NO;
    _directionalLockHorizontal = NO;
    
    _contentOffset = CGPointZero;
    _contentSize = CGSizeZero;
    _contentInset = UIEdgeInsetsZero;
    _directionalLockEnabled = NO;
    _bounces = YES;
    _alwaysBounceHorizontal = NO;
    _alwaysBounceVertical = NO;
    _pagingEnabled = NO;
    _scrollEnabled = YES;
    _decelerationRate = STPScrollViewDecelerationRateNormal;
    _minimumZoomScale = 1;
    _maximumZoomScale = 1;
    _zoomScale = 1;
    _bouncesZoom = YES;
    
    _tracking = NO;
    _dragging = NO;
    _decelerating = NO;
    
    _zooming = NO;
    _zoomBouncing = NO;
    
    _panGestureRecognizer = [[STPScrollViewPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    _pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_pinchGestureRecognizer];
    
    
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    
    CGRect rect = self.bounds;
    rect.origin.x    -= contentInset.left;
    rect.origin.y    -= contentInset.top;
    
    //rect.size.width  -= (contentInset.left + contentInset.right);
    //rect.size.height -= (contentInset.top  + contentInset.bottom);

    [self setBounds:rect];
    [self setContentOffset:CGPointMake(-contentInset.left, -contentInset.top)];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.x"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.y"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.x"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.y"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.offset"];
}

- (void)panGesture:(STPScrollViewPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    CGPoint translation = [recognizer translationInView:self];
    CGPoint velocity = [recognizer velocityInView:self];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _tracking = YES;
            _dragging = NO;
            _decelerating = NO;
            
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

            _tracking = NO;
            _dragging = YES;
            _decelerating = NO;
            
            if (self.directionalLockEnabled) {
                if (!_lock) {
                    _lock = YES;
                    
                    CGFloat translationX = translation.x * translation.x;
                    CGFloat translationY = translation.y * translation.y;
                    
                    if (translationX < translationY) {
                        NSLog(@"_directionalLockHorizontal");
                        _directionalLockHorizontal = YES;
                    }
                    
                    if (translationY < translationX) {
                        NSLog(@"_directionalLockVertical");
                        _directionalLockVertical = YES;
                    }
                }
            }
            
            CGFloat availableOffsetX = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
            CGFloat availableOffsetY = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
            
            CGFloat translationX = translation.x;
            CGFloat translationY = translation.y;
            
            // contentSizeを超えたときの抵抗
            if (self.contentOffset.x < self.contentInset.left || availableOffsetX < self.contentOffset.x) {
                translationX = translationX / RESISTANCE_INTERACTIVE;
            }
            
            if (self.contentOffset.y < self.contentInset.top || availableOffsetY < self.contentOffset.y) {
                translationY = translationY / RESISTANCE_INTERACTIVE;
            }
            
            self.contentOffset = CGPointMake(self.contentOffset.x - translationX, self.contentOffset.y - translationY);
            [recognizer setTranslation:CGPointZero inView:self];
            
            
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            _tracking = NO;
            _dragging = NO;
            _decelerating = YES;
            
            
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
                [self.delegate scrollViewDidEndDragging:self willDecelerate:self.bounces];
            }
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                [self.delegate scrollViewDidEndDecelerating:self];
            }
            
            _animating = YES;
            
            // declerating X content offset
            _deceleratingX = YES;
            POPDecayAnimation *decayAnimationX = [POPDecayAnimation animation];
            POPAnimatableProperty *propX = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.decay.property.x" initializer:^(POPMutableAnimatableProperty *prop) {
                prop.readBlock = ^(id obj, CGFloat values[]) {
                    values[0] = [obj contentOffset].x;
                };
                prop.writeBlock = ^(id obj, const CGFloat values[]) {
                    
                    CGPoint contentOffset = [obj contentOffset];
                    contentOffset.x = values[0];
                    [obj setContentOffset:contentOffset bounces:self.bounces];
                    
                };
                prop.threshold = 0.01;
            }];
            decayAnimationX.property = propX;
            decayAnimationX.velocity = @(-velocity.x);
            decayAnimationX.delegate = self;
            decayAnimationX.deceleration = self.decelerationRate;
            decayAnimationX.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                
                _deceleratingX = NO;
                
                // 2軸のアニメーションが終了してからProtocolを呼び出し
                if (!_deceleratingX && !_deceleratingY) {
                    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                        [self.delegate scrollViewDidEndDecelerating:self];
                    }
                }
            
            };
            [self pop_addAnimation:decayAnimationX forKey:@"stp.scrollView.animation.decay.x"];
            
            
            // declerating Y content offset
            _deceleratingY = YES;
            POPDecayAnimation *decayAnimationY = [POPDecayAnimation animation];
            POPAnimatableProperty *propY = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.decay.property.y" initializer:^(POPMutableAnimatableProperty *prop) {
                prop.readBlock = ^(id obj, CGFloat values[]) {
                    values[0] = [obj contentOffset].y;
                };
                prop.writeBlock = ^(id obj, const CGFloat values[]) {
                    
                    CGPoint contentOffset = [obj contentOffset];
                    contentOffset.y = values[0];
                    [obj setContentOffset:contentOffset bounces:self.bounces];
                    
                };
                
                prop.threshold = 0.01;
            }];
            decayAnimationY.property = propY;
            decayAnimationY.velocity = @(-velocity.y);
            decayAnimationY.delegate = self;
            decayAnimationY.deceleration = self.decelerationRate;
            decayAnimationY.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                
                _deceleratingY = NO;
                
                // 2軸のアニメーションが終了してからProtocolを呼び出し
                if (!_deceleratingX && !_deceleratingY) {
                    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                        [self.delegate scrollViewDidEndDecelerating:self];
                    }
                }
                
            };
            [self pop_addAnimation:decayAnimationY forKey:@"stp.scrollView.animation.decay.y"];
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    
    CGFloat limitMinX = CGRectGetMinX(rect);
    CGFloat limitMinY = CGRectGetMinY(rect);
    CGFloat limitMaxX = CGRectGetMaxX(rect);
    CGFloat limitMaxY = CGRectGetMaxY(rect);
    
    CGPoint targetContentOffset = self.contentOffset;
    
    if (1) {
        
    }

    
    if (animated) {
        
    } else {
        
        //self.contentOffset.x
        
    }
}

- (void)setContentOffset:(CGPoint)contentOffset bounces:(BOOL)bounces
{
    
    if (bounces) {
        
        CGFloat availableOffsetX = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
        CGFloat availableOffsetY = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
        
        availableOffsetX = MAX(0, availableOffsetX);
        availableOffsetY = MAX(0, availableOffsetY);
        
        if (contentOffset.x < self.contentInset.left || availableOffsetX < contentOffset.x) {
            
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
                        prop.threshold = 0.01;
                    }];
                    bouncsAnimation.property = prop;
                    bouncsAnimation.velocity = decayAnimation.velocity;
                    bouncsAnimation.delegate = self;
                    
                    if (contentOffset.x < self.contentInset.left) {
                        bouncsAnimation.toValue = @(-self.contentInset.left);
                    }
                    
                    if (availableOffsetX < contentOffset.x) {
                        bouncsAnimation.toValue = @(availableOffsetX);
                    }
                    
                    [self pop_addAnimation:bouncsAnimation forKey:@"stp.scrollView.animation.bounce.x"];
                    return;
                }
            }
        }
        
        if (contentOffset.y < self.contentInset.top || availableOffsetY < contentOffset.y) {
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
                        prop.threshold = 0.01;
                    }];
                    bouncsAnimation.property = prop;
                    bouncsAnimation.velocity = decayAnimation.velocity;
                    bouncsAnimation.delegate = self;
                    
                    if (contentOffset.y < self.contentInset.top) {
                        bouncsAnimation.toValue = @(-self.contentInset.top);
                    }
                    
                    if (availableOffsetY < contentOffset.y) {
                        bouncsAnimation.toValue = @(availableOffsetY);
                    }
                    
                    [self pop_addAnimation:bouncsAnimation forKey:@"stp.scrollView.animation.bounce.y"];
                    return;
                }
            }
        }
        
        return [self setContentOffset:contentOffset];
        
    } else {
        [self setContentOffset:contentOffset];
    }

    
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (animated) {
        
        __block BOOL animationXFinished = NO;
        __block BOOL animationYFinished = NO;
        
        POPBasicAnimation *animationX = [POPBasicAnimation animation];
        animationX.property = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.scroll.property.x" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj contentOffset].x;
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                
                CGPoint contentOffset = [obj contentOffset];
                contentOffset.y = values[0];
                [obj setContentOffset:contentOffset];
                
            };
            
            prop.threshold = 0.01;
        }];
        animationX.toValue = @(contentOffset.x);
        animationX.delegate = self;
        animationX.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
            animationXFinished = NO;
            
            // 2軸のアニメーションが終了してからProtocolを呼び出し
            if (animationXFinished && animationYFinished) {
                if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
                    [self.delegate scrollViewDidEndScrollingAnimation:self];
                }
            }
            
        };
        [self pop_addAnimation:animationX forKey:@"stp.scrollView.animation.scroll.x"];
        
        
        POPBasicAnimation *animationY = [POPBasicAnimation animation];
        animationX.property = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.scroll.property.y" initializer:^(POPMutableAnimatableProperty *prop) {
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
        animationY.toValue = @(contentOffset.y);
        animationY.delegate = self;
        animationY.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
            animationYFinished = NO;
            
            // 2軸のアニメーションが終了してからProtocolを呼び出し
            if (animationXFinished && animationYFinished) {
                if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
                    [self.delegate scrollViewDidEndScrollingAnimation:self];
                }
            }
            
        };
        [self pop_addAnimation:animationX forKey:@"stp.scrollView.animation.scroll.x"];
        
    } else {
        [self setContentOffset:contentOffset];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    
    CGFloat availableOffsetX = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    CGFloat availableOffsetY = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    
    availableOffsetX = MAX(0, availableOffsetX);
    availableOffsetY = MAX(0, availableOffsetY);

    CGFloat deltaX = contentOffset.x - _contentOffset.x;
    CGFloat deltaY = contentOffset.y - _contentOffset.y;
    
    if (self.bounces) {
        
        if (!self.alwaysBounceVertical) {
            if (contentOffset.y < self.contentInset.top || availableOffsetY < contentOffset.y) {
                deltaY = 0;
            }
        }
        
        if (!self.alwaysBounceHorizontal) {
            if (contentOffset.x < self.contentInset.left || availableOffsetX < contentOffset.x) {
                deltaX = 0;
            }
        }
        
        
    } else {
        
        if (contentOffset.x < self.contentInset.left || availableOffsetX < contentOffset.x) {
            deltaX = 0;
        }
        
        if (contentOffset.y < self.contentInset.top || availableOffsetY < contentOffset.y) {
            deltaY = 0;
        }
    
    }
    
    if (_directionalLockVertical) {
        deltaY = 0;
    }
    
    if (_directionalLockHorizontal) {
        deltaX = 0;
    }
    
    CGPoint deltaPoint = CGPointMake(deltaX, deltaY);
    _contentOffset = contentOffset;

    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.layer.position = CGPointMake(view.layer.position.x - deltaPoint.x, view.layer.position.y - deltaPoint.y);
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
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.zoom"];
            
            _zooming = YES;
            _initialTouchPoint = location;
            _initialTransform = self.zoomView.layer.affineTransform;
            
            CGPoint locationInZoomView = [recognizer locationInView:self.zoomView];
            CGPoint anchorPoint = CGPointMake( locationInZoomView.x / self.zoomView.bounds.size.width, locationInZoomView.y / self.zoomView.bounds.size.height);
            
            [self _convertAnchorPoint:anchorPoint];
            [recognizer setScale:self.zoomScale];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
            CGFloat targetScale = recognizer.scale;
            
            if (targetScale < self.minimumZoomScale) {
                targetScale = self.minimumZoomScale - (self.minimumZoomScale - targetScale) / RESISTANCE_INTERACTIVE;
            }

            if (self.maximumZoomScale < targetScale) {
                targetScale = self.maximumZoomScale + (targetScale - self.maximumZoomScale) / RESISTANCE_INTERACTIVE;
            }
            
            [self setZoomScale:targetScale];

        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _zooming = NO;
            CGFloat targetScale = recognizer.scale;
            
            if (targetScale < self.minimumZoomScale) {
                targetScale = self.minimumZoomScale - (self.minimumZoomScale - targetScale) / RESISTANCE_INTERACTIVE;
            }
            
            if (self.maximumZoomScale < targetScale) {
                targetScale = self.maximumZoomScale + (targetScale - self.maximumZoomScale) / RESISTANCE_INTERACTIVE;
            }
            
            [self setZoomScale:targetScale animated:self.bouncesZoom];
            
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
    
    if (self.bouncesZoom) {
        
        _zoomScale = zoomScale;
        self.zoomView.layer.affineTransform = CGAffineTransformMakeScale(zoomScale, zoomScale);
        
    } else {
        
        if (zoomScale < self.minimumZoomScale) {
            zoomScale = self.minimumZoomScale;
        }
        
        if (self.maximumZoomScale < zoomScale) {
            zoomScale = self.maximumZoomScale;
        }
        
        _zoomScale = zoomScale;
        self.zoomView.layer.affineTransform = CGAffineTransformMakeScale(zoomScale, zoomScale);
        
    }
    
    self.contentSize = self.zoomView.frame.size;

}

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated
{
    if (animated) {
        
        _animating = YES;
        _zoomBouncing = YES;
        
        if (scale < self.minimumZoomScale) {
            scale = self.minimumZoomScale;
        }
        
        if (self.maximumZoomScale < scale) {
            scale = self.maximumZoomScale;
        }
        
        POPBasicAnimation *zoomAnimation = [POPBasicAnimation animation];

        POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.zoom.property" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj zoomScale];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setZoomScale:values[0]];
            };
            prop.threshold = 0.01;
        }];
        zoomAnimation.property = prop;
        zoomAnimation.toValue = @(scale);
        zoomAnimation.delegate = self;
        zoomAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished){
            _zoomBouncing = NO;
        };
        [self pop_addAnimation:zoomAnimation forKey:@"stp.scrollView.animation.zoom"];

        
    } else {
        [self setZoomScale:scale];
    }
    
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated
{
    
    [self _convertAnchorPoint:CGPointMake(0, 0)];
    
    CGFloat scaleX = self.bounds.size.width / rect.size.width;
    CGFloat scaleY = self.bounds.size.height / rect.size.height;
    CGFloat scale = MAX(scaleX, scaleY);
    CGPoint targetOffset = CGPointMake(rect.origin.x, rect.origin.y);
    
    if (animated) {
        
        POPBasicAnimation *zoomAnimation = [POPBasicAnimation animation];
        POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.zoom.property" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj zoomScale];
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                [obj setZoomScale:values[0]];
            };
            prop.threshold = 0.01;
        }];
        zoomAnimation.property = prop;
        zoomAnimation.toValue = @(scale);
        zoomAnimation.delegate = self;
        zoomAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished){
            _zoomBouncing = NO;
        };
        [self pop_addAnimation:zoomAnimation forKey:@"stp.scrollView.animation.zoom"];
        
        
        POPBasicAnimation *offsetAnimation = [POPBasicAnimation animation];
        offsetAnimation.property = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.offset.property" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(id obj, CGFloat values[]) {
                values[0] = [obj contentOffset].x;
                values[1] = [obj contentOffset].y;
            };
            prop.writeBlock = ^(id obj, const CGFloat values[]) {
                CGPoint contentOffset = [obj contentOffset];
                contentOffset.x = values[0];
                contentOffset.y = values[1];
                
                [obj setContentOffset:contentOffset];
                
            };
            prop.threshold = 0.01;
        }];
        offsetAnimation.toValue = [NSValue valueWithCGPoint:targetOffset];
        offsetAnimation.delegate = self;
        
        [self pop_addAnimation:offsetAnimation forKey:@"stp.scrollView.animation.offset"];
        
    } else {
        [self setZoomScale:scale];
        [self setContentOffset:targetOffset];
    }
    
}

- (void)_convertAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint _anchorPoint = self.zoomView.layer.anchorPoint;
    CGFloat toPointX = self.zoomView.frame.size.width * (_anchorPoint.x - anchorPoint.x);
    CGFloat toPointY = self.zoomView.frame.size.height * (_anchorPoint.y - anchorPoint.y);
    
    self.zoomView.layer.anchorPoint = anchorPoint;
    
    CGPoint position = self.zoomView.layer.position;
    position.x = position.x - toPointX;
    position.y = position.y - toPointY;
    self.zoomView.layer.position = position;
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
        if (finished) {
            _lock = NO;
            _directionalLockHorizontal = NO;
            _directionalLockVertical = NO;
        }
    }
    
    
    
}

@end
