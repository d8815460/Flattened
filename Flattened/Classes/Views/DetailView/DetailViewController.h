//
//  MapViewController.h
//  
//
//  Created by Valentin Filip on 2/16/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *item;

@property (assign, nonatomic) BOOL editable;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *bkgView;
@property (strong, nonatomic) IBOutlet UITextView *textBody;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollRecipients;

@end
