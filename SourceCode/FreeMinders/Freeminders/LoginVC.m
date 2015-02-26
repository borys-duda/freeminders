//
//  LoginVC.m
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "LoginVC.h"
#import "Utils.h"
//#import <Parse/Parse.h>
//#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Const.h"
#import "DataManager.h"
#import "UserManager.h"

#define SEGUE_SIGNUP @"signup"
#define DEVELOPMENT 0

#define VERIFY_TITLE @"Verify Email Address"
#define VERIFY_MESSAGE @"An email has been sent to the inbox associated with this email address. Please validate your account by clicking the link provided in that email."

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;

@property (nonatomic) AlertType alertType;

@end

@implementation LoginVC
@synthesize isFirstTimeInstallationApp;
AlertType alertType;
CGFloat keyboardHeight = 80.0;
NSString *NOT_LOGGED_IN_SEGUES = @"userNotLoggedInSegue";
NSString *emailRegex ;


- (void)viewDidLoad
{
    [super viewDidLoad];
    emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupGestureRecognizers];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *forgotPasswordTap = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(forgotPasswordLabelPressed)];
    [self.forgotPasswordLabel addGestureRecognizer:forgotPasswordTap];
}

- (void)dismissKeyboard
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark- Actions

- (void)signupLabelPressed
{
    [self performSegueWithIdentifier:SEGUE_SIGNUP sender:self];
}

- (void)forgotPasswordLabelPressed
{
    [self dismissKeyboard];
    self.alertType = forgotPassword;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Password" message:@"Enter your email address to reset your password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)loginButtonPressed:(id)sender
{
    [self checkCredentialsForLogin];
}

- (IBAction)signupButtonPressed
{
    [self checkCredentialsForSignup];
}

- (IBAction)loginFacebookButtonPressed:(id)sender
{

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[UserManager sharedInstance] loginFacebookUserWithBlock:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!user) {
            if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
                [Utils showSimpleAlertViewWithTitle:@"Login Cancelled" content:@"You cancelled the Facebook login." andDelegate:self];
            } else {
                NSLog(@"An error occurred: %@", error);
                [Utils showSimpleAlertViewWithTitle:@"Login Failed" content:@"Either the email address provided does not have an account associated with it or the password you supplied is incorrect. Please check these values and try again." andDelegate:self];
            }
        } else {
            int interval = (int)round(-[user.createdAt timeIntervalSinceNow]);
            NSLog(@"User with facebook logged in! %d",interval);
            if (interval<30) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [Utils setParseEmailForFacebookLogin];
                [Utils loadDefaultTasks:self selector:@selector(defaultRemindersCallBack:)];
            }else {
                [Utils setParseEmailForFacebookLogin];
                if(isFirstTimeInstallationApp){
                    isFirstTimeInstallationApp=0;
                    [self performSegueWithIdentifier:SEGUE_SUCCESSFUL_LOGIN sender:self];
                }
                else{
                    [self performSegueWithIdentifier:SEGUE_SUCCESSFUL_LOGIN sender:self];
                }
            }
        }
    }];
}

- (void)defaultRemindersCallBack:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    if (error) {
//        [Utils showSimpleAlertViewWithTitle:@"Error" content:@"The default reminders could not be saved, please check your internet connection" andDelegate:nil];
//        return;
//    }
    [self performSegueWithIdentifier:SEGUE_SUCCESSFUL_LOGIN sender:self];
}
- (void)defaultRemindersCallBackForSignup:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UserManager sharedInstance] logoutUser];
    [UserData clearInstance];
}

#pragma mark- UIAlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == forgotPassword) {
        if (buttonIndex == 1) {
            NSString *email = [alertView textFieldAtIndex:0].text;
            
            if (email.length > 0) {
                [[UserManager sharedInstance] requestResetPasswordWithEmail:email];
                [Utils showSimpleAlertViewWithTitle:@"Password Reset Sent" content:@"Your password reset instructions have been emailed to you" andDelegate:nil];
            }
        }
    }else if (self.alertType == resendVerificationMail) {
        if (buttonIndex == 1) {
            [[UserManager sharedInstance] resendVerificationEmail:self.usernameTextField.text withBlock:^(BOOL succeeded, NSError *error) {
                [[UserManager sharedInstance] logoutUser];
                [UserData clearInstance];
            }];
            [Utils showSimpleAlertViewWithTitle:@"Verification mail Sent" content:@"Email verification link has been emailed to you" andDelegate:nil];
        }
    }
    
    self.alertType = none;
}

#pragma mark- Networking

