//
//  ADVGallery.m
//  
//
//  Created by Valentin Filip on 2/13/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "ADVGallery.h"
#import "SMPageControl.h"

#import <QuartzCore/QuartzCore.h>

@interface ADVGallery ()

@property (nonatomic, strong) UIScrollView  *scrollView;

@end




@implementation ADVGallery

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.clipsToBounds = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    
    [self addSubview:self.scrollView];
    
    imagePadding = 10;
}

- (void)didMoveToSuperview {
	[self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Accessors

- (void)setImages:(NSArray *)images {
    if ([_images isEqualToArray:images]) {
        return;
    }
    
    _images = images;
    
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageControl-dot"]];
    [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"pageControl-dot-selected"]];
    self.pageControl.numberOfPages = _images.count;
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = CGRectMake(20, 0, self.frame.size.width - 42, self.frame.size.height - self.pageControl.bounds.size.height);
}



#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = ceil((self.scrollView.contentOffset.x - (imagePadding/2))/self.scrollView.frame.size.width);
    
    self.pageControl.currentPage = index;
}


#pragma mark - SMPageControl delegate

- (void)pageControlValueChanged:(id)pageControl {
    [self.scrollView scrollRectToVisible:CGRectMake(ceil(((SMPageControl *)pageControl).currentPage) * self.scrollView.frame.size.width, 40, 1, 40) animated:YES];
}

@end
