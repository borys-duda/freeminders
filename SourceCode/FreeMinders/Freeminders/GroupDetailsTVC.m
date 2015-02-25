//
//  GroupDetailsTVC.m
//  Freeminders
//
//  Created by Vegunta's on 06/09/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "GroupDetailsTVC.h"
#import "UserData.h"
#import "ReminderGroup.h"
#import "Reminder.h"

//#define NSLog( a ) ""
//#define NSLog( a, b )

@interface GroupDetailsTVC ()

@property (strong,nonatomic)  UIView *actionMenu;
@property (weak,nonatomic) IBOutlet UILabel *groupTitleLabel;
@property (weak,nonatomic) IBOutlet UILabel *groupTypeabel;
@property (weak,nonatomic) IBOutlet UILabel *numberOfMindersLabel;
@property (weak,nonatomic) IBOutlet UILabel *numberOfTriggersLabel;
@property (weak,nonatomic) IBOutlet UILabel *numberOfStepsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *numberOfMindersImageView;
@property (weak, nonatomic) IBOutlet UIImageView *numberOfTriggersImageView;
@property (weak, nonatomic) IBOutlet UIImageView *numberOfStepsImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForgroupTitletextviewConstriant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForTextViewConstriant;


@property (weak,nonatomic) IBOutlet UITextView *groupTitleTextView;
@property (weak,nonatomic) IBOutlet UILabel *discriptionOfGroupLabel;
@property (weak,nonatomic) IBOutlet UITextView *discriptionOfGroupTextView;

@property (nonatomic) BOOL isEditing;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic)UILabel *notificationLabel;
@property (strong, nonatomic)UILabel *loctionLabel;
@property (strong,nonatomic) ReminderGroup *reminderGroupCancelValues;





@end

@implementation GroupDetailsTVC

int GROUPTITLE_SECTION=0,GROUPTYPE_SECTION=1,GROUPDISCRIPTION_SECTION=2,GROUPSAMPLEMINDERS_SECTION=3;
NSString  *SEGU_NOTIFICATION_SEREEN=@"notificationScreen",*SEGU_LOCATION_SEREEN=@"locationScreen";

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
    [self setUpUi];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    self.reminderGroupCancelValues = [[UserData instance].reminderGroup copy];
    self.discriptionOfGroupTextView.autocorrectionType=UITextAutocorrectionTypeNo;
    self.groupTitleTextView.autocapitalizationType=UITextAutocorrectionTypeNo;

}
- (void)viewWillDisappear:(BOOL)animated {
    [_actionMenu removeFromSuperview];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpUiActionMenu];
    
}
-(void)setUpUi
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self action:@selector(pickerCancelled)];
    [pickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, spaceItem, doneButton, nil] animated:NO];
    self.discriptionOfGroupTextView.inputAccessoryView=pickerToolbar;
    self.groupTitleTextView.inputAccessoryView=pickerToolbar;

    self.groupTitleTextView.text= [UserData instance].reminderGroup.name;
    self.numberOfMindersLabel.text= [NSString stringWithFormat:@"%d Reminders",(int)([UserData instance].reminderGroup.tasksIngroup.count)];
    //(int)(((ReminderGroup *)([UserData instance].GroupName)).tasksIngroup.count)
    self.groupTypeabel.text=[UserData instance].reminderGroup.typeOfTheGroup;
    self.numberOfStepsLabel.text= [NSString stringWithFormat:@"%d steps",(int)([UserData instance].reminderGroup.numberOfSteps)];
    self.numberOfTriggersLabel.text= [NSString stringWithFormat:@"%d triggers",(int)([UserData instance].reminderGroup.numberOfTriggers)];
}

