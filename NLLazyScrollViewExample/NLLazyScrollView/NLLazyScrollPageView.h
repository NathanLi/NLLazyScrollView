//
//  NLLazyScrollPageView.h
//  Lazy Loading UIScrollView for iOS
//
//  Created by NathanLi on 14-5-7.
//  Copyright (c) 2014年 NathanLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLLazyScrollPageView : UIView
/**
 * The identifier used to categorize views into buckets for reuse.
 * Views will be reused when a new view is requested with a matching identifier.
 * If the reuseIdentifier is nil then the class name will be used.
 */
@property (nonatomic, copy) NSString *reuseIdentifier;

- initWithReuseIdentifier:(NSString *)reuseIdentifier;

/**
 * Called immediately after the view has been dequeued from the recycled view pool.
 */
- (void)prepareForReuse;

@end
