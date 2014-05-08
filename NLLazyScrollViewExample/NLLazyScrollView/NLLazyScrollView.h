//
//  NLLazyScrollView.h
//  Lazy Loading UIScrollView for iOS
//
//  Created by Nathan Li on 24/11/12.
//  Copyright (c) 2012 Nathan Li. All rights reserved.
//  Distribuited under MIT License
//

#import <UIKit/UIKit.h>
#import "NLLazyScrollPageView.h"

@class NLLazyScrollView;

enum {
    NLLazyScrollViewDirectionHorizontal =   0,
    NLLazyScrollViewDirectionVertical   =   1,
};typedef NSUInteger NLLazyScrollViewDirection;

enum {
    NLLazyScrollViewTransitionAuto      =   0,
    NLLazyScrollViewTransitionForward   =   1,
    NLLazyScrollViewTransitionBackward  =   2
}; typedef NSUInteger NLLazyScrollViewTransition;

@protocol NLLazyScrollViewDelegate <NSObject>
@optional
- (void)lazyScrollViewWillBeginDragging:(NLLazyScrollView *)pagingView;
//Called when it scrolls, except from as the result of self-driven animation.
- (void)lazyScrollViewDidScroll:(NLLazyScrollView *)pagingView at:(CGPoint) visibleOffset;
//Called whenever it scrolls: through user manipulation, setup, or self-driven animation.
- (void)lazyScrollViewDidScroll:(NLLazyScrollView *)pagingView at:(CGPoint) visibleOffset withSelfDrivenAnimation:(BOOL)selfDrivenAnimation;
- (void)lazyScrollViewDidEndDragging:(NLLazyScrollView *)pagingView;
- (void)lazyScrollViewWillBeginDecelerating:(NLLazyScrollView *)pagingView;
- (void)lazyScrollViewDidEndDecelerating:(NLLazyScrollView *)pagingView atPageIndex:(NSInteger)pageIndex;
- (void)lazyScrollView:(NLLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex;
@end

@protocol NLLazyScrollViewDataSource <NSObject>
@required
- (NLLazyScrollPageView *)lazyScrollView:(NLLazyScrollView *)lazyScrollView atPageIndex:(NSInteger)pageIndex;

@end

@interface NLLazyScrollView : UIScrollView

@property (nonatomic, weak)   id<NLLazyScrollViewDataSource>  dataSource;
@property (nonatomic, weak)   id<NLLazyScrollViewDelegate>    controlDelegate;

@property (nonatomic,assign)    NSUInteger                      numberOfPages;
@property (readonly)            NSUInteger                      currentPage;
@property (readonly)            NLLazyScrollViewDirection       direction;

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) CGFloat autoPlayTime; //default 3 seconds

- (id)initWithFrameAndDirection:(CGRect)frame
                      direction:(NLLazyScrollViewDirection)direction
                 circularScroll:(BOOL) circularScrolling;
- (NLLazyScrollPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier;
- (void)setEnableCircularScroll:(BOOL)circularScrolling;
- (BOOL)circularScrollEnabled;

- (void) reloadData;

- (void) setPage:(NSInteger) index animated:(BOOL) animated;
- (void) setPage:(NSInteger) newIndex transition:(NLLazyScrollViewTransition) transition animated:(BOOL) animated;
- (void) moveByPages:(NSInteger) offset animated:(BOOL) animated;

- (NLLazyScrollPageView *) visibleView;

@end
