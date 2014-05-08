//
//  NLViewController.m
//  NLLazyScrollViewExample
//
//  Created by Nathan Li on 24/11/12.
//  Copyright (c) 2012 Nathan Li. All rights reserved.
//

#import "NLViewController.h"
#import "NLLazyScrollView.h"

#define ARC4RANDOM_MAX	0x100000000


@interface NLViewController () <NLLazyScrollViewDelegate, NLLazyScrollViewDataSource> {
    NLLazyScrollView* lazyScrollView;
    NSMutableArray*    viewControllerArray;
}
@end

@implementation NLViewController

- (NLLazyScrollPageView *)lazyScrollView:(NLLazyScrollView *)lazyScrollView_ atPageIndex:(NSInteger)pageIndex {
  NLLazyScrollPageView *pageView = [lazyScrollView_ dequeueReusablePageWithIdentifier:@"NLLazyScrollView"];
  if (pageView == nil) {
    pageView = [[NLLazyScrollPageView alloc] initWithReuseIdentifier:@"NLLazyScrollView"];
  }
  
  pageView.backgroundColor = [UIColor colorWithRed: ((double)pageIndex + 10) * 10 / 255.0
                                             green: ((double)pageIndex) * pageIndex / 255.0
                                              blue: ((double)pageIndex) * 20 / 255.0
                                             alpha: 1.0f];
  [[pageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  UILabel* label = [[UILabel alloc] initWithFrame:self.view.bounds];
  label.text = [NSString stringWithFormat:@"%d",pageIndex];
  label.backgroundColor = [UIColor clearColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.font = [UIFont boldSystemFontOfSize:50];
  label.textColor = [UIColor whiteColor];
  [pageView addSubview:label];
  
  return pageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // PREPARE PAGES
    NSUInteger numberOfPages = 10;
    viewControllerArray = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    for (NSUInteger k = 0; k < numberOfPages; ++k) {
        [viewControllerArray addObject:[NSNull null]];
    }
    
    // PREPARE LAZY VIEW
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
    lazyScrollView = [[NLLazyScrollView alloc] initWithFrame:rect];
    [lazyScrollView setEnableCircularScroll:YES];

    [lazyScrollView setAutoPlay:YES];
  
//    __weak __typeof(&*self)weakSelf = self;
//    lazyScrollView.dataSource = ^(NSUInteger index) {
//        return [weakSelf controllerAtIndex:index];
//    };
    lazyScrollView.dataSource = self;
    lazyScrollView.numberOfPages = numberOfPages;

    lazyScrollView.controlDelegate = self;
  [lazyScrollView reloadData];
    [self.view addSubview:lazyScrollView];
    
    // MOVE BY 3 FORWARD
    UIButton*btn_moveForward = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn_moveForward setTitle:@"MOVE BY 3" forState:UIControlStateNormal];
    [btn_moveForward addTarget:self action:@selector(btn_moveForward:) forControlEvents:UIControlEventTouchUpInside];
    [btn_moveForward setFrame:CGRectMake(self.view.frame.size.width/2.0f,lazyScrollView.frame.origin.y+lazyScrollView.frame.size.height+5, 320/2.0f,40)];
    [self.view addSubview:btn_moveForward];
    
    // MOVE BY -3 BACKWARD
    UIButton*btn_moveBackward = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn_moveBackward setTitle:@"MOVE BY -3" forState:UIControlStateNormal];
    [btn_moveBackward addTarget:self action:@selector(btn_moveBack:) forControlEvents:UIControlEventTouchUpInside];
    [btn_moveBackward setFrame:CGRectMake(0,lazyScrollView.frame.origin.y+lazyScrollView.frame.size.height+5, 320/2.0f,40)];
    [self.view addSubview:btn_moveBackward];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)lazyScrollViewDidScroll:(NLLazyScrollView *)pagingView at:(CGPoint) visibleOffset {

}

- (void) btn_moveBack:(id) sender {
    [lazyScrollView moveByPages:-3 animated:YES];
}

- (void) btn_moveForward:(id) sender {
    [lazyScrollView moveByPages:3 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (UIViewController *) controllerAtIndex:(NSInteger) index {
    if (index > viewControllerArray.count || index < 0) return nil;
    id res = [viewControllerArray objectAtIndex:index];
    if (res == [NSNull null]) {
        UIViewController *contr = [[UIViewController alloc] init];
        contr.view.backgroundColor = [UIColor colorWithRed: (CGFloat)arc4random()/ARC4RANDOM_MAX
                                                      green: (CGFloat)arc4random()/ARC4RANDOM_MAX
                                                       blue: (CGFloat)arc4random()/ARC4RANDOM_MAX
                                                     alpha: 1.0f];
        
        UILabel* label = [[UILabel alloc] initWithFrame:contr.view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%d",index];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:50];
        [contr.view addSubview:label];
        
        [viewControllerArray replaceObjectAtIndex:index withObject:contr];
        return contr;
    }
    return res;
}

//- (void)lazyScrollViewDidEndDragging:(NLLazyScrollView *)pagingView {
//    NSLog(@"subviews count:%d", [[pagingView subviews] count]);
//}
@end