//
//  STPScrollView.m
//  STPScrollView
//
//  Created by Norikazu on 2015/04/26.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import "STPScrollView.h"
#import <POP.h>

#define RESISTANCE_INTERACTIVE 2.3
#define BOUNCES_SPRINGSPEED 4


typedef NS_ENUM(NSInteger, STPScrollViewScrollDirection)
{
    STPScrollViewScrollDirectionEvery,
    STPScrollViewScrollDirectionVertical,
    STPScrollViewScrollDirectionHorizontal
};

const CGFloat STPScrollViewDecelerationRateNormal = 0.997;
const CGFloat STPScrollViewDecelerationRateFast = 0.985;


@interface STPScrollView () <UIGestureRecognizerDelegate, POPAnimationDelegate>
{
    CGPoint _initialTouchPoint;
    CGFloat _initialZoomScale;
    CGPoint _initialZoomViewPosition;
    
    // Pinch Gestureでzoomによるoffset設定に使用
    CGPoint _initialScalePosition;
    CGPoint _previousScalePosition;
    
    
    CGPoint _previousZoomViewOrigin;
    CGPoint _previousPosition;
    CGAffineTransform _initialTransform;
    BOOL _animating;
    BOOL _deceleratingX;
    BOOL _deceleratingY;
    BOOL _directionalLock;
    NSTimeInterval _lastTouchTime;
    
}

@property (nonatomic) UIView *zoomView;
@property (nonatomic) STPScrollViewScrollDirection direction;


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
    
    _directionalLock = NO;
    _direction = STPScrollViewScrollDirectionEvery;
    
    self.clipsToBounds = YES;
    
    _panGestureRecognizer = [[STPScrollViewPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _pinchGestureRecognizer = [[STPScrollViewPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
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

- (CGRect)availableRect
{
    return UIEdgeInsetsInsetRect(self.bounds, _contentInset);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.x"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.y"];
    [self pop_removeAnimationForKey:@"stp.scrollView.animation.offset"];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGRect visibleRect = (CGRect){self.contentOffset, self.bounds.size};
    CGPoint offset = self.contentOffset;
    
    if (minX <= CGRectGetMinX(visibleRect)) {
        offset.x = minX;
    }
    
    if (CGRectGetMaxX(visibleRect) <= maxX) {
        offset.x = maxX - visibleRect.size.width;
    }
    
    if (minY <= CGRectGetMinY(visibleRect)) {
        offset.y = minY;
    }
    
    if (CGRectGetMaxY(visibleRect) <= maxY) {
        offset.y = maxY - visibleRect.size.height;
    }
    
    [self setContentOffset:[self _limitOffset:offset] animated:animated];
}

#pragma mark - ContentOffset

- (void)setContentOffset:(CGPoint)contentOffset
{
    
    CGFloat deltaX = contentOffset.x - _contentOffset.x;
    CGFloat deltaY = contentOffset.y - _contentOffset.y;
    CGPoint deltaPoint = CGPointMake(deltaX, deltaY);
    _contentOffset = contentOffset;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        
        //NSLog(@"-position %@", NSStringFromCGPoint(view.layer.frame.origin));
        
        view.layer.position = CGPointMake(view.layer.position.x - deltaPoint.x, view.layer.position.y - deltaPoint.y);

        //NSLog(@"+position %@", NSStringFromCGPoint(view.layer.frame.origin));
        //view.layer.frame = (CGRect){CGPointMake(view.layer.frame.origin.x - deltaPoint.x, view.layer.frame.origin.y - deltaPoint.y), view.layer.frame.size};
    }];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:self];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset bounces:(BOOL)bounces
{
    
    CGFloat availableOffsetX = self.contentSize.width + self.contentInset.left - (self.bounds.size.width - self.contentInset.right);
    CGFloat availableOffsetY = self.contentSize.height + self.contentInset.top - (self.bounds.size.height - self.contentInset.bottom);
    
    availableOffsetX = MAX(0, availableOffsetX);
    availableOffsetY = MAX(0, availableOffsetY);
    
    CGFloat targetOffsetX = -(self.contentInset.left - availableOffsetX);
    CGFloat targetOffsetY = -(self.contentInset.top - availableOffsetY);
    
    if (bounces) {
        
        if (contentOffset.x <= -self.contentInset.left || targetOffsetX <= contentOffset.x) {
            
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
                    bouncsAnimation.springSpeed = BOUNCES_SPRINGSPEED;
                    bouncsAnimation.velocity = decayAnimation.velocity;
                    bouncsAnimation.delegate = self;
                    
                    if (contentOffset.x <= self.contentInset.left) {
                        bouncsAnimation.toValue = @(-self.contentInset.left);
                    }
                    
                    if (targetOffsetX <= contentOffset.x) {
                        bouncsAnimation.toValue = @(targetOffsetX);
                    }
                    
                    [self pop_addAnimation:bouncsAnimation forKey:@"stp.scrollView.animation.bounce.x"];
                    return;
                }
            }
        }
        if (contentOffset.y <= -self.contentInset.top || targetOffsetY <= contentOffset.y) {
            
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
                    bouncsAnimation.springSpeed = BOUNCES_SPRINGSPEED;
                    bouncsAnimation.velocity = decayAnimation.velocity;
                    bouncsAnimation.delegate = self;
                    
                    if (contentOffset.y <= -self.contentInset.top) {
                        bouncsAnimation.toValue = @(-self.contentInset.top);
                    }
                    
                    if (targetOffsetY <= contentOffset.y) {
                        bouncsAnimation.toValue = @(targetOffsetY);
                    }
                    
                    [self pop_addAnimation:bouncsAnimation forKey:@"stp.scrollView.animation.bounce.y"];
                    return;
                }
            }
        }

        [self setContentOffset:contentOffset];
    } else {
    
        CGPoint contentOffset = self.contentOffset;
        
        if (contentOffset.x <= self.contentInset.left || availableOffsetX <= contentOffset.x) {
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.x"];
            if (contentOffset.x <= self.contentInset.left) {
                contentOffset.x = -self.contentInset.left;
            }
            
            if (availableOffsetX <= contentOffset.x) {
                contentOffset.x = availableOffsetX;
            }
        }
        
        if (contentOffset.y <= self.contentInset.top || availableOffsetY <= contentOffset.y) {
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.y"];
            if (contentOffset.y <= self.contentInset.top) {
                contentOffset.y = -self.contentInset.top;
            }
            
            if (availableOffsetY <= contentOffset.y) {
                contentOffset.y = availableOffsetY;
            }
        }
        
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
                contentOffset.x = values[0];
                [obj setContentOffset:contentOffset];
                
            };
            
            prop.threshold = 0.01;
        }];
        animationX.toValue = @(contentOffset.x);
        animationX.delegate = self;
        animationX.completionBlock = ^(POPAnimation *anim, BOOL finished) {
            
            animationXFinished = NO;
            
        };
        [self pop_addAnimation:animationX forKey:@"stp.scrollView.animation.scroll.x"];
        
        
        POPBasicAnimation *animationY = [POPBasicAnimation animation];
        animationY.property = [POPAnimatableProperty propertyWithName:@"stp.scrollView.animation.scroll.property.y" initializer:^(POPMutableAnimatableProperty *prop) {
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
            
        };
        [self pop_addAnimation:animationY forKey:@"stp.scrollView.animation.scroll.y"];
        
    } else {
        [self setContentOffset:contentOffset];
    }
}

