//
//  AddEditTaskTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "AddEditTaskTVC.h"
#import "Reminder.h"
#import "ReminderGroup.h"
#import "ReminderStep.h"
#import "UserData.h"
#import "Utils.h"
#import "EditStep.h"

@interface AddEditTaskTVC ()
@property (strong,nonatomic)  UIView *actionMenu;
@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *taskGroupTextField;
@property (strong, nonatomic) UITextView *taskNotesTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *detailsStepsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *importantSwitch;
@property (weak, nonatomic) IBOutlet UIButton *triggerWeatherButton;
@property (weak, nonatomic) IBOutlet UIButton *triggerLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *triggerDatetimeButton;
@property (weak, nonatomic) IBOutlet UILabel *triggerWeatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *triggerLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *triggerDatetimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *addStepTextField;

@property (weak, nonatomic) IBOutlet UIButton *localNotificationButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *localNotificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *noTriggerButton;
@property (weak, nonatomic) IBOutlet UILabel *noTriggerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notesViewHeightConstraint;



@property (strong, nonatomic) UIButton *upButton;
@property (strong, nonatomic) UIButton *downButton;

@property (strong, nonatomic) Reminder *task;
@property (strong, nonatomic) NSMutableArray *taskSets;
@property  (nonatomic) NSInteger editingRow;


@property (nonatomic) AlertType alertType;

@end

@implementation AddEditTaskTVC

@synthesize isFromSteps;

NSInteger SWITCH_DETAILS_INDEX = 0;
NSInteger SECTION_SWITCH = 0, SECTION_DETAILS = 1, SECTION_TRIGGERS = 2, SECTION_STEPS = 3, SECTION_NOTIFCATION = 4;
NSString *SEGUE_WEATHER_TRIGGER = @"weather", *SEGUE_LOCATION_TRIGGER = @"location",
*SEGUE_DATETIME_TRIGGER = @"datetime",*SEGU_EDITSTEP=@"StepEditor",*SEGU_EMAIL_EDIT=@"EmailEditScreen",
*SEGU_EMAIL_EDIT_BEFORE_PRCHASE=@"PurchaseScreen";
UIPickerView *taskGroupPicker;

UIToolbar *textViewToolbar;
bool addtaskGroup;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [UserData instance].didChangeTrigger = NO;
    self.task = [UserData instance].task;
    self.taskNotesTextView=[[UITextView alloc] initWithFrame:CGRectMake(15, 0, 295 , 50)];
    self.taskNotesTextView.delegate=self;
    self.taskNotesTextView.autocorrectionType=UITextAutocorrectionTypeNo;
    self.taskNameTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    self.taskGroupTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    [Utils updateUserLocation];
    [self setupUI:YES];
    [self setupTaskSetNames];
    [self setupTextViewToolbar];
    if(isFromSteps)
    {
        self.detailsStepsSwitch.selectedSegmentIndex=1;
    }
    [self setUpUiActionMenu];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        [self setupUI:NO];
        [self.tableView reloadData];
}

