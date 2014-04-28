//
//  AppDelegate.m
//  Flattened
//
//  Created by ALEX on 2014/4/28.
//  Copyright (c) 2014年 miiitech. All rights reserved.
//

#import "AppDelegate.h"

#import "ADVTheme.h"

#import "MailViewController.h"
#import "PaperFoldNavigationController.h"

static AppDelegate *sharedDelegate;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ADVThemeManager customizeAppAppearance];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.mainVC = (((UINavigationController *)self.window.rootViewController).viewControllers)[0];
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        splitViewController.presentsWithGesture = NO;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        MenuViewController *menuVC = splitViewController.viewControllers[0];
        menuVC.delegate = self;
    } else {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        if (![[NSUserDefaults standardUserDefaults] valueForKey:@"NavigationType"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:ADVNavigationTypeMenu forKey:@"NavigationType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        self.navigationType = [[NSUserDefaults standardUserDefaults] integerForKey:@"NavigationType"];
        if (_navigationType == ADVNavigationTypeTab) {
            [self setupTabbar];
        } else {
            [self setupMenu];
        }
        
        self.window.rootViewController = self.mainVC;
        self.window.backgroundColor = [UIColor blackColor];
        [self.window makeKeyAndVisible];
    }
    return YES;
}

- (void)setupTabbar {
    if (!self.tabbarVC) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];
        
        
        self.tabbarVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TabbarController"];
    }
    
    self.mainVC = _tabbarVC;
}

- (void)setupMenu {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    if (!self.foldVC) {
        self.foldVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"PaperFoldController"];
    }
    
    UINavigationController *navMag1 = [mainStoryboard instantiateViewControllerWithIdentifier:@"PropertiesNav"];
    if (!_menuVC) {
        _menuVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SideViewController"];
        _menuVC.delegate = self;
    }
    [_foldVC setRootViewController:navMag1];
    [_foldVC setLeftViewController:_menuVC width:275];
    
    self.mainVC = _foldVC;
}


#pragma mark - Actions

- (void)showMenuiPad:(id)sender {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_barButtonFromMaster.target performSelector:_barButtonFromMaster.action withObject:_barButtonFromMaster];
#pragma clang diagnostic pop
}


- (void)togglePaperFold:(id)sender {
    if (_foldVC.paperFoldView.state == PaperFoldStateLeftUnfolded) {
        [_foldVC.paperFoldView setPaperFoldState:PaperFoldStateDefault animated:YES];
    } else {
        [_foldVC.paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded animated:YES];
    }
}


-(void)userDidSwitchToControllerAtIndexPath:(NSIndexPath*)indexPath{
    NSString *controllerIdentifier;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.mainVC = (((UINavigationController *)self.window.rootViewController).viewControllers)[0];
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        NSString *title;
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        controllerIdentifier = @"PropertiesNav";
                        break;
                    case 1:
                        title = @"SENT EMAILS";
                        break;
                    case 2:
                        title = @"DRAFTS";
                        break;
                    case 3:
                        title = @"TRASH";
                        break;
                    case 4:
                        title = @"SETTINGS";
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
        controllerIdentifier = controllerIdentifier ? : @"OtherNav";
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                                                 bundle: nil];
        UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:controllerIdentifier];
        
        splitViewController.delegate = (id)nav.topViewController;
        splitViewController.viewControllers = @[splitViewController.viewControllers[0], nav];
        nav.topViewController.title = title;
    } else {
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        controllerIdentifier = @"PropertiesNav";
                        break;
                    case 1:
                        controllerIdentifier = @"MapNav";
                        break;
                    case 2:
                        controllerIdentifier = @"ElementsNav";
                        break;
                    case 3:
                        controllerIdentifier = @"AccountNav";
                        break;
                    case 4:
                        controllerIdentifier = @"SettingsNav";
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];
        UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:controllerIdentifier];
        
        [_foldVC setRootViewController:nav];
        [_foldVC.paperFoldView setPaperFoldState:PaperFoldStateDefault animated:YES];
    }
}

- (void)resetAfterTypeChange:(BOOL)cancel {
    UINavigationController *settingsNav;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"NavigationType"] == ADVNavigationTypeTab) {
        [self setupTabbar];
        _tabbarVC.selectedIndex = 4;
        settingsNav = [_tabbarVC.viewControllers lastObject];
        [settingsNav popToRootViewControllerAnimated:NO];
    } else {
        [self setupMenu];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];
        settingsNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsNav"];
        [_foldVC setRootViewController:settingsNav];
        [_foldVC setLeftViewController:_menuVC width:275];
    }
    
    self.window.rootViewController = self.mainVC;
    
    if (!cancel) {
        UIViewController *settingsVC = settingsNav.viewControllers[0];
        [settingsVC performSegueWithIdentifier:@"selectNavigationTypeNoAnim" sender:settingsVC];
    }
}

+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+ (AppDelegate *)sharedDelegate {
    if (!sharedDelegate) {
        sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return sharedDelegate;
}


+ (void)customizeTabsForController:(UITabBarController *)tabVC {
    NSArray *items = tabVC.tabBar.items;
    for (int idx = 0; idx < items.count; idx++) {
        UITabBarItem *item = items[idx];
        [ADVThemeManager customizeTabBarItem:item forTab:((SSThemeTab)idx)];
    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0.55f green:0.56f blue:0.58f alpha:1.00f], UITextAttributeTextColor,
      [UIFont fontWithName:@"OpenSans-Semibold" size:9], UITextAttributeFont,
      nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:@"OpenSans-Semibold" size:9], UITextAttributeFont,
      nil]
                                             forState:UIControlStateSelected];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
