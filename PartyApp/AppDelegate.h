//
//  AppDelegate.h
//  PartyApp
//
//  Created by Varun on 14/06/2014.
//  Copyright (c) 2014 WebFactory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, QBActionStatusDelegate> {
    BOOL refreshingSession;
    
}
@property (nonatomic,retain) NSDictionary *userInfo;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) FBSession *session;

//- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
//- (void)userLoggedIn;
//- (void)userLoggedOut;
- (void)getUserInformation;

@end
