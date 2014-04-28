//
//  SettingsViewController.m
//  
//
//  Created by Valentin Filip on 4/19/13.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ADVTheme.h"
#import "NavigationSelectViewController.h"
#import "Utils.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(![Utils isVersion6AndBelow])
        self.navigationController.navigationBar.translucent = NO;
    
    [ADVThemeManager customizeTableView:self.tableView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"SETTINGS";
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
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    
//    UIBarButtonItem* reloadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation-btn-menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
//    
//    self.navigationItem.leftBarButtonItem = reloadButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [self.tableView reloadData];
}


- (void)showMenu:(id)sender {
    [[AppDelegate sharedDelegate] togglePaperFold:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"Navigation Type";
    NSString *themeName;
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"NavigationType"]) {
        case ADVNavigationTypeMenu:
            themeName = @"Hidden Menu";
            break;
        case ADVNavigationTypeTab:
            themeName = @"Tabbar";
            break;
        default:
            break;
    }
    cell.detailTextLabel.text = themeName;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"selectNavigationType" sender:self];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectNavigationType"] || [segue.identifier isEqualToString:@"selectNavigationTypeNoAnim"]) {
        
    }
}
@end
