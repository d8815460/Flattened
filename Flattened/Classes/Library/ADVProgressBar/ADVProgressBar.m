//
//  ADVProgressBar.m
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

#define MIN_WIDTH 10.0f

#import "ADVProgressBar.h"
#import "AppDelegate.h"
#import "ADVTheme.h"

@implementation ADVProgressBar

@synthesize progress;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {    
    if (self = [super initWithFrame:frame]) {    
        [self initialize];
    }
    
    return self;
}


- (void)initialize {
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    self.backgroundColor = [UIColor clearColor];
    bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    
    self.maxBackgroundImage = [theme progressPercentTrackImage];
    [self addSubview:bgImageView];
    
    self.minBackgroundImage = [[theme progressPercentProgressImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    progressImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    progressImageView.image = self.minBackgroundImage;
    [self addSubview:progressImageView];
}

#pragma mark - Accessors

- (void)setMinBackgroundImage:(UIImage *)minBackgroundImage {
    _minBackgroundImage = minBackgroundImage;
    progressImageView.image = minBackgroundImage;
}

- (void)setMaxBackgroundImage:(UIImage *)maxBackgroundImage {
    _maxBackgroundImage = maxBackgroundImage;
    bgImageView.image = maxBackgroundImage;
}

- (void)setProgress:(CGFloat)theProgress {
    
    if (self.progress != theProgress) {        
        if (theProgress >= 0 && theProgress <= 1) {            
            progress = theProgress;
                        
            CGRect frame = progressImageView.frame;
            
            frame.origin.x = 0;
            frame.origin.y = 0;
            CGFloat width = (bgImageView.frame.size.width - 2*frame.origin.x - MIN_WIDTH) * progress;
            width += MIN_WIDTH;
            
            float percentage = progress*100;
            BOOL display = percentage == 0;
            
            frame.size.width = width;
            
            progressImageView.frame = CGRectIntegral(frame);
            progressImageView.hidden = display;
        }
    }
}


@end
