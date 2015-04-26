//
//  STPScrollView.h
//  STPScrollView
//
//  Created by Norikazu on 2015/04/26.
//  Copyright (c) 2015年 Stamp inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPScrollViewPanGestureRecognizer.h"

@protocol STPScrollViewDelegate;
@interface STPScrollView : UIView

@property (nonatomic)         CGPoint                      contentOffset;                  // default CGPointZero
@property (nonatomic)         CGSize                       contentSize;                    // default CGSizeZero
@property (nonatomic)         UIEdgeInsets                 contentInset;                   // default UIEdgeInsetsZero. add additional scroll area around content
@property (nonatomic,assign) id<STPScrollViewDelegate>      delegate;                       // default nil. weak reference
@property (nonatomic,getter=isDirectionalLockEnabled) BOOL directionalLockEnabled;         // default NO. if YES, try to lock vertical or horizontal scrolling while dragging
@property (nonatomic)         BOOL                         bounces;                        // default YES. if YES, bounces past edge of content and back again
@property (nonatomic)         BOOL                         alwaysBounceVertical;           // default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag vertically
@property (nonatomic)         BOOL                         alwaysBounceHorizontal;         // default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag horizontally
@property (nonatomic,getter=isPagingEnabled) BOOL          pagingEnabled;                  // default NO. if YES, stop on multiples of view bounds
@property (nonatomic,getter=isScrollEnabled) BOOL          scrollEnabled;                  // default YES. turn off any dragging temporarily
@property (nonatomic)         CGFloat                      decelerationRate;

@property(nonatomic) CGFloat minimumZoomScale;     // default is 1.0
@property(nonatomic) CGFloat maximumZoomScale;     // default is 1.0. must be > minimum zoom scale to enable zooming

@property(nonatomic) CGFloat zoomScale;            // default is 1.0
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

@property(nonatomic) BOOL  bouncesZoom;          // default is YES. if set, user can go past min/max zoom while gesturing and the zoom will animate to the min/max value at gesture end

@property(nonatomic,readonly,getter=isZooming)       BOOL zooming;       // returns YES if user in zoom gesture
@property(nonatomic,readonly,getter=isZoomBouncing)  BOOL zoomBouncing;  // returns YES if we are in the middle of zooming back to the min/max value


@property (nonatomic) STPScrollViewPanGestureRecognizer *panGestureRecognizer;


@end


@protocol STPScrollViewDelegate <NSObject>


@optional

- (void)scrollViewDidScroll:(STPScrollView *)scrollView;                                               // any offset changes
//- (void)scrollViewDidZoom:(STPScrollView *)scrollView; // any zoom scale changes

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(STPScrollView *)scrollView;
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(STPScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(STPScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDecelerating:(STPScrollView *)scrollView;   // called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(STPScrollView *)scrollView;      // called when scroll view grinds to a halt


//- (void)scrollViewDidEndScrollingAnimation:(STPScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating

- (UIView *)viewForZoomingInScrollView:(STPScrollView *)scrollView;     // return a view that will be scaled. if delegate returns nil, nothing happens
/*
- (void)scrollViewWillBeginZooming:(STPScrollView *)scrollView withView:(UIView *)view; // called before the scroll view begins zooming its content
- (void)scrollViewDidEndZooming:(STPScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations

- (BOOL)scrollViewShouldScrollToTop:(STPScrollView *)scrollView;   // return a yes if you want to scroll to the top. if not defined, assumes YES
- (void)scrollViewDidScrollToTop:(STPScrollView *)scrollView;      // called when scrolling animation finished. may be called immediately if already at top
*/
@end
