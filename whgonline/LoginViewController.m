//
//  LoginViewController.m
//  whgonline
//
//  Created by Marius on 26.08.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

NSString *userGroup;

NSString *registerUrl = @"http://vplan.whgonline.de/index.php?p=register";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
}

- (IBAction)login:(id)sender {
    // User validation, if success call the success segue
    if (self.usernameTextField.text.length != 0 && self.passwordTextField.text.length != 0) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"http://vplan.whgonline.de/api.php?do=getToken" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *token = operation.responseString;
            NSDictionary *parameters = @{@"login":@"Einloggen", @"username":self.usernameTextField.text, @"password":self.passwordTextField.text, @"token":token};
            [manager POST:@"http://vplan.whgonline.de/api.php?do=getStatus" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                userGroup = operation.responseString;
                if ([userGroup isEqualToString:@"PUPIL"] || [userGroup isEqualToString:@"TEACHER"] || [userGroup isEqualToString:@"ADMIN"]) {
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setValue:self.usernameTextField.text forKey:@"username"];
                    [defaults synchronize];
                     
                    [self saveCookies];
                     
                    //[self setApnsToken];
                    
                    // Render success
                    [self performSegueWithIdentifier:@"loginSuccessSegue" sender:self];
                    
                } else {
                    // Login failed—inform the user
                    __block UIAlertView *alert =
                    [[UIAlertView alloc]
                        initWithTitle:@"Login fehlgeschlagen"
                        message:@"Dein Benutzername oder dein Passwort stimmen nicht. Bitte versuche es erneut."
                        delegate:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:nil];
                    [alert show];
                    
                    // Hide the alert
                    double delayInSeconds = 3;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [alert dismissWithClickedButtonIndex:0 animated:YES];
                    });
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    } else {
        
    }
}

- (void)saveCookies {
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
}


- (void)showError:(NSString *)response {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                    message:response
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (IBAction)register:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    webViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    webViewController.webURL = registerUrl;
    webViewController.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Fertig"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(dismissModalViewControllerAnimated:)];
    webViewController.navigationItem.rightBarButtonItem = doneButton;
    
    [webViewController.navigationItem setTitle:@"Registrieren"];
    
    if (webViewController) {
        [self presentViewController:navigationController animated:YES completion:nil];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField) {
        //[textField resignFirstResponder];
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loginSuccessSegue"]) {
        UITabBarController *tabBarController = [segue destinationViewController];
        UINavigationController *navigationController = [tabBarController.viewControllers objectAtIndex:0];
        MainViewController *mainViewController = (MainViewController *)navigationController.visibleViewController;
        mainViewController.userGroup = userGroup;
        [mainViewController loadViews];
    }
}



@end
