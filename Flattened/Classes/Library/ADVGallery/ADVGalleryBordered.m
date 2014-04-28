//
//  ADVGallery.m
//  
//
//  Created by Valentin Filip on 2/13/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "ADVGalleryBordered.h"
#import "SMPageControl.h"

#import <QuartzCore/QuartzCore.h>

@interface ADVGalleryBordered ()

@property (nonatomic, strong) UIScrollView  *scrollView;

@end




@implementation ADVGalleryBordered

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = CGRectMake(20, 0, self.frame.size.width - 42, self.frame.size.height - self.pageControl.bounds.size.height);
    
    CGFloat offset = imagePadding/2;
    for (NSString *imageName in self.images) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        imageV.contentMode = UIViewContentModeCenter;
        imageV.layer.borderWidth = 5;
        imageV.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor];
        CGRect frameImageV = imageV.frame;
        frameImageV.origin.x = offset;
        frameImageV.size.width += imageV.layer.borderWidth*2;
        frameImageV.size.height += imageV.layer.borderWidth*2;
        frameImageV.origin.y = (self.bounds.size.height - self.pageControl.bounds.size.height - frameImageV.size.height) / 2;
        imageV.frame = frameImageV;
        offset += imagePadding + frameImageV.size.width;
        
        [self.scrollView addSubview:imageV];
    }
    self.scrollView.contentSize = CGSizeMake(offset, self.bounds.size.height - self.pageControl.bounds.size.height);
    [self.scrollView scrollRectToVisible:CGRectMake(ceil(self.images.count/2) * self.scrollView.frame.size.width, 40, 1, 40) animated:NO];
    [self scrollViewDidScroll:self.scrollView];
    
}

@end