- (void)setupUI:(BOOL)isFromViewLoad
{
    // TASK NAME
    self.taskNameTextField.text = self.task.name;
    
    // TASK GROUP
    self.taskGroupTextField.text = self.task.reminderGroup.name;//[Utils getTaskGroupNameForId:self.task.reminderGroupId].name;
    self.taskNotesTextView.text = self.task.note;
    taskGroupPicker = [[UIPickerView alloc] init];
    taskGroupPicker.delegate = self;
    taskGroupPicker.dataSource = self;
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                  target:self action:@selector(pickerCancelled)];
    [pickerToolbar setItems:[NSArray arrayWithObjects: spaceItem, doneButton,spaceItem, nil] animated:NO];
    self.taskGroupTextField.inputAccessoryView = pickerToolbar;
    [self.taskGroupTextField setInputView:taskGroupPicker];
    self.taskNameTextField.inputAccessoryView=pickerToolbar;
    self.taskNotesTextView.inputAccessoryView=pickerToolbar;
    [self.taskGroupTextField setEnabled:![UserData instance].task.isStoreTask];
    
    // TASK NOTES
    if (isFromViewLoad)
        self.taskNotesTextView.text = self.task.note;
    if (self.taskNotesTextView.text.length > 0) {
        self.taskNotesTextView.tag = 111;
      }else {
        self.taskNotesTextView.text = @"Enter Notes";
        self.taskNotesTextView.textColor = [UIColor lightGrayColor];
        self.taskNotesTextView.tag = 110;
    }
    // TITLE
    if (!self.task.user) // if no title, task is new
        self.navigationItem.title = @"Add Reminder";
    else
        self.navigationItem.title = @"Edit Reminder";
    
    // IMPORTANT SWITCH
    [self.importantSwitch setOn:self.task.isImportant];
    
    // local notifications, email
    [self.emailButton setImage:[UIImage imageNamed:@"add_task_email-gray.png"] forState:UIControlStateNormal];
    self.emailLabel.textColor = [UIColor lightGrayColor];
    [self.emailButton setBackgroundColor:[UIColor whiteColor]];
    self.emailLabel.backgroundColor = [UIColor whiteColor];
    
    [self.localNotificationButton setImage:[UIImage imageNamed:@"add_task_local-notification-gray.png"] forState:UIControlStateNormal];
    self.localNotificationLabel.textColor = [UIColor lightGrayColor];
    [self.localNotificationButton setBackgroundColor:[UIColor whiteColor]];
    self.localNotificationLabel.backgroundColor = [UIColor whiteColor];
    
    
    // TRIGGERS
    [self.triggerWeatherButton setImage:[UIImage imageNamed:@"add_task_weather_icon_inactive.png"] forState:UIControlStateNormal];
    self.triggerWeatherLabel.textColor = [UIColor lightGrayColor];
    [self.triggerWeatherButton setBackgroundColor:[UIColor whiteColor]];
    self.triggerWeatherLabel.backgroundColor = [UIColor whiteColor];
    
    [self.triggerLocationButton setImage:[UIImage imageNamed:@"add_task_location_icon_inactive.png"] forState:UIControlStateNormal];
    self.triggerLocationLabel.textColor = [UIColor lightGrayColor];
    [self.triggerLocationButton setBackgroundColor:[UIColor whiteColor]];
    self.triggerLocationLabel.backgroundColor = [UIColor whiteColor];
    
    [self.triggerDatetimeButton setImage:[UIImage imageNamed:@"add_task_date_time_icon_inactive.png"] forState:UIControlStateNormal];
    self.triggerDatetimeLabel.textColor = [UIColor lightGrayColor];
    [self.triggerDatetimeButton setBackgroundColor:[UIColor whiteColor]];
    self.triggerDatetimeLabel.backgroundColor = [UIColor whiteColor];
    
    [self.noTriggerButton setImage:[UIImage imageNamed:@"No-Trigger-gray.png"] forState:UIControlStateNormal];
    self.noTriggerLabel.textColor = [UIColor lightGrayColor];
    [self.noTriggerButton setBackgroundColor:[UIColor whiteColor]];
    self.noTriggerLabel.backgroundColor = [UIColor whiteColor];
    
    switch (self.task.triggerType) {
        case noTrigger:
            [self.noTriggerButton setImage:[UIImage imageNamed:@"No-Trigger-white.png"] forState:UIControlStateNormal];
            [self.noTriggerButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
            self.noTriggerLabel.backgroundColor = COLOR_FREEMINDER_BLUE;
            self.noTriggerLabel.textColor = [UIColor whiteColor];
            
            break;
            
        case weatherTrigger:
            [self.triggerWeatherButton setImage:[UIImage imageNamed:@"add_task_weather_icon_active.png"] forState:UIControlStateNormal];
            [self.triggerWeatherButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
            self.triggerWeatherLabel.backgroundColor = COLOR_FREEMINDER_BLUE;
            self.triggerWeatherLabel.textColor = [UIColor whiteColor];
            
            break;
            
        case locationTrigger:
             [self.triggerLocationButton setImage:[UIImage imageNamed:@"add_task_location_icon_active.png"] forState:UIControlStateNormal];
            [self.triggerLocationButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
            self.triggerLocationLabel.backgroundColor = COLOR_FREEMINDER_BLUE;
            self.triggerLocationLabel.textColor = [UIColor whiteColor];
            
            break;
            
        case datetimeTrigger:
            [self.triggerDatetimeButton setImage:[UIImage imageNamed:@"add_task_date_time_icon_active.png"] forState:UIControlStateNormal];
            [self.triggerDatetimeButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
            self.triggerDatetimeLabel.backgroundColor = COLOR_FREEMINDER_BLUE;
            self.triggerDatetimeLabel.textColor = [UIColor whiteColor];
            
            break;
            
        default:
            break;
    }
    
    if(self.task.isNotificationEnable)
    {
        [self.localNotificationButton setImage:[UIImage imageNamed:@"add_task_local-notification-white.png"] forState:UIControlStateNormal];
        self.localNotificationLabel.textColor = [UIColor whiteColor];;
        [self.localNotificationButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
        self.localNotificationLabel.backgroundColor = COLOR_FREEMINDER_BLUE;
       
    }
    if(self.task.userContacts.count)
    {
        [self.emailButton setImage:[UIImage imageNamed:@"add_task_email-white.png"] forState:UIControlStateNormal];
        self.emailLabel.textColor = [UIColor whiteColor];;
        [self.emailButton setBackgroundColor:COLOR_FREEMINDER_BLUE];
        self.emailLabel.backgroundColor = COLOR_FREEMINDER_BLUE;
    }
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:SEGU_EDITSTEP]){
        EditStep *controller = (EditStep *)segue.destinationViewController;
        controller.indexPathRow = self.editingRow;
    }
}
-(void)setUpUiActionMenu
{
    self.actionMenu = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.actionMenu.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = CGRectMake(0, 7, 120, 35);
    CGPoint center;
    
    UIButton *reOrederButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 5, 320, 35)];
    center = reOrederButton.center;
    reOrederButton.frame = rect;
    reOrederButton.center = center;
    reOrederButton.layer.borderWidth = 1.0f;
    reOrederButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
    reOrederButton.layer.cornerRadius = 10;
    [reOrederButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [reOrederButton setTitle:@"Reorder" forState:UIControlStateNormal];
    [reOrederButton setTitle:@"Done" forState:UIControlStateSelected];
    [reOrederButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
    [reOrederButton addTarget:self action:@selector(reOrederButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:reOrederButton];
    
//    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
//    CGRect actionmenurect = _actionMenu.frame;
//    actionmenurect.origin.y = mainWindow.frame.size.height - actionmenurect.size.height;
//    _actionMenu.frame = actionmenurect;
//    [mainWindow addSubview: _actionMenu];
//    NSLog(@"FRAME : %@",NSStringFromCGRect(mainWindow.frame));
//    NSLog(@"FRAME : %@",NSStringFromCGRect(self.view.frame));
    
}
-(void)reOrederButtonAction:(UIButton *)sender
{
    if(!sender.selected)
    {
        sender.selected = !sender.selected;
        [self.tableView setEditing:YES animated:YES];
    }
    else
    {
        sender.selected = !sender.selected;
        [self.tableView setEditing:NO animated:NO];
    }
    [self.tableView reloadData];
}
//- (void)setupGestures
//{
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:tap];
//}

- (void)setupTaskSetNames
{
    self.taskSets = [[NSMutableArray alloc] initWithObjects:@"(None)", nil];
    for (ReminderGroup *taskSet in [UserData instance].taskSets) {
        [self.taskSets addObject:taskSet];
    }
    [self.taskSets addObject:@"+ Add Group"];
}

- (void)setupTextViewToolbar
{
    textViewToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(textViewDonePressed)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    UIImage *downImage = [UIImage imageNamed:@"steps-Editing-Down@2x.png"];// set your image Name here
//    self.downButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.downButton setImage:downImage forState:UIControlStateNormal];
//    [self.downButton addTarget:self  action:@selector(textViewDownEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//     self.downButton.frame = CGRectMake(0, 0, 25, 25);
//    UIBarButtonItem *downEditButton = [[UIBarButtonItem alloc] initWithCustomView:self.downButton];
//
//    UIImage *upImage = [UIImage imageNamed:@"steps-Editing-Up@2x.png"];// set your image Name here
//     self.upButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.upButton setImage:upImage forState:UIControlStateNormal];
//    [self.upButton addTarget:self  action:@selector(textViewUpEditButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//     self.upButton.frame = CGRectMake(0, 0, 25, 25);
//    UIBarButtonItem *upEditButton = [[UIBarButtonItem alloc] initWithCustomView:self.upButton];
    
   
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered
                                                                    target:self action:@selector(textViewdeleteButtonpressed)];
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                  target:self action:@selector(pickerCancelled)];
    [textViewToolbar setItems:[NSArray arrayWithObjects:deleteButton,spaceItem,doneButton, nil] animated:NO];
}

