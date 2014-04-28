//
//  ADVGallery.m
//  
//
//  Created by Valentin Filip on 2/13/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "ADVGalleryPlain.h"
#import "SMPageControl.h"

#import <QuartzCore/QuartzCore.h>

@interface ADVGalleryPlain ()

@property (nonatomic, strong) UIScrollView  *scrollView;

@end




@implementation ADVGalleryPlain

- (void)initialize {
    [super initialize];
    
    imagePadding = 0;
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.pageControl.bounds.size.height);
    
    CGFloat offset = 0;
    for (NSString *imageName in self.images) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        imageV.image = image;
        imageV.contentMode = UIViewContentModeScaleAspectFill;
        imageV.clipsToBounds = YES;
        CGRect frameImageV = imageV.frame;
        frameImageV.origin.x = offset;
        frameImageV.size.height = self.bounds.size.height - self.pageControl.bounds.size.height;
        imageV.frame = frameImageV;
        offset += frameImageV.size.width;
        
        [self.scrollView addSubview:imageV];
    }
    
    self.scrollView.contentSize = CGSizeMake(offset, self.bounds.size.height - self.pageControl.bounds.size.height);
}

@end
