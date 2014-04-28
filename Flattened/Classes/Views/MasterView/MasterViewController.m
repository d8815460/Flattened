//
//  MasterViewController.m
//  
//
//  Created by Valentin Filip on 6/1/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void) awakeFromNib{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([AppDelegate sharedDelegate].barButtonForDetail != nil) {
            self.navigationItem.leftBarButtonItem = [AppDelegate sharedDelegate].barButtonForDetail;
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 40, 30);
    [menuButton setImage:[UIImage imageNamed:@"navigation-btn-menu"] forState:UIControlStateNormal];
    [menuButton addTarget:appDelegate action:@selector(showMenuiPad:) forControlEvents:UIControlEventTouchUpInside];
    appDelegate.barButtonFromMaster = barButtonItem;
    appDelegate.barButtonForDetail = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    [self.navigationItem setLeftBarButtonItem:[AppDelegate sharedDelegate].barButtonForDetail animated:YES];
    appDelegate.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    
    [AppDelegate sharedDelegate].barButtonForDetail = nil;
    [AppDelegate sharedDelegate].masterPopoverController = nil;
}


@end