-(void)hideKeyBoard
{
    [self.groupTitleTextView resignFirstResponder];
    [self.discriptionOfGroupTextView resignFirstResponder];
}
-(void)setUpUiActionMenu
{
    self.actionMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 70)];
    self.actionMenu.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = CGRectMake(0, 24, 120, 35);
    CGPoint center;
    
    UILabel *groupResetLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 15)];
    groupResetLabel.text=@"GROUP RESET";
    groupResetLabel.font=[UIFont systemFontOfSize:14];
    groupResetLabel.textColor=[UIColor blackColor];
    [self.actionMenu addSubview:groupResetLabel];
    
    UIButton *notificationButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 24, 158, 35)];
    center = notificationButton.center;
    notificationButton.frame = rect;
    notificationButton.center = center;
    notificationButton.layer.borderWidth = 1.0f;
    notificationButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
    notificationButton.layer.cornerRadius = 10;
    [notificationButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [notificationButton setTitle:@"Notification" forState:UIControlStateNormal];
    [notificationButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
    [notificationButton addTarget:self action:@selector(notificationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:notificationButton];
    
    UIButton *locationButton =[[UIButton alloc]initWithFrame:CGRectMake(160, 24, 158, 35)];
    rect = CGRectMake(160, 24, 120, 35);
    center = locationButton.center;
    locationButton.frame = rect;
    locationButton.center = center;
    locationButton.layer.borderWidth = 1.0f;
    locationButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
    locationButton.layer.cornerRadius = 10;
    [locationButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [locationButton setTitle:@"Location" forState:UIControlStateNormal];
    [locationButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionMenu addSubview:locationButton];
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect actionmenurect = _actionMenu.frame;
    actionmenurect.origin.y = mainWindow.frame.size.height - actionmenurect.size.height;
    _actionMenu.frame = actionmenurect;
    [mainWindow addSubview: _actionMenu];
    NSLog(@"FRAME : %@",NSStringFromCGRect(mainWindow.frame));
    NSLog(@"FRAME : %@",NSStringFromCGRect(self.view.frame));
    
}
-(void)notificationButtonAction:(UIButton *)sender
{
    sender.selected=!sender.selected;
    if(sender.selected)
        self.notificationLabel.textColor=COLOR_FREEMINDER_BLUE;
    [self performSegueWithIdentifier: SEGU_NOTIFICATION_SEREEN sender:self];
}
-(void)locationButtonAction:(UIButton *)sender
{
    sender.selected=!sender.selected;
    if(sender.selected)
        self.loctionLabel.textColor=COLOR_FREEMINDER_BLUE;
    [self performSegueWithIdentifier: SEGU_LOCATION_SEREEN sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if(!self.isEditing)
    {
        if(section == GROUPTITLE_SECTION)
        {
            return [self heightForTheGroupTitle];
        }
        else if (section==GROUPTYPE_SECTION)
        {
            return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GROUPTYPE_SECTION]];
        }
        else if (section==GROUPDISCRIPTION_SECTION)
        {
            return [self heightForTheGroupDescription];
        }
        else if(section == GROUPSAMPLEMINDERS_SECTION)
        {
            return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GROUPSAMPLEMINDERS_SECTION]];
        }
        
    }
    else{
        CGFloat hgt = 60;
        if(section == 0)
        {
            [self.groupTitleTextView setFrame:CGRectMake(18, 0, 280, hgt)];
            self.heightForgroupTitletextviewConstriant.constant=hgt;
            return hgt;
        }
        else if (section == 1)
        {
            hgt = 130;
            [self.discriptionOfGroupTextView setFrame:CGRectMake(18, 0, 280, hgt)];
             self.heightForTextViewConstriant.constant=hgt;
             return hgt;
        }
    }
    return 0;
}
-(CGFloat)heightForTheGroupTitle
{
    NSString *string=[UserData instance].reminderGroup.name;
    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName: @"Helvetica" size: 15]];
    txtSz.width +=20;
    CGRect lblFrame = CGRectMake(18,0, txtSz.width, txtSz.height+20);
    int lineCount = txtSz.width/260;
    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
    strCount /= [@"\n" length];
    if(txtSz.width > 260)
    {
        lineCount += 1;
        lblFrame = CGRectMake(18,0, 260, txtSz.height*(lineCount+strCount+1));
    }
    [self.groupTitleTextView setFrame:CGRectMake(18, 0, 280, lblFrame.size.height+20)];
    self.heightForgroupTitletextviewConstriant.constant= lblFrame.size.height + 20;
    return lblFrame.size.height+ 10;
}
-(CGFloat)heightForTheGroupDescription
{
    NSString *string=[UserData instance].reminderGroup.desc;
    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName: @"Helvetica" size: 15 ]];
    txtSz.width +=20;
    CGRect lblFrame = CGRectMake(18,0, txtSz.width, txtSz.height+20);
    int lineCount = txtSz.width/260;
    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
    strCount /= [@"\n" length];
