//
//  ADVGallery.m
//  
//
//  Created by Valentin Filip on 2/13/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "ADVGalleryShadowed.h"
#import "SMPageControl.h"

#import <QuartzCore/QuartzCore.h>

@interface ADVGalleryShadowed ()

@property (nonatomic, strong) UIScrollView  *scrollView;

@end




@implementation ADVGalleryShadowed

- (void)initialize {
    [super initialize];
    
    imagePadding = 8;
}


#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
        
    self.scrollView.frame = CGRectMake(8, 0, self.frame.size.width - 17, self.frame.size.height - self.pageControl.bounds.size.height);
    
    CGFloat offset = imagePadding/2;
    for (NSString *imageName in self.images) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        imageV.contentMode = UIViewContentModeCenter;
        imageV.layer.cornerRadius = 5;
        imageV.layer.shadowColor = [[UIColor blackColor] CGColor];
        imageV.layer.shadowOffset = CGSizeMake(0, 0);
        imageV.layer.shadowOpacity = 1;
        CGRect frameImageV = imageV.frame;
        frameImageV.origin.x = offset;
        frameImageV.origin.y = self.bounds.size.height - self.pageControl.bounds.size.height - frameImageV.size.height;
        imageV.frame = frameImageV;
        offset += imagePadding + frameImageV.size.width;
        
        [self.scrollView addSubview:imageV];
    }
    self.scrollView.contentSize = CGSizeMake(offset, self.bounds.size.height - self.pageControl.bounds.size.height);
    CGRect pageRect = CGRectMake(ceil(self.images.count/2) * self.scrollView.frame.size.width, 40, 1, 40);
    [self.scrollView scrollRectToVisible:pageRect animated:NO];
    [self scrollViewDidScroll:self.scrollView];
    
}

@end
