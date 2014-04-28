//
//  SecondViewController.h
//  
//
//  Created by Valentin Filip on 7/9/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSTextField;


@interface ElementsViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet SSTextField *textField;
@property (strong, nonatomic) IBOutlet UISlider *sliderView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UIButton *buttonFirst;
@property (strong, nonatomic) IBOutlet UIButton *buttonSecond;
@property (strong, nonatomic) IBOutlet UIImageView *imgVBkg;
@property (strong, nonatomic) IBOutlet UIImageView *imgVBubble;


- (IBAction)sliderValueChanged:(id)sender;

@end
