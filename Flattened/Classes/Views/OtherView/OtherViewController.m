//
//  OtherViewController.m
//  
//
//  Created by Valentin Filip on 5/27/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "OtherViewController.h"

#import "ADVTheme.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface OtherViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIBarButtonItem *barButtonFromMaster;

@end

@implementation OtherViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(![Utils isVersion6AndBelow])
        self.navigationController.navigationBar.translucent = NO;
    
    [ADVThemeManager customizeView:self.view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = [self.navigationItem.title uppercaseString];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:17];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
        && [[NSUserDefaults standardUserDefaults] integerForKey:@"NavigationType"] == ADVNavigationTypeMenu) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(0, 0, 40, 30);
        [menuButton setImage:[UIImage imageNamed:@"navigation-btn-menu"] forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    }
}


- (void)showMenu:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[AppDelegate sharedDelegate] togglePaperFold:sender];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_barButtonFromMaster.target performSelector:_barButtonFromMaster.action withObject:_barButtonFromMaster];
#pragma clang diagnostic pop
    }
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 40, 30);
    [menuButton setImage:[UIImage imageNamed:@"navigation-btn-menu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.barButtonFromMaster = barButtonItem;
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:menuButton] animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


@end
