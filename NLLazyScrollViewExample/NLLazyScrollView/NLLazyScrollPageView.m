//
//  NLLazyScrollPageView.m
//  Lazy Loading UIScrollView for iOS
//
//  Created by NathanLi on 14-5-7.
//  Copyright (c) 2014年 NathanLi. All rights reserved.
//

#import "NLLazyScrollPageView.h"

@implementation NLLazyScrollPageView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super init]) {
    _reuseIdentifier = reuseIdentifier;
  }
  return self;
}

- (void)prepareForReuse {

}

- (void)didMoveToSuperview {
  
}
@end
