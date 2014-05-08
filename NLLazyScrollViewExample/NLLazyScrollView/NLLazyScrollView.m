//
//  NLLazyScrollView.m
//  Lazy Loading UIScrollView for iOS
//
//  Created by Nathan Li on 24/11/12.
//  Copyright (c) 2012 Nathan Li. All rights reserved.
//  Distribuited under MIT License
//

#import "NLLazyScrollView.h"

enum {
    NLLazyScrollViewScrollDirectionBackward     = 0,
    NLLazyScrollViewScrollDirectionForward      = 1
}; typedef NSUInteger NLLazyScrollViewScrollDirection;

#define kNLLazyScrollViewTransitionDuration     0.4

@interface NLLazyScrollView() <UIScrollViewDelegate> {
    NSUInteger      numberOfPages;
    NSUInteger      currentPage;
    BOOL            isManualAnimating;
    BOOL            circularScrollEnabled;
}
@property (nonatomic, strong) NSTimer* timer_autoPlay;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifiersToRecycledViews;
@end

@implementation NLLazyScrollView

@synthesize numberOfPages,currentPage;
@synthesize controlDelegate;
@synthesize autoPlay = _autoPlay;
@synthesize timer_autoPlay = _timer_autoPlay;
@synthesize autoPlayTime = _autoPlayTime;

#pragma mark - Life cycle
- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrameAndDirection:frame direction:NLLazyScrollViewDirectionHorizontal circularScroll:NO];
}

- (id)initWithFrameAndDirection:(CGRect)frame
                      direction:(NLLazyScrollViewDirection)direction
                 circularScroll:(BOOL) circularScrolling {
    
    self = [super initWithFrame:frame];
    if (self) {
        _direction = direction;
        circularScrollEnabled = circularScrolling;
        _autoPlayTime = 3;
        [self initializeControl];
      
      _reuseIdentifiersToRecycledViews = [[NSMutableDictionary alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduceMemoryUsage) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NLLazyScrollPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
  if (nil == identifier) {
    return nil;
  }
  
  NSMutableArray *views = [_reuseIdentifiersToRecycledViews objectForKey:identifier];
  NLLazyScrollPageView *view = [views lastObject];
  if (nil != view) {
    [views removeObject:view];
    [view prepareForReuse];
  }

  return view;
}

- (void)setAutoPlay:(BOOL)autoPlay
{
    _autoPlay = autoPlay;
    if(self.numberOfPages)
    {
        [self reloadData];
    }
}

- (BOOL)hasMultiplePages {
    return numberOfPages > 1;
}

- (void)resetAutoPlay
{
    if(_autoPlay)
    {
        if(_timer_autoPlay)
        {
            [_timer_autoPlay invalidate];
            _timer_autoPlay = nil;
        }
        _timer_autoPlay = [NSTimer scheduledTimerWithTimeInterval:_autoPlayTime target:self selector:@selector(autoPlayHanlde:) userInfo:nil repeats:YES];
    }
    else
    {
        if(_timer_autoPlay)
        {
            [_timer_autoPlay invalidate];
            _timer_autoPlay = nil;
        }
    }
}

- (void)autoPlayHanlde:(id)timer
{
    if ([self hasMultiplePages]) {
        [self autoPlayGoToNextPage];
    }
}

- (void)autoPlayGoToNextPage
{
    NSInteger nextPage = self.currentPage+1;
    if(nextPage >= self.numberOfPages)
    {
        nextPage = 0;
    }
    [self setPage:nextPage animated:YES];
}

- (void)autoPlayPause
{
    if(_timer_autoPlay)
    {
        [_timer_autoPlay invalidate];
        _timer_autoPlay = nil;
    }
}

- (void)autoPlayResume
{
    [self resetAutoPlay];
}

- (void)setEnableCircularScroll:(BOOL)circularScrolling
{
    circularScrollEnabled = circularScrolling;
}

- (BOOL)circularScrollEnabled
{
    return circularScrollEnabled;
}

- (void) awakeFromNib {
    [self initializeControl];
}

- (void) initializeControl {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.delegate = self;
    self.contentSize = CGSizeMake(self.frame.size.width, self.contentSize.height);
    currentPage = NSNotFound;
}

- (void) setNumberOfPages:(NSUInteger)pages {
    if (pages != numberOfPages) {
        numberOfPages = pages;
        int offset = [self hasMultiplePages] ? numberOfPages + 2 : 1;
        if (_direction == NLLazyScrollViewDirectionHorizontal) {
            self.contentSize = CGSizeMake(self.frame.size.width * offset,
                                          self.contentSize.height);
        } else {
            self.contentSize = CGSizeMake(self.frame.size.width,
                                          self.frame.size.height * offset);
        }
        [self reloadData];
    }
}

- (void) reloadData {
    [self setCurrentView:0];
    [self resetAutoPlay];
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (CGRect) visibleRect {
    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.bounds.size;
    return visibleRect;
}

- (CGPoint) createPoint:(CGFloat) size {
    if (_direction == NLLazyScrollViewDirectionHorizontal) {
        return CGPointMake(size, 0);
    } else {
        return CGPointMake(0, size);
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.bounces = YES;
    if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewDidEndDragging:)])
        [controlDelegate lazyScrollViewDidEndDragging:self];
    [self autoPlayResume];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self autoPlayPause];
    if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewWillBeginDragging:)])
        [controlDelegate lazyScrollViewWillBeginDragging:self];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isManualAnimating) {
        if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewDidScroll:at:withSelfDrivenAnimation:)]) {
            [controlDelegate lazyScrollViewDidScroll:self at:[self visibleRect].origin withSelfDrivenAnimation:YES];
        }
        return;
    }
    
    CGFloat offset = (_direction==NLLazyScrollViewDirectionHorizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y;
    CGFloat size =(_direction==NLLazyScrollViewDirectionHorizontal) ? self.frame.size.width : self.frame.size.height;
    
    
    // with two pages only scrollview you can only go forward
    // (this prevents us to have a glitch with the next UIView (it can't be placed in two positions at the same time)
    NLLazyScrollViewScrollDirection proposedScroll = (offset <= (size*2) ?
                                                      NLLazyScrollViewScrollDirectionBackward : // we're moving back
                                                      NLLazyScrollViewScrollDirectionForward); // we're moving forward

    // you can go back if circular mode is enabled or your current page is not the first page
    BOOL canScrollBackward = (circularScrollEnabled || (!circularScrollEnabled && self.currentPage != 0));
    // you can go forward if circular mode is enabled and current page is not the last page
    BOOL canScrollForward = (circularScrollEnabled || (!circularScrollEnabled && self.currentPage < (self.numberOfPages-1)));
    
    NSInteger prevPage = [self pageIndexByAdding:-1 from:self.currentPage];
    NSInteger nextPage = [self pageIndexByAdding:+1 from:self.currentPage];
    if (prevPage == nextPage) {
        // This happends when our scrollview have only two and we should have the same prev/next page at left/right
        // A single UIView instance can't be in two different location at the same moment so we need to place it
        // loooking at proposed direction
        [self loadViewAtIndex:prevPage andPlaceAtIndex:(proposedScroll == NLLazyScrollViewScrollDirectionBackward ? -1 : 1)];
    }

    if ( (proposedScroll == NLLazyScrollViewScrollDirectionBackward && !canScrollBackward) ||
         (proposedScroll == NLLazyScrollViewScrollDirectionForward && !canScrollForward)) {
        self.bounces = NO;
        [scrollView setContentOffset:[self createPoint:size*2] animated:NO];
        return;
    } else self.bounces = YES;

    NSInteger newPageIndex = currentPage;
    
    if (offset <= size)
        newPageIndex = [self pageIndexByAdding:-1 from:currentPage];
    else if (offset >= (size*3))
        newPageIndex = [self pageIndexByAdding:+1 from:currentPage];
    
    [self setCurrentView:newPageIndex];
    
    // alert delegate
    if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewDidScroll:at:withSelfDrivenAnimation:)]) {
        [controlDelegate lazyScrollViewDidScroll:self at:[self visibleRect].origin withSelfDrivenAnimation:NO];
    }
    else if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewDidScroll:at:)]) {
        [controlDelegate lazyScrollViewDidScroll:self at:[self visibleRect].origin];
    }
}

