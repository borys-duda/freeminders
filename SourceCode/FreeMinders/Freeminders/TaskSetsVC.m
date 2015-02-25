//
//  TaskSetsVC.m
//  Freeminders
//
//  Created by Spencer Morris on 5/7/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "TaskSetsVC.h"
#import "AddTaskGroupCell.h"
#import "TaskSetCell.h"
#import "ReminderGroup.h"
#import "UserData.h"
#import "StoreVC.h"

@interface TaskSetsVC ()

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) UITextField *addGroupTextField;

@property (strong, nonatomic) ReminderGroup *taskSetToDelete;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) AlertType alertType;


@end

@implementation TaskSetsVC

CGFloat currentKeyboardHeight = 80.0f, ORIGINAL_VIEW_HEIGHT;

NSString *SEGUE_GROUP_DETAILS=@"GroupDetailsScreen";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([UserData instance].taskSets.count == 0)
        [self performLoadTaskSets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
/*    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
/*    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];*/
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)setupGestureRecognizers
{
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:tap];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"buyGroups"]){
        StoreVC *controller = (StoreVC *)segue.destinationViewController;
        controller.isFromMyGroupsScreen = YES;
    }
}

- (void)hideKeyboard
{
    [self.addGroupTextField resignFirstResponder];
    for (int i = 0; i < [UserData instance].taskSets.count; i++) {
        TaskSetCell *cell = (TaskSetCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell.nameTextField resignFirstResponder];
    }
}

#pragma mark- UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [UserData instance].taskSets.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [UserData instance].taskSets.count) {
        NSString *CELL_IDENTIFIER = @"buyTaskSetCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        return cell;
    } else if (indexPath.row == [UserData instance].taskSets.count) {
        NSString *CELL_IDENTIFIER = @"addTaskSetCell";
        AddTaskGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        
        if (cell == nil)
            cell = [[AddTaskGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        self.addGroupTextField = cell.textField;
        [self setupGestureRecognizers];
        
        return cell;
    } else {
        NSString *CELL_IDENTIFIER = @"taskSetCell";
        TaskSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        
        if (cell == nil)
            cell = [[TaskSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        
        ReminderGroup *taskSet = [[UserData instance].taskSets objectAtIndex:indexPath.row];
        cell.nameLabel.text = taskSet.name;
        cell.nameTextField.text = taskSet.name;
        
        cell.nameLabel.hidden = self.isEditing;
        cell.deleteButton.hidden = ! self.isEditing;
        cell.nameTextField.hidden = ! self.isEditing;
        
        cell.deleteButton.tag = indexPath.row;
        cell.nameTextField.tag = indexPath.row;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!self.isEditing)
    {
        if(indexPath.row <[UserData instance].taskSets.count)
        {
            [UserData instance].reminderGroup = [[UserData instance].taskSets objectAtIndex:indexPath.row];
//             [self performSegueWithIdentifier: SEGUE_GROUP_DETAILS sender:self];
            
        }
    }

}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    }
}

#pragma mark- Actions

- (IBAction)DoneButtonPressed
{
     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonPressed
{
    self.isEditing = ! self.isEditing;
    
    NSString *title = self.isEditing?@"Save":@"Edit";
    [self.editButton setTitle:title forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (IBAction)addGroupButtonPressed
{
    NSString *groupName = [self.addGroupTextField.text lowercaseString];
    BOOL isduplicate = NO;
    NSString *noGroup=@"NO Group";
    BOOL isNoGroup = YES;
    for(int i=0;i< [UserData instance].taskSets.count; i++)
    {
        NSString *groupNames=[((ReminderGroup *)[[UserData instance].taskSets objectAtIndex:i]).name lowercaseString];
        if([groupName isEqualToString:groupNames] || ([groupName isEqualToString:[noGroup lowercaseString]] && isNoGroup))
        {
            if(isNoGroup && !([[groupName lowercaseString]isEqualToString:groupNames]))
            {
                isNoGroup=NO;
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Group"
                                                                   message:[NSString stringWithFormat:@"The Group Name \"%@\" is reserved for internal use only, please select a different group name.",groupName]
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                theAlert.tag = duplicateAlert;
                [theAlert show];
                
            }
            isduplicate=1;
            if(isNoGroup)
            {
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Group"
                                                                   message:[NSString stringWithFormat:@"Group \"%@\" already exists. Please enter another name",groupName]
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                theAlert.tag = duplicateAlert;
                [theAlert show];
            }
        }
    }
    if(!isduplicate)
    {
        if (groupName.length > 0) {
            ReminderGroup *taskSet = [[ReminderGroup alloc] init];
            taskSet.name = self.addGroupTextField.text ;
            taskSet.user = [PFUser currentUser];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [taskSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (succeeded) {
                    NSMutableArray *mutableTaskSets = [[UserData instance].taskSets mutableCopy];
                    [mutableTaskSets addObject:taskSet];
                    [UserData instance].taskSets = [mutableTaskSets copy];
                }
                
                [self.tableView reloadData];
            }];
        }
        isduplicate = NO;
    }
    self.addGroupTextField.text = @"";
    [self hideKeyboard];
}

- (IBAction)deleteGroupButtonPressed:(UIButton *)button
{
    NSInteger indexToDelete = button.tag;
    self.taskSetToDelete = [[UserData instance].taskSets objectAtIndex:indexToDelete];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Reminder Group?" message:[NSString stringWithFormat:@"Deleting this  \"%@\" reminder Group will also delete all reminders currently associated within. This cannot be undone.Would you like to continue and delete this group and all its reminders?",((ReminderGroup *)([[UserData instance].taskSets objectAtIndex:indexToDelete])).name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
    self.alertType = deleteTaskSet;
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    NSInteger taskSetToChange = textField.tag;
    ReminderGroup *taskSet = [[UserData instance].taskSets objectAtIndex:taskSetToChange];
    taskSet.name = textField.text;
    [taskSet saveEventually];
}

#pragma mark- UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == deleteTaskSet && buttonIndex == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self.taskSetToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (succeeded) {
                NSMutableArray *mutableTaskSets = [[UserData instance].taskSets mutableCopy];
                [mutableTaskSets removeObject:self.taskSetToDelete];
                [UserData instance].taskSets = [mutableTaskSets copy];
                
                [self performDeleteAllTasksWithTaskSetId:self.taskSetToDelete];
            }else{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            
            [self.tableView reloadData];
        }];
    }
    
    self.alertType = none;
}

