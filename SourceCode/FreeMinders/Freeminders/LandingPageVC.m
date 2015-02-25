//
//  LandingPageVC.m
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "LandingPageVC.h"
#import "Utils.h"
#import "Const.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "LoginVC.h"

@interface LandingPageVC ()

@property (nonatomic,strong)UIWindow *mainWindow;

@end

@implementation LandingPageVC

NSString *NOT_LOGGED_IN_SEGUE = @"userNotLoggedInSegue";
bool isAgreement;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([PFUser currentUser]) { // User logged in
        NSLog(@"USER LOGGED IN");
        [self performSegueWithIdentifier:SEGUE_SUCCESSFUL_LOGIN sender:self];
        [Utils loadUserInfoForLogin];
    } else {
        NSLog(@"USER NOT LOGGED IN");
//        if([[NSUserDefaults standardUserDefaults] boolForKey:@"terms"] == NO){
//            self.mainWindow =((AppDelegate *)([[UIApplication sharedApplication] delegate])).window;
//            self.mainWindow.tag=203;
//            [self setupAgreementView];
//        }
//        else{
//            [self performSegueWithIdentifier:NOT_LOGGED_IN_SEGUE sender:self];
//        }
          [self performSegueWithIdentifier:NOT_LOGGED_IN_SEGUE sender:self];
        
   }
}

//-(void)agreementAccept{
//	
//    isAgreement=1;
//    UIView *agreementView = [self.mainWindow viewWithTag:202];
//    [agreementView removeFromSuperview];
//	
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"terms"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//   
//    [self performSegueWithIdentifier:NOT_LOGGED_IN_SEGUE sender:self];
//}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if([segue.identifier isEqualToString:NOT_LOGGED_IN_SEGUE]){
//       if(isAgreement)
//       {
//           isAgreement=0;
//           LoginVC *loginFirstTimeInThisApp=(LoginVC *)segue.destinationViewController;
//           loginFirstTimeInThisApp.isFirstTimeInstallationApp=YES;
//       }
//    }
//}
//-(void)agreemntDecline{
//	
//	exit(99);
//}
//-(void)setupAgreementView{
//	
//    UIView *agreementView = [[UIView alloc] initWithFrame:(CGRect){(320-10)/2,(460-10)/2,10,10}];
//	agreementView.tag = 202;
//	agreementView.backgroundColor = [UIColor whiteColor];
//    	UIWebView *webView = [[UIWebView alloc] initWithFrame:(CGRect){0,20,320,self.mainWindow.frame.size.height-65}];
//    	webView.delegate = self;
//    	NSString *_resource =@"Terms_popup";
//    	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
//    																			  pathForResource:_resource ofType:@"htm"]isDirectory:NO]]];
//        [self.mainWindow addSubview: agreementView];
//	
//	[UIView animateWithDuration:0.3 animations:^{
//		
//         agreementView.frame = (CGRect){0,0,320,self.mainWindow.frame.size.height};
//		
//    }completion:^(BOOL finished){
//		agreementView.backgroundColor = [UIColor whiteColor];
//        [agreementView addSubview:webView];
//		
//		UIButton *disagreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        //		[disagreeButton setBackgroundImage:[UIImage imageNamed:@"agreementButton.png"] forState:UIControlStateNormal];
//		[disagreeButton setTitle:NSLocalizedString(@"Disagree",nil) forState:UIControlStateNormal];
//		[disagreeButton addTarget:self action:@selector(agreemntDecline) forControlEvents:UIControlEventTouchUpInside];
//		 disagreeButton.frame = (CGRect){0,agreementView.frame.size.height - 45,
//			159, 45};
//        [disagreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [disagreeButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
//		[agreementView addSubview:disagreeButton];
//		
//		UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        //		[agreeButton setBackgroundImage:[UIImage imageNamed:@"agreementButton.png"] forState:UIControlStateNormal];
//		[agreeButton setTitle:NSLocalizedString(@"Agree",nil) forState:UIControlStateNormal];
//		[agreeButton addTarget:self action:@selector(agreementAccept) forControlEvents:UIControlEventTouchUpInside];
//		agreeButton.frame = (CGRect){160,agreementView.frame.size.height - 45,
//			161, 45};
//        [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [agreeButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
//        
//		[agreementView addSubview:agreeButton];
//	}];
//	
//	
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