- (void) setCurrentView:(NSInteger) index {
    if (index == currentPage) return;
    currentPage = index;
  
  for (NLLazyScrollPageView *view in self.subviews) {
    [self recycleView:view];
    [view removeFromSuperview];
  }
  
    NSInteger prevPage = [self pageIndexByAdding:-1 from:currentPage];
    NSInteger nextPage = [self pageIndexByAdding:+1 from:currentPage];
    
    [self loadViewAtIndex:index andPlaceAtIndex:0];
    // Pre-load the content for the adjacent pages if multiple pages are to be displayed
    if ([self hasMultiplePages]) {
        [self loadViewAtIndex:prevPage andPlaceAtIndex:-1];   // load previous page
        [self loadViewAtIndex:nextPage andPlaceAtIndex:1];   // load next page
    }

    CGFloat size =(_direction==NLLazyScrollViewDirectionHorizontal) ? self.frame.size.width : self.frame.size.height;
    
    self.contentOffset = [self createPoint:size * ([self hasMultiplePages] ? 2 : 0)]; // recenter
    
    if ([self.controlDelegate respondsToSelector:@selector(lazyScrollView:currentPageChanged:)])
        [self.controlDelegate lazyScrollView:self currentPageChanged:self.currentPage];
}

- (NLLazyScrollPageView *) visibleView {
    __block NLLazyScrollPageView *visibleView = nil;
    [self.subviews enumerateObjectsUsingBlock:^(NLLazyScrollPageView *subView, NSUInteger idx, BOOL *stop) {
        if (CGRectIntersectsRect([self visibleRect], subView.frame)) {
            visibleView = subView;
            *stop = YES;
        }
    }];
  
  return visibleView;
}

