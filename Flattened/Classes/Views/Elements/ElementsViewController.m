//
//  SecondViewController.m
//  
//
//  Created by Valentin Filip on 7/9/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "ElementsViewController.h"
#import "ADVTheme.h"
#import "RCSwitchOnOff.h"
#import "ADVPercentProgressBar.h"
#import "SSTextField.h"
#import "AppDelegate.h"

#import "EmailCell.h"
#import "DataSource.h"
#import "UISearchBar+TextColor.h"
#import "Utils.h"


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.1;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.9;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

CGFloat animatedDistance;

@interface ElementsViewController ()

@property (nonatomic, strong) ADVPercentProgressBar        *progressBar;

@end



@implementation ElementsViewController

@synthesize scrollView;
@synthesize textField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(![Utils isVersion6AndBelow])
        self.navigationController.navigationBar.translucent = NO;
    
    [ADVThemeManager customizeView:self.view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"UI ELEMENTS";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:17];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"NavigationType"] == ADVNavigationTypeMenu) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(0, 0, 40, 30);
        [menuButton setImage:[UIImage imageNamed:@"navigation-btn-menu"] forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    }
    
    _searchBar.field.leftViewMode = UITextFieldViewModeNever;
    _searchBar.field.placeholder = @"Search";
    _searchBar.field.textColor = [UIColor colorWithRed:0.68f green:0.68f blue:0.68f alpha:1.00f];
    
    UIView *rightIconSearch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 38)];
    rightIconSearch.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.00f];
    UIImageView *rightIconSearchImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIconSearch"]];
    rightIconSearchImg.center = rightIconSearch.center;
    [rightIconSearch addSubview:rightIconSearchImg];
    _searchBar.field.rightView = rightIconSearch;
    _searchBar.field.rightViewMode = UITextFieldViewModeAlways;
    
    self.progressBar = [[ADVPercentProgressBar alloc] initWithFrame:CGRectMake(33, 90, 255, 9)];
    self.progressBar.progress = 0.72;
    [self.scrollView addSubview:self.progressBar];
    
    RCSwitchOnOff* onSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(80, 135, 65, 23)];
    [onSwitch setOn:YES];    
    [self.scrollView addSubview:onSwitch];
    
    RCSwitchOnOff* offSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(175, 135, 65, 23)];
    [offSwitch setOn:NO];    
    [self.scrollView addSubview:offSwitch];
    
    self.buttonFirst.titleLabel.font =  [UIFont fontWithName:@"ProximaNova-Bold" size:12];
    self.buttonSecond.titleLabel.font =  [UIFont fontWithName:@"ProximaNova-Bold" size:12];
    
    CGRect frameSegm = self.segment.frame;
    frameSegm.size.height = 32;
    self.segment.frame = frameSegm;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (void)showMenu:(id)sender {
    [[AppDelegate sharedDelegate] togglePaperFold:sender];
}

- (IBAction)sliderValueChanged:(id)sender {    
    if([sender isKindOfClass:[UISlider class]]) {
        UISlider *s = (UISlider*)sender;
        
        if(s.value >= 0.0 && s.value <= 1.0) {
            if (self.progressBar) {
                self.progressBar.progress = s.value;
            }
        }
    }
}

- (void)viewFinishedLayout:(id)sender {
    
}

- (void)clearTextField:(id)sender {
    self.textField.text = @"";
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
    CGRect textFieldRect = [self.scrollView.window convertRect:aTextField.bounds fromView:textField];
    CGRect viewRect = [self.scrollView.window convertRect:self.scrollView.bounds fromView:self.scrollView];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = 
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.scrollView setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.scrollView setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [aTextField resignFirstResponder];
    return YES;
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setSearchBar:nil];
    [self setButtonFirst:nil];
    [self setButtonSecond:nil];
    [self setImgVBkg:nil];
    [self setImgVBubble:nil];
    [super viewDidUnload];
}

#pragma mark - Utils

- (BOOL)isTall {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
        && [UIScreen mainScreen].bounds.size.height == 568)
    {
        return YES;
    }
    return NO;
}


@end
