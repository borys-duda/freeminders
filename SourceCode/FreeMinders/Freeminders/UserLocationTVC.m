
//
//  UserLocationTVC.m
//  Freeminders
//
//  Created by Saisyam Dampuri on 10/8/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "UserLocationTVC.h"
#import "Const.h"
#import "UserData.h"
#import "UserLocation.h"
#import "NewLocationTVC.h"
#import "LocationCell.h"
#import "MBProgressHUD.h"

@interface UserLocationTVC ()

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

//@property (weak, nonatomic) IBOutlet UIButton *defaultButton;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL isDone;
@property (strong, nonatomic) UserLocation *userLocationsDefault;


@property (nonatomic) BOOL isChecked;
@property (nonatomic) NSInteger IndextoDefult;
@property (nonatomic) NSInteger preIndextoDefult;
@property (nonatomic) int userLocationToEdit;


@property (nonatomic) AlertType alertType;


@end

@implementation UserLocationTVC
NSString *ADD_EDIT_USER_LOCATION = @"addeditlocation";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.userLocationToEdit = -1;
    [self performLoadDefaultAdrress];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if([segue.identifier isEqualToString:ADD_EDIT_USER_LOCATION]){
        NewLocationTVC *controller = (NewLocationTVC *)segue.destinationViewController;
        [controller setLocationToEdit:self.userLocationToEdit];
//    }
}

- (IBAction)settingsButtonPressed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)editButtonPressed:(UIButton *)sender
{
    if(!sender.selected)
    {
        self.isEditing = YES;
        sender.selected = !sender.selected;
        [sender setTitle:@"Done" forState:UIControlStateSelected];
    }
    else
    {
        self.isEditing = NO;
        [PFObject saveAllInBackground:[UserData instance].userLocations block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"User Locations saved");
            }
        }];
        sender.selected = !sender.selected;
    }
    [self.tableView reloadData];
    
}
- (void)performLoadDefaultAdrress
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"userid : %@",[PFUser currentUser].objectId);
    PFQuery *query = [PFQuery queryWithClassName:[UserLocation parseClassName]];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(!error)
        {
            if ([objects.firstObject isKindOfClass:[UserLocation  class]] || objects.count == 0)
                [UserData instance].userLocations = objects;
            for (int i=0; i<[[UserData instance].userLocations count]; i++) {
                UserLocation *loc = [[UserData instance].userLocations objectAtIndex:i];
                _preIndextoDefult = loc.isDefault?i:_preIndextoDefult;
                
            }
            [self.tableView reloadData];
        }
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ([UserData instance].userLocations.count + 1);
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(indexPath.row < ([UserData instance].userLocations.count))
    {
        NSString *CELL_IDENTIFIER = @"userLocationCell";
        LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        if (cell == nil)
            cell = [[LocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        UserLocation *userLocation=[[UserData instance].userLocations objectAtIndex:indexPath.row];
        
        for(UIView *view in cell.contentView.subviews){
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        if (![userLocation isKindOfClass:[NSNull class]]) {
            UILabel *locationLabel=[[UILabel alloc] init];
            if(self.isEditing)
            {
                locationLabel.frame=CGRectMake(14, 0, 135, 44);
            }
            else{
                if(userLocation.isDefault)
                {
                    locationLabel.frame=CGRectMake(14, 0, 240, 44);
                    
                }else{
                    locationLabel.frame=CGRectMake(14, 0, 300, 44);
                }
            }
            locationLabel.text = userLocation.name;
            locationLabel.font=[UIFont systemFontOfSize:15];
            locationLabel.textColor=[UIColor blackColor];
            locationLabel.tag=99+indexPath.row;
            [cell.contentView addSubview:locationLabel];
            cell.defaultButton.hidden = !userLocation.isDefault;
            cell.deleteButton.hidden = !(self.isEditing && !userLocation.isDefault);
            cell.makedefaultButton.hidden = !(self.isEditing && !userLocation.isDefault);
            
            cell.defaultButton.tag = indexPath.row;
            cell.deleteButton.tag = indexPath.row;
            cell.makedefaultButton.tag = indexPath.row;
            cell.defaultButton.layer.cornerRadius = 10;
            //        cell.defaultButton.center = self.isEditing?cell.makedefaultButton.center:cell.deleteButton.center;
        }
        return cell;
    }
    else //if(indexPath.row ==([UserData instance].userLocations.count))
    {
        NSString *CELL_IDENTIFIER = @"addLocationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        return cell;
    }
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
}

- (void)performSaveLocations
{
    [PFObject saveAllInBackground:[UserData instance].userLocations block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"User Locations saved");
        }
    }];
}
#pragma mark- UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == deleteTaskSet && buttonIndex == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        UserLocation *location = [[UserData instance].userLocations objectAtIndex:self.userLocationToEdit];
        [location deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (succeeded) {
                [[UserData instance].userLocations removeObject:location];
                [self performSaveLocations];
            }
            [self performLoadDefaultAdrress];
        }];
    }
    
    self.alertType = none;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 35;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[UserData instance].userLocations count]) {
        self.userLocationToEdit = indexPath.row;
        [self performSegueWithIdentifier:ADD_EDIT_USER_LOCATION sender:self];
    }else{
         self.userLocationToEdit = -1;
        [self performSegueWithIdentifier:ADD_EDIT_USER_LOCATION sender:self];
    }
}


- (IBAction)makeDefaultButtonPressed:(UIButton *)sender
{
    if(!sender.selected)
    {
        _IndextoDefult = sender.tag;
        for (int i=0; i<[[UserData instance].userLocations count]; i++) {
            ((UserLocation *)[[UserData instance].userLocations objectAtIndex:i]).isDefault = NO;
        }
        ((UserLocation *)[[UserData instance].userLocations objectAtIndex:sender.tag]).isDefault = YES;
        _isDone=1;
//        sender.selected = !sender.selected;
        [self.tableView reloadData];
        
    }
    else
    {
        sender.selected = !sender.selected;
    }
    
}
- (IBAction)deleteButtonPressed:(UIButton *)button
{
    NSInteger indexToDelete = button.tag;
    NSString *name = ((UserLocation *)[[UserData instance].userLocations objectAtIndex:indexToDelete]).name;
    self.userLocationToEdit = indexToDelete;//[[UserData instance].userLocations objectAtIndex:indexToDelete];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Location?" message:[NSString stringWithFormat:@"Are you sure you want to delete this location \"%@\"? This cannot be undone",name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
    self.alertType = deleteTaskSet;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
