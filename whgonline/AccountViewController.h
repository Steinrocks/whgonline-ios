//
//  AccountViewController.h
//  whgonline
//
//  Created by Marius on 21.12.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface AccountViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@end
