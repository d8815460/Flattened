//
//  ADVPopoverProgressBar.m
//  ADVPopoverProgressBar
//
//
/*
 The MIT License
 
 Copyright (c) 2011 Tope Abayomi
 http://www.appdesignvault.com/
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#define LEFT_PADDING 5.0f
#define RIGHT_PADDING 3.0f
#define PERCENT_VIEW_WIDTH 25.0f
#define MIN_WIDTH 10.0f

#import "ADVPercentProgressBar.h"


@implementation ADVPercentProgressBar

@synthesize progress;


- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        [bgImageView setImage:[UIImage imageNamed:@"progressTrack.png"]];
        [self addSubview:bgImageView];
        
        progressFillImage = [[UIImage imageNamed:@"progressProgress.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
        [self addSubview:progressImageView];
        
        percentView = [[UIView alloc] initWithFrame:CGRectMake(0, -17, PERCENT_VIEW_WIDTH, 12)];
        
        UIImageView* percentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PERCENT_VIEW_WIDTH, 12)];
        [percentImageView setImage:[UIImage imageNamed:@"progressValue.png"]];
        [percentView addSubview:percentImageView];
        
        UILabel* percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PERCENT_VIEW_WIDTH, 12)];
        [percentLabel setTag:1];
        [percentLabel setText:@"0%"];
        [percentLabel setBackgroundColor:[UIColor clearColor]];
        [percentLabel setTextColor:[UIColor whiteColor]];
        [percentLabel setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:9]];
        [percentLabel setTextAlignment:NSTextAlignmentCenter];
        [percentLabel setAdjustsFontSizeToFitWidth:YES];        
        [percentView addSubview:percentLabel];
        
        [self addSubview:percentView];
        
        self.progress = 0.0f;
    }
    
    return self;
}


- (void)setProgress:(CGFloat)theProgress {
    
    if (self.progress != theProgress) {
        
        if (theProgress >= 0 && theProgress <= 1) {
            
            progress = theProgress;
            
            progressImageView.image = progressFillImage;
            
            CGRect frame = progressImageView.frame;
            
            frame.size.height = bgImageView.frame.size.height;
            CGFloat width = (bgImageView.frame.size.width - MIN_WIDTH) * progress;
            width += MIN_WIDTH;
            
            float percentage = progress*100;
            BOOL display = percentage == 0;
            
            frame.size.width = width;
            
            progressImageView.frame = CGRectIntegral(frame);
            progressImageView.hidden = display;
            
            float leftEdge = width - (PERCENT_VIEW_WIDTH / 2);
            percentView.frame = CGRectIntegral(CGRectMake(leftEdge, percentView.frame.origin.y, PERCENT_VIEW_WIDTH, percentView.frame.size.height));
            
            UILabel* percentLabel = (UILabel*)[percentView viewWithTag:1];
            [percentLabel setText:[NSString  stringWithFormat:@"%d%%", (int)percentage]];
            percentView.hidden = display;
        }
    }
}

@end
