//
//  MainViewController.h
//  whgonline
//
//  Created by Marius on 26.08.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AccountViewController.h"

@interface MainViewController : UIViewController<UIWebViewDelegate>

- (void)applicationDidBecomeActive;
- (void)loadAlert;
- (void)loadViews;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) NSString *userGroup;

@end
