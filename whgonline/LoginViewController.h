//
//  LoginViewController.h
//  whgonline
//
//  Created by Marius on 26.08.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;


@end
