//
//  helpVC.m
//  Freeminders
//
//  Created by Vegunta's on 05/12/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "helpVC.h"

@interface helpVC ()

@end

@implementation helpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"Help";
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
//                                   initWithTitle:@"Back"
//                                   style:UIBarButtonItemStyleBordered
//                                   target:self
//                                   action:@selector(backButtonpressed)];
//    self.navigationItem.leftBarButtonItem = backButton;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:(CGRect){0, 0 ,320, self.view.frame.size.height}];
    webView.delegate = self;
    NSString *_resource =@"HowTo v1.31";
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                              pathForResource:_resource ofType:@"htm"] isDirectory:NO]]];
    [self.view addSubview:webView];
    
}
//-(void)backButtonpressed
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