- (NSInteger) pageIndexByAdding:(NSInteger) offset from:(NSInteger) index {
    // Complicated stuff with negative modulo
    while (offset<0) offset += numberOfPages;
    return (numberOfPages+index+offset) % numberOfPages;

}

- (void) moveByPages:(NSInteger) offset animated:(BOOL) animated {
    NSUInteger finalIndex = [self pageIndexByAdding:offset from:self.currentPage];
    NLLazyScrollViewTransition transition = (offset >= 0 ?  NLLazyScrollViewTransitionForward :
                                             NLLazyScrollViewTransitionBackward);
    [self setPage:finalIndex transition:transition animated:animated];
}

- (void) setPage:(NSInteger) newIndex animated:(BOOL) animated {
    [self setPage:newIndex transition:NLLazyScrollViewTransitionForward animated:animated];
}

- (void) setPage:(NSInteger) newIndex transition:(NLLazyScrollViewTransition) transition animated:(BOOL) animated {
    if (newIndex == currentPage) return;
    
    if (animated) {
        //BOOL isOnePageMove = (abs(self.currentPage-newIndex) == 1);
        CGPoint finalOffset;
        
        if (transition == NLLazyScrollViewTransitionAuto) {
            if (newIndex > self.currentPage) transition = NLLazyScrollViewTransitionForward;
            else if (newIndex < self.currentPage) transition = NLLazyScrollViewTransitionBackward;
        }
        
        CGFloat size =(_direction==NLLazyScrollViewDirectionHorizontal) ? self.frame.size.width : self.frame.size.height;
        
        if (transition == NLLazyScrollViewTransitionForward) {
            //if (!isOnePageMove)
                //[self loadControllerAtIndex:newIndex andPlaceAtIndex:2];
            [self loadViewAtIndex:newIndex andPlaceAtIndex:1];
            
            //finalOffset = [self createPoint:(size*(isOnePageMove ? 3 : 4))];
            finalOffset = [self createPoint:(size*3)];
        } else {
            //if (!isOnePageMove)
                //[self loadControllerAtIndex:newIndex andPlaceAtIndex:-2];
            [self loadViewAtIndex:newIndex andPlaceAtIndex:-1];
            
            //finalOffset = [self createPoint:(size*(isOnePageMove ? 1 : 0))];
            finalOffset = [self createPoint:(size*1)];
        }
        isManualAnimating = YES;
        
        [UIView animateWithDuration:kNLLazyScrollViewTransitionDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.contentOffset = finalOffset;
                         } completion:^(BOOL finished) {
                             if (!finished) return;
                             [self setCurrentView:newIndex];
                             isManualAnimating = NO;
                         }];
    } else {
        [self setCurrentView:newIndex];
    }
}

- (void) setCurrentPage:(NSUInteger)newCurrentPage {
    [self setCurrentView:newCurrentPage];
}

- (void)recycleView:(NLLazyScrollPageView *)pageView {
  NSString *reuseIdentifier = pageView.reuseIdentifier;
  if (nil == reuseIdentifier) {
    reuseIdentifier = NSStringFromClass([pageView class]);
  }
  
  if (nil == reuseIdentifier) return;
  
  NSMutableArray *pageViews = [_reuseIdentifiersToRecycledViews objectForKey:reuseIdentifier];
  if (nil == pageViews) {
    pageViews = [[NSMutableArray alloc] init];
    [_reuseIdentifiersToRecycledViews setObject:pageViews forKey:reuseIdentifier];
  }
  
  [pageViews addObject:pageView];
}

- (NLLazyScrollPageView *) loadViewAtIndex:(NSInteger) index andPlaceAtIndex:(NSInteger) destIndex {
  NLLazyScrollPageView *pageView = [self.dataSource lazyScrollView:self atPageIndex:index];
  
    CGRect viewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    int offset = [self hasMultiplePages] ? 2 : 0;
    if (_direction == NLLazyScrollViewDirectionHorizontal) {
        viewFrame = CGRectOffset(viewFrame, self.frame.size.width * (destIndex + offset), 0);
    } else {
        viewFrame = CGRectOffset(viewFrame, 0, self.frame.size.height * (destIndex + offset));
    }
    pageView.frame = viewFrame;
    
    [self addSubview:pageView];
    return pageView;
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewWillBeginDecelerating:)])
        [controlDelegate lazyScrollViewWillBeginDecelerating:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (nil != controlDelegate && [controlDelegate respondsToSelector:@selector(lazyScrollViewDidEndDecelerating:atPageIndex:)])
        [controlDelegate lazyScrollViewDidEndDecelerating:self atPageIndex:self.currentPage];
}

#pragma mark - Memory Warnings
- (void)reduceMemoryUsage {
  [_reuseIdentifiersToRecycledViews removeAllObjects];
}

@end