#pragma mark - zoom 

- (UIView *)zoomView
{
    if ([self.delegate viewForZoomingInScrollView:self]) {
        return [self.delegate viewForZoomingInScrollView:self];
    }
    return nil;
}


- (void)_setZoomScale:(CGFloat)zoomScale
{
    if (zoomScale == _zoomScale) {
        return;
    }
    
    [self _convertAnchorPoint:CGPointMake(0, 0)];
    
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
    [self _convertAnchorPoint:CGPointMake(0.5, 0.5)];
    
}

- (void)setZoomScale:(CGFloat)zoomScale
{
    if (zoomScale == _zoomScale) {
        return;
    }
    
    [self _convertAnchorPoint:CGPointMake(0, 0)];
    
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
    [self _convertAnchorPoint:CGPointMake(0.5, 0.5)];
    self.contentSize = self.zoomView.layer.frame.size;
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.delegate scrollViewDidZoom:self];
    }
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
                [obj _setZoomScale:values[0]];
            };
            prop.threshold = 0.01;
        }];
        zoomAnimation.property = prop;
        zoomAnimation.toValue = @(scale);
        zoomAnimation.delegate = self;
        zoomAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished){
            _zoomBouncing = NO;
            if (finished) {
                if ([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
                    [self.delegate scrollViewDidEndZooming:self withView:self.zoomView atScale:scale];
                }
            }
        };
        
        [self pop_addAnimation:zoomAnimation forKey:@"stp.scrollView.animation.zoom"];
        
    } else {
        [self _setZoomScale:scale];
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


#pragma mark - Pan Gesture

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
            
            if (self.directionalLockEnabled) {
                if (!_directionalLock) {
                    CGFloat x = translation.x * translation.x;
                    CGFloat y = translation.y * translation.y;

                    if (x > y) {
                        _directionalLock = YES;
                        _direction = STPScrollViewScrollDirectionHorizontal;
                    }
                    if (x < y) {
                        _directionalLock = YES;
                        _direction = STPScrollViewScrollDirectionVertical;
                    }
                }
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
            _tracking = NO;
            _dragging = YES;
            _decelerating = NO;
            

            CGPoint contentOffset = self.contentOffset;            
            CGFloat translationX = translation.x;
            CGFloat translationY = translation.y;
            
            if (self.directionalLockEnabled) {
                if (_direction == STPScrollViewScrollDirectionVertical) {
                    translationX = 0;
                }
                if (_direction == STPScrollViewScrollDirectionHorizontal) {
                    translationY = 0;
                }
            }
            
            if (!self.alwaysBounceHorizontal) {
                if (self.contentSize.width <= [self availableRect].size.width) {
                    translationX = 0;
                }
            }
            
            if (!self.alwaysBounceVertical) {
                if (self.contentSize.height <= [self availableRect].size.height) {
                    translationY = 0;
                }
            }
            
            
            // contentSizeを超えたときの抵抗
            if ([self _overAvailableOffsetX:contentOffset]) {
                translationX = translationX / RESISTANCE_INTERACTIVE;
            }
            
            if ([self _overAvailableOffsetY:contentOffset]) {
                translationY = translationY / RESISTANCE_INTERACTIVE;
            }
            
            if (!self.bounces) {
                if ([self _overAvailableOffsetX:contentOffset]) {
                    translationX = 0;
                }
                
                if ([self _overAvailableOffsetY:contentOffset]) {
                    translationY = 0;
                }
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
            
            CGPoint contentOffset = self.contentOffset;
            CGFloat velocityX = velocity.x;
            CGFloat velocityY = velocity.y;
            
            if (self.directionalLockEnabled) {
                if (_direction == STPScrollViewScrollDirectionVertical) {
                    velocityX = 0;
                }
                if (_direction == STPScrollViewScrollDirectionHorizontal) {
                    velocityY = 0;
                }
            }
            
            if (!self.alwaysBounceHorizontal) {
                if (self.contentSize.width <= [self availableRect].size.width) {
                    velocityX = 0;
                }
            }
            
            if (!self.alwaysBounceVertical) {
                if (self.contentSize.height <= [self availableRect].size.height) {
                    velocityY = 0;
                }
            }
            
            
            if ([self _overAvailableOffsetX:contentOffset]) {
                velocityX = velocityX / RESISTANCE_INTERACTIVE;
            }
            
            if ([self _overAvailableOffsetY:contentOffset]) {
                velocityY = velocityY / RESISTANCE_INTERACTIVE;
            }
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
                [self.delegate scrollViewDidEndDragging:self willDecelerate:self.bounces];
            }
            
            if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                [self.delegate scrollViewDidEndDecelerating:self];
            }
            
            _animating = YES;
            
            // declerating X content offset
            _deceleratingX = YES;
            
            POPDecayAnimation *decayAnimationX = [self pop_animationForKey:@"stp.scrollView.animation.decay.x"];
            if (!decayAnimationX) {
                decayAnimationX = [POPDecayAnimation animation];
            }

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
            decayAnimationX.velocity = @(-velocityX);
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
            
            POPDecayAnimation *decayAnimationY = [self pop_animationForKey:@"stp.scrollView.animation.decay.y"];
            if (!decayAnimationY) {
                decayAnimationY = [POPDecayAnimation animation];
            }
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
            decayAnimationY.velocity = @(-velocityY);
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

#pragma mark - Pinch Gesture

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.zoom"];
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.x"];
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.decay.y"];
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.x"];
            [self pop_removeAnimationForKey:@"stp.scrollView.animation.bounce.y"];
            
            _zooming = YES;
            _initialTouchPoint = location;
            _previousPosition = location;
            _initialTransform = self.zoomView.layer.affineTransform;
            _lastTouchTime = CFAbsoluteTimeGetCurrent();
            
            [recognizer setScale:self.zoomScale];
            _initialScalePosition = CGPointMake(_initialTouchPoint.x * self.zoomScale, _initialTouchPoint.y * self.zoomScale);
            _previousScalePosition = _initialScalePosition;
            
            if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
                [self.delegate scrollViewWillBeginZooming:self withView:self.zoomView];
            }
            
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
            CGFloat targetScale = recognizer.scale;
            
            if (self.bouncesZoom) {
                if (targetScale <= self.minimumZoomScale) {
                    targetScale = self.minimumZoomScale - (self.minimumZoomScale - targetScale) / RESISTANCE_INTERACTIVE;
                }
                
                if (self.maximumZoomScale <= targetScale) {
                    targetScale = self.maximumZoomScale + (targetScale - self.maximumZoomScale) / RESISTANCE_INTERACTIVE;
                }
            } else {
                if (targetScale <= self.minimumZoomScale) {
                    targetScale = self.minimumZoomScale;
                }
                
                if (self.maximumZoomScale <= targetScale) {
                    targetScale = self.maximumZoomScale;
                }
            }
            
            [self setZoomScale:targetScale];
            
            CGPoint translation = CGPointMake(location.x - _previousPosition.x, location.y - _previousPosition.y);
            CGFloat translationX = translation.x;
            CGFloat translationY = translation.y;
            CGPoint scalePosition = CGPointMake(_initialTouchPoint.x * self.zoomScale, _initialTouchPoint.y * self.zoomScale);
            CGPoint scaleTranslation = CGPointMake(_previousScalePosition.x - scalePosition.x, _previousScalePosition.y - scalePosition.y);
            
            self.contentOffset = CGPointMake(self.contentOffset.x - translationX/RESISTANCE_INTERACTIVE - scaleTranslation.x, self.contentOffset.y - translationY/RESISTANCE_INTERACTIVE  - scaleTranslation.y);
            
            _previousScalePosition = scalePosition;
            _previousPosition = location;
            
            _lastTouchTime = CFAbsoluteTimeGetCurrent();
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _zooming = NO;
            
            CGFloat targetScale = recognizer.scale;
            
            
            if (targetScale < self.minimumZoomScale) {
                targetScale = self.minimumZoomScale;
            }
            
            if (self.maximumZoomScale < targetScale) {
                targetScale = self.maximumZoomScale;
            }
            
            self.contentSize = CGSizeMake(targetScale * self.zoomView.layer.bounds.size.width, targetScale * self.zoomView.layer.bounds.size.height);
            [self setZoomScale:targetScale animated:self.bouncesZoom];
            
            NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
            CGPoint translation = CGPointMake(location.x - _previousPosition.x, location.y - _previousPosition.y);
            
            CGFloat velocityX = POPPixelsToPoints(translation.x) / (currentTime - _lastTouchTime);
            CGFloat velocityY = POPPixelsToPoints(translation.y) / (currentTime - _lastTouchTime);
            
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
            decayAnimationX.velocity = @(-velocityX);
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
            decayAnimationY.velocity = @(-velocityY);
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

