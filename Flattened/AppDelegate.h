//
//  AppDelegate.h
//  Flattened
//
//  Created by ALEX on 2014/4/28.
//  Copyright (c) 2014年 miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import <Reachability.h>
#import "GoogleMapViewController.h"

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

@property (strong, nonatomic) GoogleMapViewController *mainMap;
@property (nonatomic, strong) Reachability *hostReach;                                  //判斷網路是否可用
@property (nonatomic, strong) Reachability *internetReach;                              //判斷網路是否可用
@property (nonatomic, strong) Reachability *wifiReach;                                  //判斷wifi網路是否可用
@property (nonatomic, readonly) int networkStatus;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (NSInteger)OSVersion;
+ (AppDelegate *)sharedDelegate;

+ (void)customizeTabsForController:(UITabBarController *)tabVC;
- (void)togglePaperFold:(id)sender;
- (void)resetAfterTypeChange:(BOOL)cancel;
- (void)showMenuiPad:(id)sender;

- (BOOL)isParseReachable;
- (void)presentWelcomeViewController;
- (void)presentWelcomeViewControllerAnimated:(BOOL)animated;
- (void)presentFirstSignInViewController;
- (void)presentGoogleMapController;
- (void)logOut;

- (BOOL)handleActionURL:(NSURL *)url;                                                   //偵測動作URL_照相機跟相簿偵測

@end