#pragma mark- Networking

- (void)performLoadTaskSets
{
    PFQuery *query = [PFQuery queryWithClassName:[ReminderGroup parseClassName]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    if (![UserData instance].isHavingActiveSubscription) {
        [query whereKey:@"isSubscribed" notEqualTo:[NSNumber numberWithBool:YES]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"TASK SETS LOADED");
        if ([objects.firstObject isKindOfClass:[ReminderGroup class]])
            [UserData instance].taskSets = objects;
        
        [self.tableView reloadData];
    }];
}

-(void)performDeleteAllTasksWithTaskSetId:(ReminderGroup *)taskSet
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    [query whereKey:@"reminderGroup" equalTo:taskSet];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        NSLog(@"TASKS LOADED");
        if (! error) {
          /*  for (Reminder *task in objects) {
                [task deleteEventually];
            }*/
            [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                NSMutableArray *mutableFilterGroups = [[UserData instance].filterGroups mutableCopy];
                if ([[UserData instance].filterGroups containsObject:taskSet.objectId]) {
                    [mutableFilterGroups removeObject:taskSet.objectId];
                    [UserData instance].filterGroups = [mutableFilterGroups copy];
                    [UserData instance].isFilteringGroups = (mutableFilterGroups.count > 0);
                }
            }];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }

    }];
    
   
}


#pragma mark- Keyboard handling
/*
- (void)keyboardWillShow:(NSNotification*)notification
{
    currentKeyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    [self setViewMovedUp];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    currentKeyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    [self setViewMovedUp];
}

-(void)setViewMovedUp
{
    BOOL isKeyboardUp = self.view.frame.size.height < ORIGINAL_VIEW_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if ( ! isKeyboardUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.size.height -= currentKeyboardHeight;
    } else {
        // revert back to the normal state.
        rect.size.height += currentKeyboardHeight;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
*/
#pragma mark- end of lifecycle methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
