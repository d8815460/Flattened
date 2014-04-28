//
//  MenuViewController.m
//  
//
//  Created by Valentin Filip on 09.04.2012.
//  Copyright (c) 2012 App Design Vault. All rights reserved.
//

#import "MenuViewController.h"
#import "DataSource.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface MenuViewController ()

@property (nonatomic, strong) NSArray       *menu;
@property (nonatomic, strong) NSIndexPath   *currentSelection;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(![Utils isVersion6AndBelow]){
        self.profileView.frame = CGRectMake(0, 15, 275, 80);
        CGRect tableRect = self.tableView.frame;
        tableRect.origin.y += 15;
        tableRect.size.height -= 15;
        self.tableView.frame = tableRect;
    }
    
    self.menu = [DataSource menu];
    [self.tableView reloadData];
    
    UIImage *imgBkg = [[UIImage imageNamed:@"menu-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(100, 0, 150, 0)];
    UIImageView *imgVBkg = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgVBkg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imgVBkg.image = imgBkg;
    [self.view insertSubview:imgVBkg atIndex:0];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.profileView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu-profile-background.png"]];
    
    
    NSDictionary *account = [DataSource userAccount];
    UIImageView *profileImageView = (UIImageView *)[_profileView viewWithTag:1];
    profileImageView.image = [UIImage imageNamed:account[@"avatar"]];
    
    UILabel *nameLabel = (UILabel *)[_profileView viewWithTag:2];
    nameLabel.text = account[@"name"];
    nameLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:19];
    nameLabel.textColor = [UIColor whiteColor];
    
    UILabel *emailLabel = (UILabel *)[_profileView viewWithTag:3];
    emailLabel.text = account[@"email"];
    emailLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
    emailLabel.textColor = [UIColor colorWithRed:0.56f green:0.59f blue:0.64f alpha:1.00f];
    
    UIButton *btnSettings = (UIButton *)[_profileView viewWithTag:4];
    [btnSettings setImage:[UIImage imageNamed:@"menu-profile-settings"] forState:UIControlStateNormal];
    btnSettings.backgroundColor = [UIColor clearColor];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menu count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *cellIdentifier = @"MenuCell";
    NSInteger index = indexPath.row;
    
    if (indexPath.row == [aTableView numberOfRowsInSection:0] - 2) {
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.row > [aTableView numberOfRowsInSection:0] - 2) {
        index--;
        cellIdentifier = @"MenuCellReverted";
    }
    
    cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.backgroundView = nil;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    aTableView.backgroundColor = [UIColor clearColor];
    NSDictionary *item = self.menu[index];
    
    UIImageView *imgRow = (UIImageView *)[cell viewWithTag:1];
    UIImage *imgRowImage = nil;
    if (item[@"image"]) {
        imgRowImage = [UIImage imageNamed:item[@"image"]];
    }
    imgRow.image = imgRowImage;
    UILabel *lblText = (UILabel *)[cell viewWithTag:2];
    lblText.text = item[@"title"];
    lblText.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:16];
    
    UIView *countView = nil;
    if ([item[@"count"] intValue] > 0) {
        UIFont *countFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:13];
        
        NSString *countString = [NSString stringWithFormat:@"%@", item[@"count"]];
        CGSize sizeCount = [countString sizeWithFont:countFont];
        
        CGFloat padding = 2;
        CGFloat viewWidth = sizeCount.width + padding*2;
        viewWidth = viewWidth > 20 ? : 20;
        
        UIImage *bkgImg = [UIImage imageNamed:@"menu-count.png"];
        countView = [[UIImageView alloc] initWithImage:[bkgImg stretchableImageWithLeftCapWidth:12 topCapHeight:0]];
        countView.frame = CGRectIntegral(CGRectMake(0, 0, viewWidth, bkgImg.size.height));
        
        int labelX = (viewWidth - sizeCount.width)/2;
        UILabel *lblCount = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelX, (bkgImg.size.height-sizeCount.height)/2+1, sizeCount.width, sizeCount.height))];
        lblCount.text = countString;
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.textColor = [UIColor colorWithRed:0.43f green:0.43f blue:0.45f alpha:1.00f];
        lblCount.textAlignment = NSTextAlignmentCenter;
        lblCount.font = countFont;
        lblCount.shadowColor = [UIColor clearColor];
        lblCount.shadowOffset = CGSizeMake(0, 1);
        [countView addSubview:lblCount];
    }
    cell.accessoryView = countView;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 44;
    if (indexPath.row == _menu.count - 1) {
        return aTableView.frame.size.height - _menu.count*rowHeight;
    }
    
    return rowHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:YES animated:YES];
        [[AppDelegate sharedDelegate].masterPopoverController dismissPopoverAnimated:YES];
    }
    
    if (indexPath.row == [aTableView numberOfRowsInSection:0] - 2) {
        return;
    } else if (indexPath.row > [aTableView numberOfRowsInSection:0] - 2) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    }
    [self.delegate userDidSwitchToControllerAtIndexPath:indexPath];
}

- (void)viewDidUnload {
    [self setProfileView:nil];
    [super viewDidUnload];
}
@end
