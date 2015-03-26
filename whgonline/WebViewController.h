//
//  WebViewController.h
//  whgonline
//
//  Created by Marius on 27.11.13.
//  Copyright (c) 2013 Marius Gebhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *webURL;

- (void)navigate:(NSString *)url;

@end
