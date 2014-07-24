//
//  AppDelegate.m
//  PartyApp
//
//  Created by Varun on 14/06/2014.
//  Copyright (c) 2014 WebFactory. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "SplashScreenViewController.h"
#import "FXBlurView.h"

@implementation AppDelegate

#pragma mark - AppDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Quickblox Account Setting
    [QBSettings setApplicationID:_pApplicationID];
    [QBSettings setAuthorizationKey:_pAuthorizationKey];
    [QBSettings setAuthorizationSecret:_pAuthorizationSecret];
    [QBSettings setAccountKey:_pAccountKey];
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self setApplicationDefaults];
    
    NSString *xibName = NSStringFromClass([ProfileViewController class]);
    BOOL isiPhone5 = [[CommonFunctions sharedObject] isDeviceiPhone5];
    if (!isiPhone5)
        xibName = [NSString stringWithFormat:@"%@4", xibName];
   
    ProfileViewController *objProfileView = [[ProfileViewController alloc] initWithNibName:xibName bundle:nil];
    objProfileView.isComeFromSignUp = FALSE;
    self.navController = [[UINavigationController alloc] initWithRootViewController:objProfileView];
    [self.navController.navigationBar setTranslucent:false];

    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"profile_picture"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                         
                                      }];
        
        // If there's no cached session, we will show a login button
    }
    
    [self.window setRootViewController:self.navController];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)setApplicationDefaults {
    
    [QBAuth createSessionWithDelegate:self];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:true];
    
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    if (![userDefs objectForKey:_pudLoggedIn])
        [userDefs setBool:false forKey:_pudLoggedIn];
    if (![userDefs objectForKey:_pudSessionExpiryDate])
        [userDefs setObject:[NSDate date] forKey:_pudSessionExpiryDate];
    [userDefs synchronize];
    
    //  Navigation Bar Setup
    UIColor *colorNavTitleText = [[CommonFunctions sharedObject] colorWithHexString:@"5f4b5e"];
    UIFont *fontNavTitleText = [UIFont fontWithName:@"ArialMT" size:14];
    
    NSDictionary *dictNavTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            colorNavTitleText, NSForegroundColorAttributeName,
                                            fontNavTitleText, NSFontAttributeName, nil];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:dictNavTitleAttributes];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
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
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    [QBAuth createSessionWithDelegate:self];
    [FBAppEvents activateApp];
  
    [FBAppCall handleDidBecomeActiveWithSession:self.session];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
     [self.session close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    return [FBSession.activeSession handleOpenURL:url];
//}

#pragma mark - QBSession Delegate

- (void)completedWithResult:(Result *)result{
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = nil;
    // QuickBlox application authorization result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        // Success result
        if(result.success){
            
            for (UIView *view in self.window.subviews) {
                if ([view isKindOfClass:[FXBlurView class]]) {
                    for (UIView *subView in view.subviews)
                        [subView removeFromSuperview];
                    [view removeFromSuperview];
                }
            }
            
            NSDate *sessionExpDate = [[QBBaseModule sharedModule] tokenExpirationDate];
            NSString *sessionToken = [[QBBaseModule sharedModule] token];
            
            NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
            [userDefs setObject:sessionExpDate  forKey:_pudSessionExpiryDate];
            [userDefs setObject:sessionToken    forKey:_pudSessionToken];
            [userDefs synchronize];
            refreshingSession = false;
        }
        else
            [self showMessage:@"Unable to make connection this time."
                    withTitle:@"No Connectivity"];
    }
}


#pragma mark - Facebook Specific Methods

/*
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
       
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{

    // Confirm logout message
    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self getUserInformation];
    }
    else
    {
        [self requestForFBSession];
    }
    
}
*/

-(void)getUserInformation
{
    [FBRequestConnection startWithGraphPath:@"/me"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              
                              [self makeRequestForUserData];
                              /* handle the result */
                          }];

}

-(void)requestForFBSession
{
    NSArray *permissionsNeeded = @[@"public_profile"];

    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // These are the current permissions the user has
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  
                                  // We will store here the missing permissions that we will have to request
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession
                                       requestNewReadPermissions:requestPermissions
                                       completionHandler:^(FBSession *session, NSError *error) {
                                           if (!error) {
                                               // Permission granted, we can request the user information
                                               [self makeRequestForUserData];
                                           } else {
                                               // An error occurred, we need to handle the error
                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                               NSLog(@"error %@", error.description);
                                           }
                                       }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self makeRequestForUserData];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
             [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            _userInfo=(NSDictionary *)result;
            ProfileViewController *objProfileView;
            for (id controller in self.navController.viewControllers) {
                
                if([(ProfileViewController *)controller isKindOfClass:[ProfileViewController class]])
                {
                   objProfileView=(ProfileViewController *)controller;
                    break;
                }
            }
            
            NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
            [userDefs setBool:TRUE forKey:_pudLoggedIn];
            [userDefs synchronize];
            [self.navController dismissViewControllerAnimated:YES completion:^{
                //[objProfileView updateUserProfileData:_userInfo];
            }];
            
        } else {
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
}


// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

@end
