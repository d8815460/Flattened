//
//  ADVGallery.h
//  
//
//  Created by Valentin Filip on 2/13/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMPageControl;

@interface ADVGallery : UIView <UIScrollViewDelegate> {
    CGFloat imagePadding;
}

@property (nonatomic, strong) NSArray *images;

@property (strong, nonatomic) IBOutlet SMPageControl *pageControl;

- (void)initialize;

@end