- (void)hideKeyboard
{
    [self.taskNameTextField resignFirstResponder];
    [self.taskGroupTextField resignFirstResponder];
    [self.taskNotesTextView resignFirstResponder];

}

- (void)showAlertForAddingTaskGroup
{
    [self.taskGroupTextField resignFirstResponder];
// None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
    if ([UIAlertController class]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Group" message:@"Add a new group for this reminder" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
            [textField becomeFirstResponder];
        }];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Add"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 addtaskGroup=0;
                                 bool isduplicate=0;
                                 BOOL isNoGroup = YES;
                                 NSString *noGroup=@"NO Group";
                                 NSString *groupName = [[alert.textFields objectAtIndex:0] text] ;
                                 for(int i=0;i < [UserData instance].taskSets.count; i++)
                                 {
                                     NSString *groupNames=[((ReminderGroup *)[[UserData instance].taskSets objectAtIndex:i]).name lowercaseString];
                                     if([[groupName lowercaseString]isEqualToString:groupNames]||([[groupName lowercaseString]isEqualToString:[noGroup lowercaseString]] && isNoGroup))
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
                                     isduplicate=0;
                                     ReminderGroup *newTaskSet = [[ReminderGroup alloc] init];
                                     newTaskSet.name = groupName;
                                     newTaskSet.user = [PFUser currentUser];
                                     
                                     [self performSaveTaskSet:newTaskSet];
                                 }
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Group" message:@"Add a new group for this reminder" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
         alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [alert show];
    }
}