//    if(txtSz.width > 260)
//    {
        lineCount += 1;
        lblFrame = CGRectMake(18,0, 260, txtSz.height*(lineCount+strCount+1));
//    }
    [self.discriptionOfGroupTextView setFrame:CGRectMake(18, 0, 280, lblFrame.size.height)];
    self.heightForTextViewConstriant.constant= lblFrame.size.height + 10;
    return lblFrame.size.height + 120;

}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if(!self.isEditing)
    {
        if(section == GROUPTITLE_SECTION)
        {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        }
        else if (section==GROUPTYPE_SECTION)
        {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        }
        else if (section==GROUPDISCRIPTION_SECTION)
        {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        }
        else if(section == GROUPSAMPLEMINDERS_SECTION)
        {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        }
        
    }
    else{
        if(section == 0)
        {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GROUPTITLE_SECTION]];
        }
        else if (section == 1)
        {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GROUPDISCRIPTION_SECTION]];
        }
    }
    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if(!self.isEditing)
    {
        if(section == GROUPTITLE_SECTION)
        {
            return [super tableView:tableView heightForHeaderInSection:GROUPTITLE_SECTION];
        }
        else if (section==GROUPTYPE_SECTION)
        {
            return [super tableView:tableView heightForHeaderInSection:GROUPTYPE_SECTION];;
        }
        else if (section==GROUPDISCRIPTION_SECTION)
        {
            return [super tableView:tableView heightForHeaderInSection:GROUPDISCRIPTION_SECTION];
        }
        else if(section == GROUPSAMPLEMINDERS_SECTION)
        {
            return [super tableView:tableView heightForHeaderInSection:GROUPSAMPLEMINDERS_SECTION];
        }
        
    }
    else{
        if(section == 0)
        {
            return [super tableView:tableView heightForHeaderInSection:GROUPTITLE_SECTION];
        }
        else if (section == 1)
        {
            return [super tableView:tableView heightForHeaderInSection:GROUPDISCRIPTION_SECTION];
        }
        
    }
    return 0;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.isEditing)
    {
        return 2;
    }
    else{
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.isEditing)
    {
        if(section == 0)
        {
            return 1;
        }
        else if (section == 1)
        {
            return 1;
        }
    }
    else{
        if(section == GROUPTITLE_SECTION)
        {
            return 1;
        }
        else if (section==GROUPTYPE_SECTION)
        {
            return 1;
        }
        else if (section==GROUPDISCRIPTION_SECTION)
        {
            return 1;
        }
        else if(section == GROUPSAMPLEMINDERS_SECTION)
        {
            return [UserData instance].reminderGroup.tasksIngroup.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        
    }
    if(!self.isEditing)
    {
        if(indexPath.section == GROUPTITLE_SECTION)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
            CGFloat lblFrame=[self heightForTheGroupTitle];
            [self.groupTitleTextView setFrame:CGRectMake(18, 0, 280, lblFrame)];
            [self.groupTitleTextView setEditable:NO];
            [self.groupTitleTextView setScrollEnabled:NO];
            [self.groupTitleTextView setSelectable:NO];
            self.groupTitleTextView.text= [UserData instance].reminderGroup.name;
        }
        else if(indexPath.section == GROUPTYPE_SECTION)
        {
            cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
            
        }
        else if (indexPath.section == GROUPDISCRIPTION_SECTION)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
            CGFloat lblFrame=[self heightForTheGroupDescription];
            [self.discriptionOfGroupTextView setFrame:CGRectMake(18, 0, 280, lblFrame-120)];
            [self.discriptionOfGroupTextView setEditable:NO];
            [self.discriptionOfGroupTextView setScrollEnabled:NO];
            [self.discriptionOfGroupTextView setSelectable:NO];
            self.discriptionOfGroupTextView.text=[UserData instance].reminderGroup.desc;
            self.numberOfMindersImageView.hidden=self.isEditing;
            self.numberOfTriggersImageView.hidden=self.isEditing;
            self.numberOfStepsImageView.hidden=self.isEditing;
            self.numberOfMindersLabel.hidden=self.isEditing;
            self.numberOfStepsLabel.hidden=self.isEditing;
            self.numberOfTriggersLabel.hidden=self.isEditing;
            [self.tableView setScrollEnabled:YES];
            
        }
        else if (indexPath.section == GROUPSAMPLEMINDERS_SECTION)
        {
            cell.textLabel.text=((Reminder *)([[UserData instance].reminderGroup.tasksIngroup objectAtIndex:indexPath.row])).name;
            cell.textLabel.textColor = self.groupTitleTextView.textColor;
            cell.textLabel.font = self.groupTitleTextView.font;
        }
        return cell;
    }
    else{
        [self.tableView setScrollEnabled:NO];
      if(indexPath.section == 0)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
            self.groupTitleTextView.text= [UserData instance].reminderGroup.name;
            [self.groupTitleTextView setEditable:YES];
            [self.groupTitleTextView setScrollEnabled:YES];
            [self.groupTitleTextView setSelectable:YES];
        }else if (indexPath.section == 1)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GROUPDISCRIPTION_SECTION]];
            self.discriptionOfGroupTextView.text=[UserData instance].reminderGroup.desc;
            [self.discriptionOfGroupTextView setEditable:YES];
            [self.discriptionOfGroupTextView setScrollEnabled:YES];
            [self.discriptionOfGroupTextView setSelectable:YES];
            self.numberOfMindersImageView.hidden=self.isEditing;
            self.numberOfTriggersImageView.hidden=self.isEditing;
            self.numberOfStepsImageView.hidden=self.isEditing;
            self.numberOfMindersLabel.hidden=self.isEditing;
            self.numberOfStepsLabel.hidden=self.isEditing;
            self.numberOfTriggersLabel.hidden=self.isEditing;
        }
        
        return cell;
        
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(!self.isEditing)
    {
        if(section == GROUPTITLE_SECTION)
        {
            return [super tableView:tableView titleForHeaderInSection:GROUPTITLE_SECTION];
        }
        else if (section==GROUPTYPE_SECTION)
        {
            return [super tableView:tableView titleForHeaderInSection:GROUPTYPE_SECTION];
        }
        else if (section==GROUPDISCRIPTION_SECTION)
        {
            return [super tableView:tableView titleForHeaderInSection:GROUPDISCRIPTION_SECTION];
        }
        else if(section == GROUPSAMPLEMINDERS_SECTION)
        {
            return [super tableView:tableView titleForHeaderInSection:GROUPSAMPLEMINDERS_SECTION];
        }
        
    } else{
        if(section == 0)
        {
            return [super tableView:tableView titleForHeaderInSection:GROUPTITLE_SECTION];
        }
        else if (section == 1)
        {
            return [super tableView:tableView titleForHeaderInSection:GROUPDISCRIPTION_SECTION];
        }
        
    }
    return @"";
}

