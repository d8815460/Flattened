//
//  MapViewController.m
//  
//
//  Created by Valentin Filip on 2/16/13.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import "DetailViewController.h"

#import "ADVTheme.h"
#import "DataSource.h"
#import "ADVGalleryPlain.h"

#import "UIColor+Alpha.h"
#import "Utils.h"

#import <QuartzCore/QuartzCore.h>

@interface DetailViewController () {
    CGSize kbSize;
}

@property (nonatomic, strong) NSMutableArray *tagViews;
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, assign) BOOL fullScreen;


@end




@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(![Utils isVersion6AndBelow])
        self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Detail";
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:17];
    
    if (_editable) {
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(0, 0, 40, 30);
        [btnCancel setImage:[UIImage imageNamed:@"navigation-btn-cancel"] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
        
        UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSend.frame = CGRectMake(0, 0, 40, 30);
        [btnSend setImage:[UIImage imageNamed:@"navigation-btn-send"] forState:UIControlStateNormal];
        [btnSend addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSend];
        
        titleLabel.text = @"COMPOSE";        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:self.view.window];
        
        self.toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, TOOLBAR_HEIGHT)];
        self.toolbarView.backgroundColor = [UIColor whiteColor];
        
        
        UIButton *btnHideKeys = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHideKeys.frame = CGRectMake(self.view.frame.size.width - 36, 9, 26, 26);
        [btnHideKeys setImage:[UIImage imageNamed:@"list-item-detail-hide-keyboard"] forState:UIControlStateNormal];
        [btnHideKeys addTarget:self action:@selector(actionHideKeys:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView addSubview:btnHideKeys];
        
        UIButton *btnToggle = [UIButton buttonWithType:UIButtonTypeCustom];
        btnToggle.frame = CGRectMake(self.view.frame.size.width - 64, 10, 18, 18);
        [btnToggle setImage:[UIImage imageNamed:@"list-item-detail-max"] forState:UIControlStateNormal];
        [btnToggle addTarget:self action:@selector(actionToggleFullScreen:) forControlEvents:UIControlEventTouchUpInside];
        btnToggle.tag = 123;
        [_toolbarView addSubview:btnToggle];
    } else {
        UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBack.frame = CGRectMake(0, 0, 30, 30);
        [btnBack setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
        
        _textBody.editable = NO;
        
        titleLabel.text = @"1 of 1";
    }
    
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    [self configureView];
    
    [_textBody becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
        && ![self isTall] && _editable)
    {
        [self performSelector:@selector(actionToggleFullScreen:) withObject:[_toolbarView viewWithTag:123] afterDelay:0.3];
    }
}

- (BOOL)isTall {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
        && [UIScreen mainScreen].bounds.size.height == 568)
    {
        return YES;
    }
    return NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Actions

- (void)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)actionSend:(id)sender {
    [self actionCancel:sender];
}

- (void)actionToggleFullScreen:(id)sender {    
    [UIView animateWithDuration:0.20f animations:^{
        if (!_fullScreen) {
            _fullScreen = YES;            
            [sender setImage:[UIImage imageNamed:@"list-item-detail-min"] forState:UIControlStateNormal];
            
            CGRect frameHeader = _headerView.frame;
            frameHeader.origin.y = -frameHeader.size.height;
            _headerView.frame = frameHeader;
            
            CGRect frameBody = _textBody.frame;
            frameBody.origin.y = 5;
            frameBody.size.height = frameBody.size.height + frameBody.size.height + self.navigationController.navigationBar.bounds.size.height;
            _textBody.frame = frameBody;
            
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            
            
            CGRect frameRect = self.view.frame;
            frameRect.size.height -= kbSize.height;
            self.toolbarView.frame = CGRectMake(0.0, frameRect.size.height - TOOLBAR_HEIGHT, 320.0, TOOLBAR_HEIGHT);
        } else {
            _fullScreen = NO;
            [sender setImage:[UIImage imageNamed:@"list-item-detail-max"] forState:UIControlStateNormal];
            
            CGRect frameHeader = _headerView.frame;
            frameHeader.origin.y = 0;
            _headerView.frame = frameHeader;
            
            CGRect frameBody = _textBody.frame;
            frameBody.origin.y = frameHeader.size.height + 5;
            frameBody.size.height = frameBody.size.height - frameHeader.size.height;
            _textBody.frame = frameBody;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            
            CGRect frameRect = self.view.frame;
            frameRect.size.height -= kbSize.height;
            self.toolbarView.frame = CGRectMake(0.0, frameRect.size.height - TOOLBAR_HEIGHT, 320.0, TOOLBAR_HEIGHT);
        }
    }];
}

