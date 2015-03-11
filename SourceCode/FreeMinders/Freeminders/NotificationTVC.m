//
//  NotificationTVC.m
//  Freeminders
//
//  Created by Vegunta's on 11/10/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "NotificationTVC.h"
#import "UserContact.h"
#import "UserData.h"
#import "EmailVC.h"
#import "DataManager.h"

@interface NotificationTVC ()

@property (weak, nonatomic) IBOutlet UILabel *localNotificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdEmailAddressLabel;
@property (weak,nonatomic) IBOutlet UISwitch *localNotificationSwitch;
@property (weak,nonatomic) IBOutlet UISwitch *firstEmailSwitch;
@property (weak,nonatomic) IBOutlet UISwitch *secondEmailSwitch;
@property (weak,nonatomic) IBOutlet UISwitch *thirdEmailSwitch;

@end

@implementation NotificationTVC

NSString *SEGU_TO_EMAIL_SETTINGS =@"NotificationToEmailSettings";
int sectionsCount;

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self titleForNavigation];
    [self intialSetUpUi];
    }
-(void)viewWillAppear:(BOOL)animated
{
    [self intialSetUpUi];
}
-(void)intialSetUpUi
{
//    if( [UserData instance].task.notificationType==localNotification || [UserData instance].task.notificationType==emailandlocalnotification)
//        [self.localNotificationSwitch setOn:YES animated:YES];

    if ([[UserData instance].userContacts count]){
        [self.firstEmailSwitch setOn:((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).defaultBool animated:YES];
        self.firstEmailAddressLabel.text= ((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email;
    }
    if ([[UserData instance].userContacts count]>1){
        [self.secondEmailSwitch setOn:((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).defaultBool animated:YES];
        self.secondEmailAddressLabel.text= ((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email;
    }
    if ([[UserData instance].userContacts count]>2) {
        [self.thirdEmailSwitch setOn:((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).defaultBool animated:YES];
        self.thirdEmailAddressLabel.text= ((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email;
    }
    [self.tableView reloadData];

}
-(void)titleForNavigation
{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setNumberOfLines:2];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setText:@"Group Notication Reset"];
    self.navigationItem.titleView = title;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:SEGU_TO_EMAIL_SETTINGS]){
        EmailVC *controller = (EmailVC *)segue.destinationViewController;
        controller.isFromNotificationScreen = YES;
    }
}
-(IBAction)appEmailSettingsButton
{
    [self performSegueWithIdentifier:SEGU_TO_EMAIL_SETTINGS sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)performLoadUserContacts
{
    [[DataManager sharedInstance] loadUserContactsWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"UserConatcts LOADED");
        if ([objects.firstObject isKindOfClass:[UserContact class]])
            [UserData instance].userContacts = [objects mutableCopy];
    }];
//    PFQuery *query = [PFQuery queryWithClassName:[UserContact parseClassName]];
//    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
//    [query setLimit:1000];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        NSLog(@"UserConatcts LOADED");
//        if ([objects.firstObject isKindOfClass:[UserContact class]])
//            [UserData instance].userContacts = [objects mutableCopy];
//    }];
    NSLog(@"number of objects are %lu",(unsigned long)[UserData instance].userContacts.count);
}
- (IBAction)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed
{
    NSMutableArray *tasksToReset = [[NSMutableArray alloc] init];
    
    for(int i=0 ; i< [UserData instance].reminderGroup.tasksIngroup.count; i++)
    {
        
        if (!((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).userContacts) {
            ((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).userContacts = [[NSMutableArray alloc] init];
        }
        [((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).userContacts removeAllObjects];
        if ([self.firstEmailSwitch isOn] && self.firstEmailAddressLabel.text.length){
            [((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).userContacts addObject:((UserContact *)([[UserData instance].userContacts objectAtIndex:0]))];
        }
        if ([self.secondEmailSwitch isOn] && self.secondEmailAddressLabel.text.length){
            [((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).userContacts addObject:((UserContact *)([[UserData instance].userContacts objectAtIndex:1]))];
        }
        if ([self.thirdEmailSwitch isOn] && self.thirdEmailAddressLabel.text.length){
            [((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).userContacts addObject:((UserContact *)([[UserData instance].userContacts objectAtIndex:2]))];
        }
        [tasksToReset addObject:((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i])];
        
        if([self.localNotificationSwitch isOn])
           ((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).isNotificationEnable=YES;
        else
            ((Reminder *)[[UserData instance].reminderGroup.tasksIngroup objectAtIndex:i]).isNotificationEnable=NO;
        
          
    }
    if(tasksToReset.count)
    {
//        [PFObject saveAllInBackground:tasksToReset];
        [[DataManager sharedInstance] saveReminders:tasksToReset];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onOffSwitchChanged:(UISwitch *)sender {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section==1) {
        if(indexPath.row==0)
        {
            return 0;
        }
        else
            return 0;
    }else if(indexPath.section==0)
    {
        return [super tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.row]];
        
    }else if(((indexPath.section < [UserData instance].userContacts.count + 2) &&(((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email.length > 0) && (indexPath.section==2)))
    {
        return [super tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.row]];
        
    }else if(((indexPath.section < [UserData instance].userContacts.count + 2) &&(((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email.length > 0) && (indexPath.section==3)))
    {
        return [super tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.row]];
        
    }else if(((indexPath.section < [UserData instance].userContacts.count + 2) &&(((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email.length > 0) && (indexPath.section==4)))
    {
        return [super tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.row]];
        
    }
    else if(indexPath.section == [UserData instance].userContacts.count + 2)
    {
        return [super tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.row]];
    }
    else
    {
        return 0;
    }
}
//- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
//{
//    sectionsCount=0;
//    for(int i=0;i<[UserData instance].userContacts.count; i++)
//    {
//        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:i])).email.length > 0)
//        {
//            sectionsCount++;
//        }
//        
//    }
//    return  sectionsCount + 3;
//    
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if(section==0 || section==1)
    {
        return 25;
    }
    else{
        
        return [super tableView:self.tableView heightForHeaderInSection:section];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0 || section==1)
        return [super tableView: self.tableView titleForHeaderInSection:section];
    if ([UserData instance].userContacts.count) {
        if((section==2) && ((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email.length > 0)
            return ((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).name;
        else if(section == 3 && ((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email.length > 0)
            return ((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).name;
        else if(section==4 && ((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email.length > 0)
            return ((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).name;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    // NSInteger row = indexPath.row;
    
    static NSString *cellIdentifier = @"emailcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( ! cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(section==0)
    {
        cell = [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
        self.localNotificationLabel.textColor = [self.localNotificationSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
        return cell;
    }
    if(section==1)
    {
        return [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    }
    if ([UserData instance].userContacts.count) {
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email.length > 0)
        {
            if(section==2)
            {
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
                self.firstEmailAddressLabel.textColor=[self.firstEmailSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
                return cell;
            }
        }
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email.length > 0)
        {
            if(section==3)
            {
                
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
                self.secondEmailAddressLabel.textColor=[self.secondEmailSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
                return cell;
            }
        }
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email.length > 0)
        {
            if(section==4)
            {
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
                self.thirdEmailAddressLabel.textColor=[self.thirdEmailSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
                return cell;
            }
        }
    }
    if(section == [UserData instance].userContacts.count + 2)
    {
        return [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
    }

    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

@end