- (void)checkCredentialsForLogin
{
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    BOOL verify =[emailTest evaluateWithObject: self.usernameTextField.text];
    
    if(verify)
    {
        NSLog(@"ATTEMPT TO LOGIN WITH USERNAME:%@ AND PASSWORD:%@",
              self.usernameTextField.text,
              self.passwordTextField.text);
        NSString *username = [self.usernameTextField.text lowercaseString];
        NSString *password = self.passwordTextField.text;
        
        if (username.length < 1 || password.length < 1) {
            [Utils showSimpleAlertViewWithTitle:@"Invalid Login Credentials" content:@"Your email and password cannot be blank" andDelegate:nil];
            return;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[UserManager sharedInstance] loginUser:username withPassword:password withBlock:^(PFUser *user, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"%@ %@ --- %d",[user objectForKey:@"emailVerified"], [([user objectForKey:@"emailVerified"]) class],error.code);
            BOOL isVerified = [[user objectForKey:@"emailVerified"] boolValue];
#if DEVELOPMENT
            isVerified = YES;
#endif
            if(user && isVerified) {
                if(isFirstTimeInstallationApp){
                    [self performSegueWithIdentifier:SEGUE_SUCCESSFUL_LOGIN sender:self];
                }else{
                    [self performSegueWithIdentifier:SEGUE_SUCCESSFUL_LOGIN sender:self];
                }
            }else if (user && (!isVerified)) {
                UIAlertView *verifyAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Your email is not verified. Please check your inbox and click on link provided." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Resend", nil];
                self.alertType = resendVerificationMail;
                [verifyAlert show];
            } else if(!user) {
                // alert user that login credentials failed
                NSString *msg = @"Either the email address provided does not have an account associated with it or the password you supplied is incorrect. Please check these values and try again.";
                if (error.code == 100) {
                    msg = @"The Internet connection appears to be offline.";
                }
                [Utils showSimpleAlertViewWithTitle:@"Login Failed" content:msg andDelegate:nil];
            }
        }];
    }
    else{
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@""
                                                           message:@"Enter a valid email address"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
        
    }
}

- (void)checkCredentialsForSignup
{
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL verify =[emailTest evaluateWithObject: self.usernameTextField.text];
    
    if(verify)
    {
        NSLog(@"ATTEMPT TO CREATE ACCOUNT WITH EMAIL:%@ AND PASSWORD:%@",
              self.usernameTextField.text,
              self.passwordTextField.text);
        NSString *username = [self.usernameTextField.text lowercaseString];
        NSString *password = [self.passwordTextField.text lowercaseString];
        
        if(username.length < 1 || password.length < 4) {
            [Utils showSimpleAlertViewWithTitle:@"Invalid Signup" content:@"Your email must be a valid email address and your password must be at least 4 characters" andDelegate:nil];
            return;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[UserManager sharedInstance] signUpUser:username withPassword:password withBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [Utils showSimpleAlertViewWithTitle:VERIFY_TITLE content:VERIFY_MESSAGE andDelegate:nil];;
                self.passwordTextField.text=@"";
                self.usernameTextField.text=@"";
                [Utils loadDefaultTasks:self selector:@selector(defaultRemindersCallBackForSignup:)];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSString *errorString = [error userInfo][@"error"];
                // show the errorString in alert view
                [Utils showSimpleAlertViewWithTitle:@"Signup Failed" content:errorString andDelegate:nil];
            }
        }];
        
    }
    else{
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@""
                                                           message:@"Enter a valid email address"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
        
    }
}
//-(void) textFieldDidBeginEditing:(UITextField *)textField{
//    if ([textField.placeholder isEqualToString:@"username"]) {
//        [((UIScrollView*)self.view) setContentOffset:CGPointMake(0, 120) animated:YES];
//    }else{
//        [((UIScrollView*)self.view) setContentOffset:CGPointMake(0, 160) animated:YES];
//    }
//}
//-(void) textFieldDidEndEditing:(UITextField *)textField{
//    [((UIScrollView*)self.view) setContentOffset:CGPointMake(0, 0) animated:YES];
//}

#pragma mark- Keyboard handling

- (void)keyboardWillShow:(NSNotification*)notification
{
    keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    keyboardHeight = 216;
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    //    else if (self.view.frame.origin.y < 0)
    //    {
    //        [self setViewMovedUp:NO];
    //    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    keyboardHeight = 216;
    /*   if (self.view.frame.origin.y >= 0)
     {
     [self setViewMovedUp:YES];
     }
     else */if (self.view.frame.origin.y < 0)
     {
         [self setViewMovedUp:NO];
     }
}

//-(void)textFieldDidBeginEditing:(UITextField *)sender
//{
//    if  (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
         [UIView setAnimationDuration:0.45];
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= keyboardHeight;
    } else {
        // revert back to the normal state.
         [UIView setAnimationDuration:0.10];
        rect.origin.y += keyboardHeight;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark- End of life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[PFUser currentUser] isAuthenticated]) {
        [Utils loadUserInfoForLogin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