#pragma mark- UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.taskNotesTextView) {
        if([textView.text isEqualToString:@"Enter Notes"])
        {
          textView.text=@"";
        }
        if(self.view.frame.size.height > 480)
        {
            if(textView.frame.size.height < 150)
            {
                [self.tableView setContentOffset:CGPointMake(0, 125) animated:YES];
            }
            else{
                
                [self.tableView setContentOffset:CGPointMake(0, 170) animated:YES];
            }
        } else{
            
            if(textView.frame.size.height < 100)
            {
                [self.tableView setContentOffset:CGPointMake(0, 140) animated:YES];
            }
            else{
                
                [self.tableView setContentOffset:CGPointMake(0, 170) animated:YES];
            }
        }
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.taskNotesTextView) {
        if(textView.tag == 110) {
            textView.text = @"";
            textView.textColor = [UIColor darkGrayColor];
            textView.tag = 111;
        }
        if([text isEqual:@"\n"])
            [textView setContentOffset:CGPointMake(0, textView.contentSize.height)];
        }
    
    return YES;
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if((textView == self.taskNotesTextView) && [textView.text length] == 0)
    {
        textView.text = @"Enter Notes";
        textView.textColor = [UIColor lightGrayColor];
        textView.tag = 110;
       
    }else if(([textView.text length] > 0)&&(textView == self.taskNotesTextView))
    {
        self.task.note=textView.text;
    
    }
    if( textView == self.taskNotesTextView)
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
  
         [self.tableView reloadData];
    
}

#pragma mark- UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.taskNameTextField) {
         [UserData instance].task.name = self.taskNameTextField.text;
       }
    
}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField ==self.taskNameTextField) {
//        [textField resignFirstResponder];
//        return YES;
//    }
//    return NO;
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [string rangeOfString:@"\n"].location == NSNotFound;
}

#pragma mark- UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_SWITCH) {
        return 1;
    }
    
    if (self.detailsStepsSwitch.selectedSegmentIndex == SWITCH_DETAILS_INDEX) {
        if (section == SECTION_STEPS) {
            return 0;
        } else {
            return [super tableView:tableView numberOfRowsInSection:section];
        }
    } else { // STEPS
        if (section == SECTION_STEPS) {
            return 1 + [UserData instance].task.reminderSteps.count;
        } else {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.detailsStepsSwitch.selectedSegmentIndex == 0) {
        if (section == SECTION_TRIGGERS || section == SECTION_DETAILS || section == SECTION_NOTIFCATION ) {
            return [super tableView:tableView heightForHeaderInSection:section];
        } else {
            return 0.0;
        }
    } else {
        return 0.0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.detailsStepsSwitch.selectedSegmentIndex == 1) {
        if([UserData instance].task.reminderSteps.count > 1)
        {
        if(section==SECTION_STEPS)
        {
            return 50;
        }
        else{
            return 0;
        }
        }else{
            return 0;
        }
    }else{
        
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.detailsStepsSwitch.selectedSegmentIndex == 1) {
        if([UserData instance].task.reminderSteps.count > 1)
        {
        if(section==SECTION_STEPS)
        {
            return self.actionMenu;
        }
        else{
            return nil;
        }
        }
        else{
            return nil;
        }
    }else{
        return nil;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_SWITCH) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    if (self.detailsStepsSwitch.selectedSegmentIndex == 0) { // details
        if (indexPath.section == SECTION_STEPS) {
            return 0.0;
        } else if(indexPath.section == SECTION_DETAILS){
            if(indexPath.row == 2){
                return [self heightForNotesCellAtIndexPath:indexPath];
            }
            else{
                return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:SECTION_DETAILS]];
            }
            
        }else if (indexPath.section == SECTION_TRIGGERS){
            if ([UserData instance].task.isDependentOnParent) {
                return [self heightFortriggerCellAtIndexPath:indexPath];
            }
            else{
                return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:SECTION_TRIGGERS]];
            }
        }else{
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    } else { // steps
        if (indexPath.section == SECTION_STEPS) {
            if (indexPath.row > 0) {
                return [self heightForStepCellAtIndexPath:indexPath];
            } else {
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        } else {
            return 0.0;
        }
    }
}
-(CGFloat)heightFortriggerCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [NSString stringWithFormat:@"This reminder is dependent upon the completion of the reminder titled %@ before it will become scheduled.",[Utils getParentReminderNames:[UserData instance].task]];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 0, 295, 55)];
    textView.text = string;
    textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
    [textView sizeToFit];
    float hgt = textView.frame.size.height;
    return hgt;
}
- (CGFloat)heightForNotesCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *note = [UserData instance].task.note;
    if(self.view.frame.size.height > 480)
    {
    if(note.length > 0){
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 0, 295, 55)];
        textView.text = self.task.note;
        textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
        [textView sizeToFit];
        float hgt = textView.frame.size.height + 18;
     
        if(hgt < 55)
            return 55;
        else if(hgt < 235)
            return hgt;
        else
            return 235;
    }
    else
    {
        return 55;
    }
    }else{
        if(note.length > 0){
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 0, 295, 55)];
            textView.text = self.task.note;
            textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
            [textView sizeToFit];
            float hgt = textView.frame.size.height + 18;
            
            if(hgt < 55)
                return 55;
            else if(hgt < 150)
                return hgt;
            else
                return 150;
        }
        else
        {
            return 55;
        }

    }
}

