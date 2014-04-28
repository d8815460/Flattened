//
//  CustomTabBarViewController.m
//
//  Created by Valentin Filip on 10/24/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "AppDelegate.h"

@interface CustomTabBarViewController ()

@end

@implementation CustomTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate customizeTabsForController:self];
}

@end
