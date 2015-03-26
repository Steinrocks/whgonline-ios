//
//  AccountViewController.m
//  whgonline
//
//  Created by Marius on 21.12.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
}

- (IBAction)logout:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://vplan.whgonline.de/api.php?do=logout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionCookies"];
        
        LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        [self presentViewController:loginViewController animated:NO completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
