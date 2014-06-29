//
//  BaseViewController.m
//  PartyApp
//
//  Created by Varun on 14/06/2014.
//  Copyright (c) 2014 WebFactory. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

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
    
    UIColor *backColor = [[CommonFunctions sharedObject] colorWithImageName:@"appBackground"
                                                                    andType:@"png"];
    [self.view setBackgroundColor:backColor];
    
//    UIImage *imgBackButton = [[CommonFunctions sharedObject] imageWithName:@"backButton"
//                                                                   andType:_pPNGType];
    
//    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBackButton style:UIBarButtonItemStyleBordered target:nil action:nil];
////    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
////    self.navigationController.navigationBar.backIndicatorImage = imgBackButton;
////    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = imgBackButton;
//    [self.navigationItem setBackBarButtonItem:backButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
