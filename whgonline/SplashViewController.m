//
//  SplashViewController.m
//  whgonline
//
//  Created by Marius on 19.02.15.
//  Copyright (c) 2015 Marius Gebhardt. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getUserStatus:^(NSString *group) {
        UIViewController* rootController;
        if ([group isEqualToString:@"PUPIL"] || [group isEqualToString:@"TEACHER"] || [group isEqualToString:@"ADMIN"]) {
            UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            UINavigationController *navigationController = [tabBarController.viewControllers objectAtIndex:0];
            MainViewController *mainViewController = (MainViewController *)navigationController.visibleViewController;
            mainViewController.userGroup = group;
            [mainViewController loadViews];
            rootController = tabBarController;
        } else {
            rootController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        }
        
        [self presentViewController: rootController animated:NO completion:nil];
    }];
}

- (void)getUserStatus:(void(^)(NSString*))group {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://vplan.whgonline.de/api.php?do=getStatus" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (group) {
                group(operation.responseString);
            }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}


@end
