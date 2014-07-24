//
//  SplashScreenViewController.m
//  PartyApp
//
//  Created by Gaganinder Singh on 22/06/14.
//  Copyright (c) 2014 WebFactory. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "ProfileViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

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
    // Do any additional setup after loading the view from its nib.
    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:_pudLoggedIn])
//        [QBAuth createSessionWithDelegate:self];
//    else {
        NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userInfo = [userDefs objectForKey:_pudUserInfo];
        
        NSLog(@"Password : %@", [userDefs objectForKey:@"Password"]);
        
        QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
        extendedAuthRequest.userLogin = [userInfo objectForKey:@"login"]; // ID: 218651
        extendedAuthRequest.userPassword = [userDefs objectForKey:@"Password"];
        [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QBDelegate Methods

- (void)completedWithResult:(Result *)result {
    BOOL error = FALSE;
    
    
    if ([result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
        if (result.success) {
            NSLog(@"Session created successfully");
            [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [self dismissViewControllerAnimated:true completion:nil];
        }
        else {
            error = TRUE;
        }
    }
//    else if ([result isKindOfClass:[QBUUserLogInResult class]]) {
//        if (result.success) {
//            QBUUserLogInResult *loginResult = (QBUUserLogInResult *)result;
//            QBUUser *userInfo = [loginResult user];
//            
//            [[CommonFunctions sharedObject] saveInformationInDefaultsForUser:userInfo];
//            NSLog(@"User Info : %@", userInfo);
//            [self dismissViewControllerAnimated:NO completion:nil];
//        }
//        else {
//            error = TRUE;
//        }
//    }
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Session Problem"
                                    message:@"Sorry can't create your session right now"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

@end
