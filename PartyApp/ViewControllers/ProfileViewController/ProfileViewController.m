//
//  ProfileViewController.m
//  PartyApp
//
//  Created by Varun on 18/06/2014.
//  Copyright (c) 2014 WebFactory. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "LogNightViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
@interface ProfileViewController () <QBActionStatusDelegate>

@end

@implementation ProfileViewController

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
    [self.navigationController setNavigationBarHidden:FALSE animated:true];
    [self setTitle:@"Party Friends"];
    // Do any additional setup after loading the view from its nib.
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:_pudLoggedIn]) {
        [self showLoginView];
    }
    
    imageViewProfile.layer.borderColor= [UIColor blueColor].CGColor;
    imageViewProfile.layer.borderWidth=1.5;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults]objectForKey:_pUserInfoDic])
    {
    NSDictionary *userInfo=[[NSUserDefaults standardUserDefaults]objectForKey:_pUserInfoDic];
    [self updateUserInfo:userInfo];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self downloadFile];
}


-(void)downloadFile{
    
    int fileID = [(QBCBlob *)[[[DataManager instance] fileList] lastObject] ID];
    
    if(fileID > 0){
        
        // Download file from QuickBlox server
        [[NSUserDefaults standardUserDefaults]setInteger:fileID forKey:_pUserProfilePic];
        [QBContent TDownloadFileWithBlobID:fileID delegate:self];
    }
    else
    {
               
         [QBAuth createSessionWithDelegate:self];
       
   
    }
    
}


#pragma mark - Update UserInformation
-(void)updateUserProfileData:(NSDictionary *)userInfo
{
    [[NSUserDefaults standardUserDefaults]setObject:userInfo forKey:_pUserInfoDic];
    [[NSUserDefaults standardUserDefaults]synchronize];
    lblName.text=[NSString stringWithFormat:@"%@ %@",[userInfo objectForKey:@"first_name"],[userInfo objectForKey:@"last_name"]];
    lblActive.text=@"active";
    lblMotto.text=[NSString stringWithFormat:@"%@",@"Share your moto"];
}


#pragma mark loginView Delegate

-(void)updateUserInfo:(NSDictionary *)dic
{
    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:_pUserInfoDic];
    [[NSUserDefaults standardUserDefaults]synchronize];
    lblName.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"first_name"]];
    lblActive.text=@"active";
    lblMotto.text=[NSString stringWithFormat:@"%@",@"Share your moto"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login View

- (void)showLoginView {
    
    NSString *xibName = NSStringFromClass([LoginViewController class]);
    BOOL isiPhone5 = [[CommonFunctions sharedObject] isDeviceiPhone5];
    if (!isiPhone5)
        xibName = [NSString stringWithFormat:@"%@4", xibName];
    
    LoginViewController *objLoginView = [[LoginViewController alloc] initWithNibName:xibName bundle:nil];
    objLoginView.delegate=self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:objLoginView];
    [navigationController.navigationBar setTranslucent:false];
    [self presentViewController:navigationController animated:NO completion:nil];
}

#pragma mark - IBActions
- (IBAction)logNightAction:(id)sender {
    LogNightViewController *objLogNight = [[LogNightViewController alloc] initWithNibName:@"LogNightViewController" bundle:nil];
    [self.navigationController pushViewController:objLogNight animated:YES];
}
- (IBAction)setReminderAction:(id)sender {
}
- (IBAction)editAccountAction:(id)sender {
}
- (IBAction)logoutAction:(id)sender {

    FBSession *session=[FBSession activeSession];
    [session closeAndClearTokenInformation];
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    [userDefs setBool:false forKey:_pudLoggedIn];
    [userDefs synchronize];
    
    [self showLoginView];
}
- (IBAction)notificationsAction:(id)sender {
    int heightForView = 60;
    if (viewNotifications.frame.origin.y > 290) {
        heightForView = 280;
    }
}


// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result{
    
    // Download file result
    if ([result isKindOfClass:QBCFileDownloadTaskResult.class]) {
        
        // Success result
        if (result.success) {
            
            QBCFileDownloadTaskResult *res = (QBCFileDownloadTaskResult *)result;
            if ([res file]) {
                
                // Add image to gallery
                [[DataManager instance] savePicture:[UIImage imageWithData:[res file]]];
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[res file]]];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageViewProfile.image=imageView.image;

                //
               // [[[DataManager instance] fileList] removeLastObject];
             
            }
        }
    }
    
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        // Success result
        if(result.success){
         
            int fileID = [[NSUserDefaults standardUserDefaults]integerForKey:_pUserProfilePic];
            
            [QBContent TDownloadFileWithBlobID:fileID delegate:self];
            
    
        }
        
    }
}



-(void)setProgress:(float)progress{
    NSLog(@"progress: %f", progress);
}

@end
