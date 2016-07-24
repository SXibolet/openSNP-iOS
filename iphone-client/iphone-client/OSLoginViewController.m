//
//  OSLoginViewController.m
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSLoginViewController.h"
#import "OSConstants.h"
#import "KeychainItemWrapper.h"
#import "OSHomeViewController.h"

@implementation OSLoginViewController

- (id)initWithURLString:(NSString *)urlString {
    self = [super initWithNibName:@"LoginView" bundle:nil];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView setDelegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    self.webView.multipleTouchEnabled = TRUE;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (IBAction)cancel:(id)sender {
    [self.webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSDictionary *headers = [(NSHTTPURLResponse*)resp.response allHeaderFields];
    NSString *key, *email;
    if ([[webView request].URL.absoluteString isEqualToString:LOGIN_URL] && ((key = headers[KEY_HTTP_HEADER_KEY]) != NULL) && (email = headers[EMAIL_HTTP_HEADER_KEY])) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
        [keychain setObject:(__bridge NSString *)kSecAttrAccessibleWhenUnlocked forKey:(__bridge NSString *)kSecAttrAccessible];
        
        // store the user's uuid in their keychain
        [keychain setObject:key forKey:(__bridge NSString *)kSecValueData];
        // " " " email " " "
        [keychain setObject:email forKey:(__bridge NSString *)kSecAttrAccount];
        
        
        [self dismissViewControllerAnimated:TRUE completion:^{
            UIViewController *pvc = self.presentingViewController;
            if ([pvc respondsToSelector:@selector(updateAfterLogin)]) {
                [pvc performSelector:@selector(updateAfterLogin)];
            }
        }];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}


@end