- (IBAction)cancelButtonPressed
{
    [[UserData instance].reminderGroup copyCancel:self.reminderGroupCancelValues];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)editButtonPressed
{
    self.isEditing = ! self.isEditing;
    if([self.editButton.titleLabel.text isEqualToString:@"Save"])
    {
        ((ReminderGroup*)([UserData instance].reminderGroup)).desc = self.discriptionOfGroupTextView.text;
        ((ReminderGroup*)([UserData instance].reminderGroup)).name = self.groupTitleTextView.text;
        [((ReminderGroup*)([UserData instance].reminderGroup)) saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded)
            {
                 self.reminderGroupCancelValues = [[UserData instance].reminderGroup copy];
                [self.tableView reloadData];
            }
            else{
                NSLog(@"Error is occured  %@",error);
            }
        }];
    }
    NSString *title = self.isEditing?@"Save":@"Edit";
    _actionMenu.hidden=self.isEditing?1:0;
    [self.editButton setTitle:title forState:UIControlStateNormal];
    [self.tableView reloadData];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

-(void)pickerDone
{
    ((ReminderGroup*)([UserData instance].reminderGroup)).desc = self.discriptionOfGroupTextView.text;
    ((ReminderGroup*)([UserData instance].reminderGroup)).name = self.groupTitleTextView.text;
    [self hideKeyBoard];
    [self.tableView reloadData];
}
-(void)pickerCancelled
{

    [[UserData instance].reminderGroup copyCancel:self.reminderGroupCancelValues];
    [self hideKeyBoard];
    [self.tableView reloadData];

}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.groupTitleTextView)
        return [text rangeOfString:@"\n"].location == NSNotFound;
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



@end
