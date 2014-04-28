//
//  MasterViewController.h
//  
//
//  Created by Valentin Filip on 10/23/12.
//  Copyright (c) 2012 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailCell.h"
#import "MasterViewController.h"

@interface MailViewController : MasterViewController <UITableViewDataSource, UITableViewDelegate, ZKRevealingTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
