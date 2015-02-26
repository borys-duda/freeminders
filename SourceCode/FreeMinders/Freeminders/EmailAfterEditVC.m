//
//  EmailAfterEditVC.m
//  Freeminders
//
//  Created by Vegunta's on 07/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "EmailAfterEditVC.h"
#import "UserContact.h"
#import "UserData.h"
#import "DataManager.h"


@interface EmailAfterEditVC ()


@property (weak, nonatomic) IBOutlet UILabel *firstEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdEmailAddressLabel;
@property (weak,nonatomic) IBOutlet UISwitch *firstEmailSwitch;
@property (weak,nonatomic) IBOutlet UISwitch *secondEmailSwitch;
@property (weak,nonatomic) IBOutlet UISwitch *thirdEmailSwitch;

@end

@implementation EmailAfterEditVC
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
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([[UserData instance].userContacts count]){
        BOOL isOn = NO;
        if ([UserData instance].task.userContacts) {
            for (int i=0; i < [[UserData instance].task.userContacts count]; i++) {
                NSString *objId = ((UserContact *)[[UserData instance].task.userContacts objectAtIndex:i]).objectId;
                if ([objId isEqualToString:((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).objectId]) {
                    isOn = YES;
                    break;
                }
            }
        }else{
            isOn = ((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).defaultBool;
        }
        [self.firstEmailSwitch setOn:isOn animated:YES];
        self.firstEmailAddressLabel.text= ((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email;
    }
    if ([[UserData instance].userContacts count] > 1){
        BOOL isOn = NO;
        if ([UserData instance].task.userContacts) {
            for (int i=0; i < [[UserData instance].task.userContacts count]; i++) {
                NSString *objId = ((UserContact *)[[UserData instance].task.userContacts objectAtIndex:i]).objectId;
                if ([objId isEqualToString:((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).objectId]) {
                    isOn = YES;
                    break;
                }
            }
        }else{
            isOn = ((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).defaultBool;
        }
        [self.secondEmailSwitch setOn:isOn animated:YES];
        self.secondEmailAddressLabel.text= ((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email;
    }
    if ([[UserData instance].userContacts count]>2) {
        BOOL isOn = NO;
        if ([UserData instance].task.userContacts) {
            for (int i=0; i < [[UserData instance].task.userContacts count]; i++) {
                NSString *objId = ((UserContact *)[[UserData instance].task.userContacts objectAtIndex:i]).objectId;
                if ([objId isEqualToString:((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).objectId]) {
                    isOn = YES;
                    break;
                }
            }
        }else{
            isOn = ((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).defaultBool;
        }
        [self.thirdEmailSwitch setOn:isOn animated:YES];
        self.thirdEmailAddressLabel.text= ((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email;
    }
    [self.tableView reloadData];
}
-(void)performLoadUserContacts
{
//    PFQuery *query = [PFQuery queryWithClassName:[UserContact parseClassName]];
//    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
//    [query setLimit:1000];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        NSLog(@"UserConatcts LOADED");
//        if ([objects.firstObject isKindOfClass:[UserContact class]])
//            [UserData instance].userContacts = [objects mutableCopy];
//    }];
//    NSLog(@"number of objects are %i",[UserData instance].userContacts.count);

    [[DataManager sharedInstance] loadUserContactsWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"UserConatcts LOADED");
        if ([objects.firstObject isKindOfClass:[UserContact class]])
            [UserData instance].userContacts = [objects mutableCopy];
        NSLog(@"number of objects are %i",[UserData instance].userContacts.count);
    }];
}
- (IBAction)cancelButtonPressed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed
{
    if (![UserData instance].task.userContacts) {
        [UserData instance].task.userContacts = [[NSMutableArray alloc] init];
    }
    [[UserData instance].task.userContacts removeAllObjects];
    if ([self.firstEmailSwitch isOn] && self.firstEmailAddressLabel.text.length){
        [[UserData instance].task.userContacts addObject:((UserContact *)([[UserData instance].userContacts objectAtIndex:0]))];
    }
    if ([self.secondEmailSwitch isOn] && self.secondEmailAddressLabel.text.length){
        [[UserData instance].task.userContacts addObject:((UserContact *)([[UserData instance].userContacts objectAtIndex:1]))];
    }
    if ([self.thirdEmailSwitch isOn] && self.thirdEmailAddressLabel.text.length){
        [[UserData instance].task.userContacts addObject:((UserContact *)([[UserData instance].userContacts objectAtIndex:2]))];
    }
      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onOffSwitchChanged:(id)sender {
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(((indexPath.section < [UserData instance].userContacts.count) && ((UserContact *)([[UserData instance].userContacts objectAtIndex:indexPath.section])).email.length > 0) || indexPath.section == [UserData instance].userContacts.count)
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return 0;
    }
    
}
/*- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    sectionsCount=0;
    
    for(int i=0;i<[UserData instance].userContacts.count; i++)
    {
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:i])).email.length > 0)
        {
            sectionsCount++;
        }
        
    }
    return  sectionsCount + 1;
   
}*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([UserData instance].userContacts.count && section < 3)
    {
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:section])).email.length > 0)
        {
            return ((UserContact *)([[UserData instance].userContacts objectAtIndex:section])).name;
        }
        else
            return @"";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    static NSString *cellIdentifier = @"emailcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( ! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([UserData instance].userContacts.count) {
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email.length > 0)
        {
            if(section == 0)
            {
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                self.firstEmailAddressLabel.textColor=[self.firstEmailSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
                return cell;
            }
        }
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email.length > 0)
        {
            if(section == 1)
            {
                
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                self.secondEmailAddressLabel.textColor=[self.secondEmailSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
                return cell;
            }
        }
        if(((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email.length > 0)
        {
            if(section == 2)
            {
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
                self.thirdEmailAddressLabel.textColor=[self.thirdEmailSwitch isOn]?COLOR_FREEMINDER_BLUE:[UIColor lightGrayColor];
                return cell;
            }
        }
    }
    if(section == [UserData instance].userContacts.count)
    {
        return [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