- (CGFloat)heightForStepCellAtIndexPath:(NSIndexPath *)indexPath
{
/*    ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:indexPath.row - 1];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    textView.text = step.name;
    textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
    [textView sizeToFit];
    
    return textView.frame.size.height;*/
    if(!self.tableView.isEditing)
    {
        ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:indexPath.row - 1];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        textView.text = [NSString stringWithFormat:@"%i. %@", (int) (indexPath.row),step.name];
        textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
        [textView sizeToFit];
        
        return textView.frame.size.height;
    }
    else{
        
        ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:indexPath.row - 1];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 265, 50)];
        textView.text = [NSString stringWithFormat:@"%i. %@", (int) (indexPath.row),step.name];
        textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
        [textView sizeToFit];
        
        return textView.frame.size.height;
    }
}


- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == SECTION_STEPS && row > 0) {
        static NSString *cellIdentifier = nil;//@"stepCell";
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [[cell.contentView viewWithTag:(row - 1)] removeFromSuperview];
        float heightForRow = [self heightForStepCellAtIndexPath:indexPath];
        CGRect frame = CGRectMake(15 , 0, 280 ,heightForRow);
        UILabel *stepLabel = [[UILabel alloc] initWithFrame:frame];
        ((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:row - 1]).order=[NSNumber numberWithInteger:row];
        stepLabel.text = [NSString stringWithFormat:@"%i. %@", (int) (row),((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:row - 1]).name];
        stepLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
        stepLabel.tag = (row - 1);
        stepLabel.numberOfLines=0;
        [stepLabel setUserInteractionEnabled:NO];
        if([UserData instance].task.reminderSteps.count > 1)
        {
            if(self.tableView.isEditing)
            {
                heightForRow = [self heightForStepCellAtIndexPath:indexPath];
                stepLabel.frame = CGRectMake(15, 0, 255, heightForRow);
             }
            stepLabel.textColor = !self.tableView.isEditing?[UIColor darkGrayColor]:COLOR_FREEMINDER_BLUE;
        }
        
        [cell addSubview:stepLabel];
        
        return cell;
    }else if (section == SECTION_TRIGGERS){
        if ([UserData instance].task.isDependentOnParent) {
            static NSString *cellIdentifier = nil;//@"stepCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.text = [NSString stringWithFormat:@"This reminder is dependent upon the completion of the reminder titled %@ before it will become scheduled.",[Utils getParentReminderNames:[UserData instance].task]];
            return cell;
        }
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (section == SECTION_DETAILS)
    {
        static NSString *cellIdentifier = nil;//@"stepCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if(indexPath.row==2)
        {
            if(self.task.note.length > 0)
            {
                int heightForRow = [self heightForNotesCellAtIndexPath:indexPath];
                CGRect frame =CGRectMake(15 , 0 , 295, heightForRow-10);
                self.taskNotesTextView.frame=frame;
                self.taskNotesTextView.text = self.task.note;
            }else
            {
                self.taskNotesTextView.text=@"Enter Notes";
            }
            self.taskNotesTextView.scrollEnabled=YES;
            self.taskNotesTextView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:15.0f];
            [cell addSubview:self.taskNotesTextView];
            
        }else if(indexPath.row==0)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:SECTION_DETAILS]];
            
        }
        else if(indexPath.row==1)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:SECTION_DETAILS]];
            
        }
        else if(indexPath.row==3)
        {
            cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:SECTION_DETAILS]];
            
        }
        return cell;
    }else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}


- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == SECTION_STEPS) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView
          editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath.section == SECTION_STEPS) {
        
        if(indexPath.row >0)
        {
            if (self.tableView.editing) {
                return 0;
            }
            return 0;
        }
    }
    return 0;
}
-(BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_STEPS) {
        if(indexPath.row > 0)
        {
            return YES;
        }
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == SECTION_STEPS && indexPath.row > 0) {
        self.editingRow=indexPath.row - 1;
        [UserData instance].step=[self.task.reminderSteps objectAtIndex:indexPath.row-1];
        [self performSegueWithIdentifier:SEGU_EDITSTEP sender:self];
 }
}
-(BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_STEPS) {
        if(indexPath.row > 0)
        {
            return YES;
        }
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
     toIndexPath:(NSIndexPath *)destinationIndexPath {
  
        ReminderStep *itemToMove = [[UserData instance].task.reminderSteps objectAtIndex:sourceIndexPath.row-1];
        NSMutableArray *stepsArr = [UserData instance].task.reminderSteps;
        [stepsArr removeObjectAtIndex:sourceIndexPath.row-1];
        [stepsArr insertObject:itemToMove atIndex:destinationIndexPath.row-1];
        [self.tableView reloadData];

    
}
-(NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    if (proposedDestinationIndexPath.section == sourceIndexPath.section) {
        if(proposedDestinationIndexPath.row==0)
        {
          return  proposedDestinationIndexPath=[NSIndexPath indexPathForRow:1 inSection:sourceIndexPath.section];
        }
        return proposedDestinationIndexPath;
    }else
    {
        return proposedDestinationIndexPath=[NSIndexPath indexPathForRow:1 inSection:sourceIndexPath.section];
    }
    return sourceIndexPath;
}
//-(void)textViewUpEditButtonPressed
//{
//    ReminderStep *itemToMove = [[UserData instance].task.reminderSteps objectAtIndex:editingRow];
//    NSMutableArray *stepsArr = [UserData instance].task.reminderSteps;
//    [stepsArr removeObjectAtIndex:editingRow];
//    [stepsArr insertObject:itemToMove atIndex:editingRow-1];
//    
//     [self hideKeyboard];
//     [self.tableView reloadData];
//}
//-(void)textViewDownEditButtonPressed
//{
//    
//    ReminderStep *itemToMove = [[UserData instance].task.reminderSteps objectAtIndex:editingRow];
//    NSMutableArray *stepsArr = [UserData instance].task.reminderSteps;
//    [stepsArr removeObjectAtIndex:editingRow];
//    [stepsArr insertObject:itemToMove atIndex:editingRow+1];
//    
//    [self hideKeyboard];
//    [self.tableView reloadData];
//
//}
#pragma mark- Actions
- (IBAction)cancelButtonPressed
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed
{
    if ([self isTaskValid]) {
        [self performSaveTask];
    } else {
        [Utils showSimpleAlertViewWithTitle:@"Reminder Name Missing" content:@"Please provide a reminder name before saving" andDelegate:self];
    }
}

- (IBAction)importantSwitchChanged:(UISwitch *)sender
{
    self.task.isImportant = sender.isOn;
}
-(void)isInactiveTask
{
   Reminder *task = [UserData instance].task;
    NSString *status;
    if (task.isActive
        && (task.lastNotificationDate || task.triggerType == noTrigger)
        && (! task.snoozedUntilDate || ! [Utils isDateInFuture:task.snoozedUntilDate])) {
        status = @"Active";
       
    } else if (task.isActive) {
        status = @"Scheduled";
        
    } else {
        status = @"Inactive";
    }
    if([status isEqualToString:@"Inactive"])
    {
        [self enableOrDisableTask:[UserData instance].task];
    }
    else{
        [self performSaveTask];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
   
}
- (IBAction)detailsStepsSwitchChanged:(UISegmentedControl *)sender
{
    [self.tableView reloadData];
}

- (IBAction)triggerButtonPressed:(UIButton *)sender
{
    if (sender == self.triggerWeatherButton) {
        /*        if ( ! [[UserData instance].task.weatherTriggers objectAtIndex:0] || ([UserData instance].task.weatherTriggers.count && [[[UserData instance].task.weatherTriggers objectAtIndex:0] isDataAvailable])) {
         self.task.triggerType = weatherTrigger;
         //            [[self.task.dateTimeTriggers objectAtIndex:0] deleteInBackground];
         //            self.task.dateTimeTriggers = nil;
         //            [[self.task.locationTriggers objectAtIndex:0] deleteInBackground];
         //            self.task.locationTriggers = nil;
         
         [self performSegueWithIdentifier:SEGUE_WEATHER_TRIGGER sender:self];
         }*/
        self.task.triggerType = weatherTrigger;
        [self performSegueWithIdentifier:SEGUE_WEATHER_TRIGGER sender:self];
    } else if (sender == self.triggerLocationButton) {
        /*        if ( ! [UserData instance].task.locationTriggers || ([UserData instance].task.locationTriggers.count && [[[UserData instance].task.locationTriggers objectAtIndex:0] isDataAvailable])) {
         self.task.triggerType = locationTrigger;
         //            [[self.task.dateTimeTriggers objectAtIndex:0] deleteInBackground];
         //            self.task.dateTimeTriggers = nil;
         //            [[self.task.weatherTriggers objectAtIndex:0] deleteInBackground];
         //            self.task.weatherTriggers = nil;
         
         [self performSegueWithIdentifier:SEGUE_LOCATION_TRIGGER sender:self];
         }*/
        self.task.triggerType = locationTrigger;
        [self performSegueWithIdentifier:SEGUE_LOCATION_TRIGGER sender:self];
    } else if (sender == self.triggerDatetimeButton) {
        /*        if ( ! [UserData instance].task.dateTimeTriggers || ([UserData instance].task.dateTimeTriggers.count && [[[UserData instance].task.dateTimeTriggers objectAtIndex:0] isDataAvailable])) {
         self.task.triggerType = datetimeTrigger;
         //            [[self.task.weatherTriggers objectAtIndex:0] deleteInBackground];
         //            self.task.weatherTriggers = nil;
         //            [[self.task.locationTriggers objectAtIndex:0] deleteInBackground];
         //            self.task.locationTriggers = nil;
         
         [self performSegueWithIdentifier:SEGUE_DATETIME_TRIGGER sender:self];
         }*/
        self.task.triggerType = datetimeTrigger;
        [self performSegueWithIdentifier:SEGUE_DATETIME_TRIGGER sender:self];
    }
    else if(sender== self.noTriggerButton)
    {
        [UserData instance].didChangeTrigger = YES;
        self.task.triggerType = noTrigger;
        if (self.task.weatherTriggers.count) {
            [[self.task.weatherTriggers objectAtIndex:0] deleteInBackground];
        }
        self.task.weatherTriggers = nil;
        if (self.task.locationTriggers.count) {
            [[self.task.locationTriggers objectAtIndex:0] deleteInBackground];
        }
        self.task.locationTriggers = nil;
        if (self.task.dateTimeTriggers.count) {
            [[self.task.dateTimeTriggers objectAtIndex:0] deleteInBackground];
        }
        self.task.dateTimeTriggers = nil;
    }
    
    
    [self setupUI:NO];
}
-(IBAction)notificationsButtonPressed:(UIButton *)sender
{
    BOOL ispurchased=[[[PFUser currentUser] objectForKey:@"hasUnlimitedEmail"] boolValue];
    
    if(sender==self.localNotificationButton)
    {
        self.task.isNotificationEnable = !self.task.isNotificationEnable;
        
    }else if (sender== self.emailButton)
    {
        if(ispurchased)
        {
            [self performSegueWithIdentifier:SEGU_EMAIL_EDIT sender:self];
            
        }else{
            
            [self performSegueWithIdentifier:SEGU_EMAIL_EDIT_BEFORE_PRCHASE sender:self];
        }
        
    }
    [self setupUI:NO];
    
}

- (IBAction)addStepButtonPressed
{
/*    if (self.addStepTextField.text.length > 0) {
        
        //        NSString *step = self.addStepTextField.text;
        NSMutableArray *mutableSteps = [[UserData instance].task.reminderSteps mutableCopy];
        if (! mutableSteps) mutableSteps = [[NSMutableArray alloc] init];
        ReminderStep *step = [[ReminderStep alloc] init];
        step.name = self.addStepTextField.text;
        step.isComplete = NO;
        step.order = [NSNumber numberWithInt:mutableSteps.count];
        [mutableSteps addObject:step];
        [UserData instance].task.reminderSteps = [mutableSteps mutableCopy];
        self.addStepTextField.text = @"";
        [self.tableView reloadData];
    }*/
    self.editingRow = -1;
//    [UserData instance].step = [[ReminderStep alloc] init];
    [self performSegueWithIdentifier:SEGU_EDITSTEP sender:self];
}

- (void)textViewDonePressed
{
}
- (void)pickerCancelled
{
    if([self.taskNameTextField isEditing])
    {
        self.taskNameTextField.text=[UserData instance].task.name;
    }else if(self.taskNotesTextView)
    {
        self.taskNotesTextView.text=[UserData instance].task.note;

    }
    [self hideKeyboard];
}

#pragma mark- UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.taskSets.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    id obj = [self.taskSets objectAtIndex:row];
    
    if ([obj isKindOfClass:NSString.class]) {
        return obj;
    } else if ([obj isKindOfClass:[ReminderGroup class]]) {
        ReminderGroup *taskSet = (ReminderGroup *) obj;
        return taskSet.name;
    } else {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    id obj = [self.taskSets objectAtIndex:row];
    if (row == 0) {
        NSLog(@"(None) selected");
        self.task.reminderGroup = nil;
        self.taskGroupTextField.text = @"";
    } else if ([obj isKindOfClass:[NSString class]]) {
        addtaskGroup=1;
        NSLog(@"Add new group");
        //        [self showAlertForAddingTaskGroup]; MOVED TO PICKER DONE
    } else if ([obj isKindOfClass:[ReminderGroup class]]) {
        
        ReminderGroup *taskSet = (ReminderGroup *) obj;
        self.task.reminderGroup = taskSet;
        self.taskGroupTextField.text = taskSet.name;
    }
}

- (void)pickerDone
{
    if([self.taskGroupTextField isEditing]){
        [self pickerView:taskGroupPicker didSelectRow:[taskGroupPicker selectedRowInComponent:0] inComponent:0];
        if ([taskGroupPicker selectedRowInComponent:0] != 0
            && [[self.taskSets objectAtIndex:[taskGroupPicker selectedRowInComponent:0]] isKindOfClass:[NSString class]]) {
            [self showAlertForAddingTaskGroup];
        }else{
            [self hideKeyboard];
        }
    }
    else{
       [self hideKeyboard];
    }
}

#pragma mark- UIAlertView delegate methods

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if(addtaskGroup) {
        @try {
            UITextField *textField = [alertView textFieldAtIndex:0];
            [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1];
        }
        @catch (NSException *exception) {
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"CLICK");
    if( addtaskGroup && buttonIndex == 1) {
        addtaskGroup=0;
        bool isduplicate=0;
        BOOL isNoGroup = YES;
        NSString *noGroup=@"NO Group";
        NSString *groupName = [[alertView textFieldAtIndex:0] text] ;
        for(int i=0;i < [UserData instance].taskSets.count; i++)
        {
            NSString *groupNames=[((ReminderGroup *)[[UserData instance].taskSets objectAtIndex:i]).name lowercaseString];
            if([[groupName lowercaseString]isEqualToString:groupNames]||([[groupName lowercaseString]isEqualToString:[noGroup lowercaseString]] && isNoGroup))
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
            isduplicate=0;
            ReminderGroup *newTaskSet = [[ReminderGroup alloc] init];
            newTaskSet.name = groupName;
            newTaskSet.user = [PFUser currentUser];
            
            [self performSaveTaskSet:newTaskSet];
        }
    }
    else if(![self isTaskValid] && buttonIndex==0 && !(alertView.tag== duplicateAlert))
    {
        if(self.detailsStepsSwitch.selectedSegmentIndex)
        {
            self.detailsStepsSwitch.selectedSegmentIndex=0;
            [self.tableView reloadData];
        }
       [self.taskNameTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    }
    else if (alertView.tag== duplicateAlert && buttonIndex==0)
    {
        
    }

    [self hideKeyboard];
}

- (void)enableOrDisableTask:(Reminder* )task
{
    task.isActive = ! task.isActive;
    task.lastNotificationDate = (task.isActive && task.triggerType == noTrigger)?[NSDate date]:nil;
    [self performSaveTask];
    
}

#pragma mark- Networking

- (void)performSaveTask
{
    [self hideKeyboard];
    if (! [[UserData instance].tasks containsObject:self.task]) {
        NSMutableArray *mutableTasks = [[NSMutableArray alloc] initWithArray:[UserData instance].tasks];
        [mutableTasks addObject:self.task];
        [UserData instance].tasks = [mutableTasks mutableCopy];
    }
    if (!self.task.isActive && [UserData instance].didChangeTrigger) {
        [self.task setEnable:YES];
    }
    self.task.name = self.taskNameTextField.text;
    self.task.user = [PFUser currentUser];
    self.task.note = ![self.taskNotesTextView.text isEqualToString:@"Enter Notes"]?self.taskNotesTextView.text:@"";
    if (self.task.triggerType == noTrigger)
           self.task.lastNotificationDate = [NSDate date];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     [self.task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [UserData instance].task = self.task;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [Utils showSimpleAlertViewWithTitle:@"Network Error" content:@"Reminder could not be saved, please connect to the internet and retry" andDelegate:self];
        }
    }];
}
- (void)performLoadTasks
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[Reminder class]])
            [UserData instance].tasks = objects;
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)performSaveTaskSet:(ReminderGroup *)newTaskSet
{
    [newTaskSet save];
    self.task.reminderGroup = newTaskSet;
    [UserData instance].taskSets = [[UserData instance].taskSets arrayByAddingObject:newTaskSet];
    self.taskGroupTextField.text = self.task.reminderGroup.name;//[Utils getTaskGroupNameForId:self.task.reminderGroupId].name;
    NSLog(@"%@",[UserData instance].taskSets);
}

#pragma mark- Other methods

- (BOOL)isTaskValid
{
    return self.taskNameTextField.text.length > 0;
}

#pragma mark- End of life cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