- (void)actionHideKeys:(id)sender {
    [_textBody resignFirstResponder];
    if (_fullScreen) {
        _fullScreen = NO;
        [((UIButton *)[_toolbarView viewWithTag:123]) setImage:[UIImage imageNamed:@"list-item-detail-max"] forState:UIControlStateNormal];
        
        CGRect frameHeader = _headerView.frame;
        frameHeader.origin.y = 0;
        _headerView.frame = frameHeader;
        
        CGRect frameBody = _textBody.frame;
        frameBody.origin.y = frameHeader.size.height + 5;
        frameBody.size.height = frameBody.size.height - frameHeader.size.height;
        _textBody.frame = frameBody;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}


#pragma mark - View config

- (void)configureView {
    if (!self.item) {
        self.item = [DataSource timeline][0];
    }
    
    UIImageView *imgVBkg = (UIImageView *)[_headerView viewWithTag:1];
    imgVBkg.image = [[UIImage imageNamed:@"list-item-detail-header-bkg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 150, 0, 10)];
    
    UILabel *lblToTitle = (UILabel *)[_headerView viewWithTag:2];
    lblToTitle.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:13];
    lblToTitle.textColor = [UIColor colorWithRed:0.47f green:0.47f blue:0.47f alpha:1.00f];
    
    UIView *viewToCount = [_headerView viewWithTag:3];
    viewToCount.backgroundColor = [UIColor colorWithRed:0.91f green:0.38f blue:0.39f alpha:1.00f];
    viewToCount.layer.cornerRadius = 2;
    
    UILabel *lblToCount = (UILabel *)[viewToCount viewWithTag:1];
    lblToCount.font = [UIFont fontWithName:@"ProximaNova-Bold" size:13];
    lblToCount.textColor = [UIColor whiteColor];
    lblToCount.text = [NSString stringWithFormat:@"%d", [_item[@"recipients"] count]];
    
    UILabel *lblSubjectTitle = (UILabel *)[_headerView viewWithTag:5];
    lblSubjectTitle.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:13];
    lblSubjectTitle.textColor = [UIColor colorWithRed:0.47f green:0.47f blue:0.47f alpha:1.00f];
    
    UILabel *lblSubject = (UILabel *)[_headerView viewWithTag:6];
    lblSubject.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14];
    lblSubject.textColor = [UIColor colorWithRed:0.16f green:0.17f blue:0.18f alpha:1.00f];
    lblSubject.text = _item[@"subject"];
    
    _textBody.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
    _textBody.textColor = [UIColor colorWithRed:0.47f green:0.47f blue:0.47f alpha:1.00f];
    _textBody.text = _item[@"body"];
    
    for (UIView *recipient in _scrollRecipients.subviews) {
        [recipient removeFromSuperview];
    }
    
    CGFloat padding = 10;
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:13];
    for (NSString *name in _item[@"recipients"]) {
        CGFloat nameWidth = [name sizeWithFont:font].width;
        
        UIView *recipient = [[UIView alloc] initWithFrame:CGRectMake(padding, 10, nameWidth + 10, 24)];
        recipient.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
        recipient.layer.cornerRadius = 3;
        UILabel *labelRecipient = [[UILabel alloc] initWithFrame:recipient.bounds];
        labelRecipient.backgroundColor = [UIColor clearColor];
        labelRecipient.text = name;
        labelRecipient.textAlignment = NSTextAlignmentCenter;
        labelRecipient.textColor = [UIColor colorWithRed:0.56f green:0.56f blue:0.56f alpha:1.00f];
        labelRecipient.font = font;
        [recipient addSubview:labelRecipient];
        padding += nameWidth + 20;
        
        [_scrollRecipients addSubview:recipient];
    }
    _scrollRecipients.contentSize = CGSizeMake(padding, _scrollRecipients.bounds.size.height);
}


#pragma mark - Keyboard delegate
const int TOOLBAR_HEIGHT = 44;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
CGRect keyboardBounds;

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //call the method to make the toolbar appear.
    [self loadToolbar];
}

- (void)loadToolbar {
    [self.view addSubview:self.toolbarView];
    //setting the position of the toolbar.
    CGRect frameRect = self.view.frame;
    frameRect.size.height -= kbSize.height;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.toolbarView.frame = CGRectMake(0.0, frameRect.size.height - TOOLBAR_HEIGHT, 320.0, TOOLBAR_HEIGHT);
    }];
}


- (void)keyboardDidShow:(NSNotification*)notification {
    CGRect tableFrame = self.textBody.frame;
    tableFrame.size.height = self.view.frame.size.height - tableFrame.origin.y - PORTRAIT_KEYBOARD_HEIGHT - TOOLBAR_HEIGHT - 10;
    self.textBody.frame = tableFrame;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    //self.txtMessage.text = nil;
    [UIView animateWithDuration:0.25f animations:^{
        self.toolbarView.frame = CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.toolbarView.frame.size.width, TOOLBAR_HEIGHT);
    }];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    [self.toolbarView removeFromSuperview];
    self.textBody.frame = CGRectMake(0, self.textBody.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.textBody.frame.origin.y - TOOLBAR_HEIGHT - 5);
}

@end
