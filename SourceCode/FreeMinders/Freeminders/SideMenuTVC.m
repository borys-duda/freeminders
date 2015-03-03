//
//  SideMenuVC.m
//  GigScout
//
//  Created by Spencer Morris on 1/29/14.
//  Copyright (c) 2014 Scalpr. All rights reserved.
//

#import "SideMenuTVC.h"
#import "Utils.h"
#import "Const.h"
#import "UserData.h"
#import "UserManager.h"
#import "DataManager.h"
//#import <Parse/Parse.h>
//#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FrostedViewController.h"

#define GROUPS_INDEXPATH [NSIndexPath indexPathForRow:2 inSection:0]
#define FEEDBACK_INDEXPATH [NSIndexPath indexPathForRow:8 inSection:0]

@interface SideMenuTVC ()

@property (weak,nonatomic) IBOutlet UILabel *username;
@property (weak,nonatomic) IBOutlet UIImageView *profilePictureView;

@property (nonatomic) BOOL isLoggedInViaFacebook;

@end

@implementation SideMenuTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.username.text = [UserData instance].userSettings.userName;
    self.isLoggedInViaFacebook = [[UserManager sharedInstance] isLinkedWithUser];
    if (self.isLoggedInViaFacebook && [[DataManager sharedInstance] checkConnectionStatus] ){
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser,NSError *error) {
            if (error) {
                // Handle error
            }
            else {
                NSString *userName = [FBuser name];
                NSURL *userImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [FBuser objectID]]];
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    //Background Thread
                    NSData *imageData = [NSData dataWithContentsOfURL:userImageURL];
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        //Run UI Updates
                        self.username.text=userName;
                        self.profilePictureView.image=image;
                        [UserData instance].userSettings.userName = userName;
                    });
                });
            }
        }];
    }
    else{
        self.username.text= [UserData instance].userSettings.userName.length?[UserData instance].userSettings.userName:[[UserManager sharedInstance] getCurrentUser].username;
        self.profilePictureView.hidden = YES;
    }
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (!self.isLoggedInViaFacebook){
        self.username.text= [UserData instance].userSettings.userName.length?[UserData instance].userSettings.userName:[[UserManager sharedInstance] getCurrentUser].username;
        self.profilePictureView.hidden = YES;
    }

}

#pragma mark- MFMailCompose methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath isEqual:FEEDBACK_INDEXPATH]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        if ([MFMailComposeViewController canSendMail]) {
        picker.mailComposeDelegate = self;
        [picker setToRecipients:[NSArray arrayWithObject:CONTACT_EMAIL]];
        [picker setSubject:@"freeminders Feedback"];
        [picker.navigationBar setTintColor:COLOR_LIGHT_GREY];
        [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark- Actions

- (void)menuButtonPressed:(id)sender
{
    [self.frostedViewController hideMenuViewController];
}

#pragma mark- End of lifecycle methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
