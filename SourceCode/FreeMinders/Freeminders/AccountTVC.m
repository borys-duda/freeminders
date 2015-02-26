//
//  AccountTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 6/11/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "AccountTVC.h"
#import "Utils.h"
#import "UserManager.h"

#define SEGUE_LOGOUT @"logout"

@interface AccountTVC ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *emailFeatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *subsriptionStausLabel;

@property (nonatomic) AlertType alertType;

@property (nonatomic) BOOL isLoggedInViaFacebook;

@end


@implementation AccountTVC
BOOL isPurchased;
NSString  *SEGUE_EMAIL_FEATURE =@"NotPurchased",*SEGU_SUBSCRIPTION_SCREEN=@"activeSubscription";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.nameTextField.text.length > 0) {
        [UserData instance].userInfo.name = self.nameTextField.text;
//        [[UserData instance].userInfo saveInBackground];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setupUI];

}
- (void)setupUI
{
    self.nameTextField.text = [UserData instance].userSettings.userName;
    self.emailTextField.text = [[UserManager sharedInstance] getCurrentUserEmail];
    
    self.isLoggedInViaFacebook = [[UserManager sharedInstance] isLinkedWithUser];
    
    if (self.isLoggedInViaFacebook) {
        self.nameTextField.text = [UserData instance].userSettings.userName;
        self.emailTextField.text = [[UserManager sharedInstance] getCurrentUserEmail];
        [self.emailTextField setEnabled:NO];
        [self.passwordTextField setEnabled:NO];
    }
    isPurchased = [[UserManager sharedInstance] isPurchasedUser];
    self.emailFeatureLabel.text= isPurchased ? @"Purchased":@"Not Purchased";
    self.emailFeatureLabel.textAlignment=NSTextAlignmentCenter;
    self.subsriptionStausLabel.text=@"No Active Subscription";
     self.subsriptionStausLabel.textAlignment=NSTextAlignmentCenter;
    if ([UserData instance].isHavingActiveSubscription) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        NSMutableAttributedString *titleStringForHelp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Active through %@",[dateFormat stringFromDate:[UserData instance].userSubscription.expireDate]]];
        [titleStringForHelp addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleStringForHelp length])];
        [titleStringForHelp addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]range:NSMakeRange(0, [titleStringForHelp length])];
        self.subsriptionStausLabel.attributedText = titleStringForHelp;
    }
}

- (void)hideKeyboard
{
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark- UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

#pragma mark- UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == changeEmail) {
        if (buttonIndex == 1) {
            NSString *email = [self.emailTextField.text lowercaseString];
            [UserData instance].userSettings.userName = self.nameTextField.text.length?self.nameTextField.text:[UserData instance].userSettings.userName;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[UserManager sharedInstance] changeUserEmail:email andUserSetting:[UserData instance].userSettings withBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (succeeded) {
                    [Utils showSimpleAlertViewWithTitle:@"Email Changed" content:@"Your email has been changed successfully" andDelegate:nil];
                    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    [self logoutButtonPressed];
                } else {
                    [Utils showSimpleAlertViewWithTitle:@"Email Change Failed" content:@"Your email address could not be changed. Please contact support if you have further questions" andDelegate:nil];
                }

            }];

        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (self.alertType == changePassword) {
        if (buttonIndex == 1) {
            NSString* password = self.passwordTextField.text;
            [UserData instance].userSettings.userName = self.nameTextField.text.length?self.nameTextField.text:[UserData instance].userSettings.userName;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[UserManager sharedInstance] changePassword:password andUserSetting:[UserData instance].userSettings withBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (succeeded) {
                    [Utils showSimpleAlertViewWithTitle:@"Password Changed" content:@"Your password has been changed successfully" andDelegate:nil];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [Utils showSimpleAlertViewWithTitle:@"Password Change Failed" content:@"Your password could not be changed. Please contact support if you have further questions" andDelegate:nil];
                }
            }];

        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (self.alertType == changeEmailAndPassword) {
        if (buttonIndex == 1) {
            NSString *email = [self.emailTextField.text lowercaseString];
            NSString *password = self.passwordTextField.text;
            [UserData instance].userSettings.userName = self.nameTextField.text.length?self.nameTextField.text:[UserData instance].userSettings.userName;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[UserManager sharedInstance] changeUserEmail:email andPassword:password andUserSetting:[UserData instance].userSettings withBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (succeeded) {
                    [Utils showSimpleAlertViewWithTitle:@"Password & Email Changed" content:@"Your password and email address have been changed successfully" andDelegate:nil];
                    [self logoutButtonPressed];
                } else {
                    [Utils showSimpleAlertViewWithTitle:@"Password & Email Change Failed" content:@"Your password and email address could not be changed. Please contact support if you have further questions" andDelegate:nil];
                }
            }];
        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    self.alertType = none;
}

#pragma mark- TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isPurchased = [[UserManager sharedInstance] isPurchasedUser];
    if(indexPath.row==3)
    {
        if(!isPurchased)
        {
            [self performSegueWithIdentifier:SEGUE_EMAIL_FEATURE sender:self];
        }
    }
    if(indexPath.row==5)
    {
        
            [self performSegueWithIdentifier:SEGU_SUBSCRIPTION_SCREEN sender:self];
        
    }
}

#pragma mark- Actions

- (IBAction)backButtonPressed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed
{
    if (([[[UserManager sharedInstance] getCurrentUserEmail] isEqualToString:self.emailTextField.text]
         || self.emailTextField.text.length == 0)
        && self.passwordTextField.text.length == 0) {
         [UserData instance].userSettings.userName = self.nameTextField.text;
        [[UserData instance].userSettings saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            }
        }];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.passwordTextField.text.length == 0) {
        self.alertType = changeEmail;
        NSString *message = [NSString stringWithFormat:@"Would you like to change your email address to: %@?", self.emailTextField.text];
        [[[UIAlertView alloc] initWithTitle:@"Change Email Address?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
    } else if ([[[UserManager sharedInstance] getCurrentUserEmail] isEqualToString:self.emailTextField.text]
               || self.emailTextField.text.length == 0) {
        self.alertType = changePassword;
        [[[UIAlertView alloc] initWithTitle:@"Change Password?" message:@"Would you like to change your password?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
    } else {
        self.alertType = changeEmailAndPassword;
        NSString *message = [NSString stringWithFormat:@"Would you like to change your password and change your email address to: %@?", self.emailTextField.text];
        [[[UIAlertView alloc] initWithTitle:@"Change Password & Email Address?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil] show];
    }
}

- (IBAction)logoutButtonPressed
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
     NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    [PFQuery clearAllCachedResults];
    [[UserManager sharedInstance] logoutUser];
    [UserData clearInstance];
//    if (self.isLoggedInViaFacebook) {
////        NSURLRequest *url=[NSURL URLWithString:@"https://m.facebook.com/v2.2/dailog/oauth/confirm"];
//       [[NSURLCache sharedURLCache] removeAllCachedResponses];
//        [self fbDidLogout];
//        [FBSession.activeSession closeAndClearTokenInformation];
//         NSLog(@"The user is no longer associated with their Facebook account.");
//        
//    }
    // if([[NSUserDefaults standardUserDefaults] boolForKey:@"terms"] == NO){
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"terms"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    [self performSegueWithIdentifier:SEGUE_LOGOUT sender:self];
}

//-(void) fbDidLogout
//{
//    NSLog(@"Logged out of facebook");
//    NSHTTPCookie *cookie;
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (cookie in [storage cookies])
//    {
//         NSLog(@"%@", cookie);
//        [storage deleteCookie:cookie];
//    }
//}

#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
