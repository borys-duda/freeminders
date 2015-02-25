//
//  AboutAndHelpTVC.m
//  Freeminders
//
//  Created by Vegunta's on 27/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "AboutAndHelpTVC.h"
#import "Const.h"
#import "helpVC.h"

@interface AboutAndHelpTVC ()

@property (weak, nonatomic) IBOutlet UIButton *helpHowToButton;
@property (weak, nonatomic) IBOutlet UIButton *DonateButton;
@property (weak, nonatomic) IBOutlet UIButton *freemindersButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;


@end

@implementation AboutAndHelpTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    NSMutableAttributedString *titleStringForHelp = [[NSMutableAttributedString alloc] initWithString:@"Help/HowTo"];
    
    // making text property to underline text-
    [titleStringForHelp addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleStringForHelp length])];
    // making color vhnage for the sting title
    [titleStringForHelp addAttribute:NSForegroundColorAttributeName value:COLOR_FREEMINDER_BLUE range:NSMakeRange(0, [titleStringForHelp length])];

    // using text on button
    [self.helpHowToButton setAttributedTitle:titleStringForHelp forState:UIControlStateNormal];
    
    
    NSMutableAttributedString *titleStringforfreminders = [[NSMutableAttributedString alloc] initWithString:@"freeminders.com"];
    
    // making text property to underline text-
    [titleStringforfreminders addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleStringforfreminders length])];
    
    // making color vhnage for the sting title

    [titleStringforfreminders addAttribute:NSForegroundColorAttributeName value:COLOR_FREEMINDER_BLUE range:NSMakeRange(0, [titleStringforfreminders length])];

    // using text on button
    [self.freemindersButton setAttributedTitle: titleStringforfreminders forState:UIControlStateNormal];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text=version;
    
    self.releaseDateLabel.text = [NSString stringWithUTF8String:__DATE__];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)helpHowToButtonPressed
{
     helpVC *controller=[[helpVC alloc]init];
//     UINavigationController *navigationController =[[UINavigationController alloc] initWithRootViewController:controller];
//     [self presentViewController:navigationController animated:YES completion:nil];
    [self.navigationController pushViewController:controller animated:YES];
}
-(IBAction)DonateButtonPressed
{
    
}
-(IBAction)freemindersButtonPressed
{
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://freeminders.com"]];
}

@end
