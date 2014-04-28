//
//  SetProfileViewController.m
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import "SetProfileViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+ResizeAdditions.h"

#define firstNameTag 100
#define lastNameTag  101

@interface SetProfileViewController ()

@end

@implementation SetProfileViewController
@synthesize userPhotoImageView;
@synthesize nextBtn, firstNameTextField, lastNameTextField;
@synthesize uploadNewPhotoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nextBtn.title = @"";
    [self.nextBtn setEnabled:NO];
    self.firstNameTextField.delegate = self;
    self.firstNameTextField.tag = firstNameTag;
    self.lastNameTextField.delegate = self;
    self.lastNameTextField.tag = lastNameTag;
    
    // 選擇相簿或照相
    [self.uploadNewPhotoButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated{
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        self.userPhotoImageView.image = [UIImage imageWithData:oldProfilePictureData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:140 interpolationQuality:kCGInterpolationHigh];
    self.userPhotoImageView.image = mediumImage;
    
    NSData *myPicData = UIImagePNGRepresentation(self.userPhotoImageView.image);
    [CMUtility processFacebookProfilePictureData:myPicData];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //因為使用者所在位置會一直被用到，所以在這裡就不做release的動作了。否則會永遠沒辦法找到使用者。
    
    
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1){
        [self shouldStartPhotoLibraryPickerController];
    } else {
        
    }
}

#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - 照片資料Delegate
#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍張照片", @"從相簿選擇",nil];
        [actionSheet showInView:self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}
- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)nextBtnPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:self.firstNameTextField.text forKey:kPAPUserFacebookFirstNameKey];
    [currentUser setObject:self.lastNameTextField.text forKey:kPAPUserFacebookLastNameKey];
//    [currentUser setObject:currentUser.username forKey:kPAPUserDisplayNameKey];
    
    [currentUser saveEventually];
    
    [self performSegueWithIdentifier:@"connectCreditCard" sender:sender];
}

- (IBAction)upLoadNewPhotoBtnPressed:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"connectCreditCard"]) {
        
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == firstNameTag) {
        if (range.length == 0) {
            if (self.firstNameTextField.text.length + 1 > 0 && self.lastNameTextField.text.length > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }else{
            if (self.firstNameTextField.text.length - 1 > 0 && self.lastNameTextField.text.length > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }
    }else if (textField.tag == lastNameTag){
        if (range.length == 0) {
            if (self.firstNameTextField.text.length  > 0 && self.lastNameTextField.text.length + 1 > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }else{
            if (self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length - 1 > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }
    }
    return YES;
}
@end