- (BOOL)_overAvailableOffsetX:(CGPoint)contentOffset
{
    CGFloat availableOffsetX = self.contentSize.width + self.contentInset.left - (self.bounds.size.width - self.contentInset.right);

    availableOffsetX = MAX(0, availableOffsetX);
    CGFloat targetOffsetX = -(self.contentInset.left - availableOffsetX);
    return (contentOffset.x <= -self.contentInset.left || targetOffsetX <= contentOffset.x);
}

- (BOOL)_overAvailableOffsetY:(CGPoint)contentOffset
{
    CGFloat availableOffsetY = self.contentSize.height + self.contentInset.top - (self.bounds.size.height - self.contentInset.bottom);
    availableOffsetY = MAX(0, availableOffsetY);
    CGFloat targetOffsetY = -(self.contentInset.top - availableOffsetY);
    return (contentOffset.y <= -self.contentInset.top || targetOffsetY <= contentOffset.y);
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

- (CGPoint)_limitOffset:(CGPoint)offset
{
    CGFloat maxX = self.contentSize.width - self.bounds.size.width;
    CGFloat maxY = self.contentSize.height - self.bounds.size.height;
    
    if (offset.x < 0) {
        offset.x = 0;
    }
    if (maxX < offset.x) {
        offset.x = maxX;
    }
    
    if (offset.y < 0) {
        offset.y = 0;
    }
    if (maxY < offset.y) {
        offset.y = maxY;
    }
    
    return offset;
}

static inline CGFloat POPPixelsToPoints(CGFloat pixels) {
    static CGFloat scale = -1;
    if (scale < 0) {
        scale = [UIScreen mainScreen].scale;
    }
    return pixels / scale;
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
    
    if (finished) {
        if ([[self pop_animationKeys] count] == 0) {
            _animating = NO;
            _directionalLock = NO;
        }
    }
    
    
}

- (void)dealloc
{
    [self pop_removeAllAnimations];
}

@end
