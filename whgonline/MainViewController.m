//
//  ViewController.m
//  whgonline
//
//  Created by Marius on 26.08.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import "MainViewController.h"

@interface MyAlertViewDelegate : NSObject<UIAlertViewDelegate>

typedef void (^AlertViewCompletionBlock)(NSInteger buttonIndex);
@property (strong,nonatomic) AlertViewCompletionBlock callback;

+ (void)showAlertView:(UIAlertView *)alertView withCallback:(AlertViewCompletionBlock)callback;

@end

@implementation MyAlertViewDelegate

@synthesize callback;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    callback(buttonIndex);
}

+ (void)showAlertView:(UIAlertView *)alertView withCallback:(AlertViewCompletionBlock)callback {
    __block MyAlertViewDelegate *delegate = [[MyAlertViewDelegate alloc] init];
    alertView.delegate = delegate;
    delegate.callback = ^(NSInteger buttonIndex) {
        callback(buttonIndex);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        delegate = nil;
#pragma clang diagnostic pop
        alertView.delegate = nil;
    };
    [alertView show];
}

@end



@interface MainViewController ()

@end

@implementation MainViewController

BOOL loggedIn = FALSE;
NSString *token;
UINavigationController *vplanNavigationController = nil;
UIWebView *currentVplanWebView, *oldVplanWebView, *teacherVplanWebView;
LoginViewController *loginViewController = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *wineRed = [UIColor colorWithRed:153.0f/255.0f green:51.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    self.view.tintColor = wineRed;
    self.tabBarController.tabBar.tintColor = wineRed;
    
    [self loadAlert];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
}

- (void)applicationDidBecomeActive {
    [self loadWebViews];
}

- (void)loadViews {
    // Aktueller Vertretungsplan
    currentVplanWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    [currentVplanWebView setScalesPageToFit:YES];
    [currentVplanWebView setDelegate:self];
    
    // Vorheriger Vertretungsplan
    oldVplanWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    [oldVplanWebView setScalesPageToFit:YES];
    [oldVplanWebView setDelegate:self];
    
    NSLog(@"GROUP: %@", self.userGroup);
    
    if([self.userGroup isEqualToString:@"TEACHER"] || [self.userGroup isEqualToString:@"ADMIN"]) {
        // Lehrer Vertretungsplan
        teacherVplanWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
        [teacherVplanWebView setScalesPageToFit:YES];
        [teacherVplanWebView setDelegate:self];
        [self.segmentedControl insertSegmentWithTitle:@"Lehrer" atIndex:2 animated:NO];
    }
    
    self.view = currentVplanWebView;

    [self loadWebViews];
}

- (void)loadWebViews {
    [currentVplanWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://vplan.whgonline.de/getpdf.php?file=vplan"]]];
    [oldVplanWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://vplan.whgonline.de/getpdf.php?file=vplan_a"]]];
    if([self.userGroup isEqualToString:@"TEACHER"] || [self.userGroup isEqualToString:@"ADMIN"]) {
        [teacherVplanWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://vplan.whgonline.de/getpdf.php?file=vplanL"]]];
    }
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        self.view = currentVplanWebView;
    } else if (selectedSegment == 1) {
        self.view = oldVplanWebView;
    } else if (selectedSegment == 2) {
        self.view = teacherVplanWebView;
    }
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:webView animated:YES];
    //hud.labelText = @"Laden";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //[MBProgressHUD hideHUDForView:webView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showError:error.localizedDescription];
}

- (void)loadAlert {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:@"http://vplan.whgonline.de/api.php?do=getAlert" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([operation.responseString length] > 0) {
                NSArray *array = [operation.responseString componentsSeparatedByString:@"|"];
                if([array count] == 1) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:[array objectAtIndex:0] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:[array objectAtIndex:0] delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:@"Ja", nil];
                    [MyAlertViewDelegate showAlertView:alert withCallback:^(NSInteger buttonIndex) {
                        if(buttonIndex == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[array objectAtIndex:1]]];
                        }
                    }];
                }
                
            }
            
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Could not load alert: %@", error);
        }
    ];
}


@end

                                                
