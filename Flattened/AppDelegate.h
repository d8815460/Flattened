//
//  AppDelegate.h
//  Flattened
//
//  Created by ALEX on 2014/4/28.
//  Copyright (c) 2014年 miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@class PaperFoldNavigationController;


typedef enum {
    ADVNavigationTypeTab = 0,
    ADVNavigationTypeMenu
} ADVNavigationType;

@interface AppDelegate : UIResponder <UIApplicationDelegate, MenuViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabbarVC;
@property (strong, nonatomic) PaperFoldNavigationController *foldVC;
@property (strong, nonatomic) MenuViewController *menuVC;
@property (strong, nonatomic) UIViewController *mainVC;
@property (assign, nonatomic) ADVNavigationType navigationType;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIBarButtonItem *barButtonFromMaster;
@property (strong, nonatomic) UIBarButtonItem *barButtonForDetail;

+ (AppDelegate *)sharedDelegate;
+ (void)customizeTabsForController:(UITabBarController *)tabVC;
- (void)togglePaperFold:(id)sender;
- (void)resetAfterTypeChange:(BOOL)cancel;
- (void)showMenuiPad:(id)sender;

@end
