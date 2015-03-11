//
//  TaskListVC.m
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "TaskListVC.h"
#import "TaskCell.h"
#import "GroupFilterCell.h"
#import "Reminder.h"
#import "ReminderGroup.h"
#import "UserData.h"
#import "Utils.h"
#import "Const.h"
#import "FrostedViewController.h"
#import "LocalNotificationManager.h"
#import "AppDelegate.h"
#import "DataManager.h"

@interface TaskListVC ()

@property (weak, nonatomic) IBOutlet UIImageView *datetimeImageView;
@property (weak, nonatomic) IBOutlet UIView *datetimeView;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UIView *groupView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIView *statusView;

@property (strong, nonatomic) IBOutlet UIView *statusFilterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusFilterViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *statusFilterAllButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusFilterAllCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *statusFilterActiveButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusFilterActiveCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *statusFilterScheduledButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusFilterScheduledCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *statusFilterInactiveButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusFilterInactiveCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *statusFilterImportantButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusFilterImportantCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *statusFilterCompletedtButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusFilterCompletedCheckImageView;

@property (weak, nonatomic) IBOutlet UIView *groupFilterView;
@property (weak, nonatomic) IBOutlet UITableView *groupFilterTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupFilterViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupFilterViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *datetimeFilterView;
@property (weak, nonatomic) IBOutlet UITableView *datetimeFilterTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datetimeFilterViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datetimeFilterHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *datetimeFilterDateRangeView;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;

@property (weak, nonatomic) IBOutlet UIView *snoozeView;
@property (weak, nonatomic) IBOutlet UIView *snoozeRoundedRectangleView;
@property (weak, nonatomic) IBOutlet UIView *wizardView;
@property (weak, nonatomic) IBOutlet UIView *wizardRoundedRectangleView;
@property (weak, nonatomic) IBOutlet UIButton *snoozeHourButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeMorningButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeTonightButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeDayButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeWeekButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeDateButton;
@property (weak, nonatomic) IBOutlet UITextField *snoozeTextField;

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *activeTasks;
@property (strong, nonatomic) NSMutableArray *scheduledTasks;
@property (strong, nonatomic) NSMutableArray *dormantTasks;
//@property (strong, nonatomic) NSDate *undoLastNotificationDate;
//@property (strong, nonatomic) Reminder *reminderToProcessWhenDone;

@property (nonatomic) AlertType alertType;
@property (strong, nonatomic) UIAlertView *configAlert;
@property (strong, nonatomic) UIDatePicker *configPicker;
@property (strong, nonatomic) NSDictionary *configDict;

@property (strong, nonatomic) NSMutableDictionary *undoComplete;

@end

@implementation TaskListVC

@synthesize refreshHeaderView;

NSInteger SECTION_ACTIVE = 0, SECTION_SCHEDULED = 1, SECTION_DORMANT = 2;
CGFloat HEADER_HEIGHT = 24.0, FILTER_VIEW_HEIGHT = 50.0, dateKeyboardHeight = 80.0f;
NSString *TASK_CELL_IDENTIFIER = @"taskCell", *GROUP_FILTER_IDENTIFIER = @"groupFilterCell", *DATETIME_FILTER_IDENTIFIER = @"datetimeFilterCell";
NSString *SEGUE_VIEW_OR_ADD = @"viewOrAddTask", *SEGUE_EDIT = @"editTask";
NSArray *datetimeFilters;
NSString *DT_ALL = @"All (Clear Filter)", *DT_TODAY = @"Today", *DT_TOMORROW = @"Tomorrow", *DT_THIS_WEEK = @"This Week", *DT_NEXT_WEEK = @"Next Week", *DT_THIS_MONTH = @"This Month", *DT_SET_DATE = @"Set Date";
UIDatePicker *startDatePicker, *endDatePicker;
NSDateFormatter *dateFormatter;
NSIndexPath *lastCellIndexPathSwiped;
NSString *DATETIME_FORMATS = @"MMM dd, yyyy";

bool isEnable;
bool isFirstTime;

#define CONFIG_ALERT_MIN_TAG 100

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _undoComplete = [[NSMutableDictionary alloc] init];
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.reminderToProcessWhenDone = nil;
    isFirstTime=1;
    [self setupRefreshHeaderView];
    [self setupGestureRecognizers];
    [self setupFilterViewsInitially];
    [self setupSnoozeViewInitially];
    [self setupDatePickers];
    NSLog(@"NOTIS::::: %@",[[UIApplication sharedApplication] scheduledLocalNotifications]);
    [self performSelector:@selector(setupUI) withObject:self afterDelay:0.12];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"freeminders";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.undoLastNotificationDate = nil;
    
    self.groupFilterTableView.rowHeight = 44;
    self.datetimeFilterTableView.rowHeight = 44;
    [self performLoadTasks];
    [self performLoadTaskSets];
//    [self setupActiveDormantArrays];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performLoadTasks)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    // load tasks for notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performLoadTasks)
                                                 name:LocalNotificationRecieved
                                               object:nil];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if(isFirstTime)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Background work
            [self performLoadTasks];
            isFirstTime=0;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // Update UI
//            });
        });

    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationItem.title = @"Main Screen";
    [self hideDatetimeFilterView];
    [self hideGroupFilterView];
    [self hideStatusFilterView];
    [self.snoozeTextField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupRefreshHeaderView
{
    if (! self.refreshHeaderView) {
        self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        self.refreshHeaderView.delegate = self;
        [self.tableView addSubview:self.refreshHeaderView];
    }
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // Filters
    UITapGestureRecognizer *tapDatetime = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterViewPressed:)];
    [self.datetimeView addGestureRecognizer:tapDatetime];
    
    UITapGestureRecognizer *tapGroup = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterViewPressed:)];
    [self.groupView addGestureRecognizer:tapGroup];
    
    UITapGestureRecognizer *tapStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterViewPressed:)];
    [self.statusView addGestureRecognizer:tapStatus];
}

- (void)setupFilterViewsInitially
{
    // Hide status filter view
    self.statusFilterViewBottomConstraint.constant = - self.statusFilterView.frame.size.height;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 58, 0, 0);
    self.statusFilterAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.statusFilterAllButton.contentEdgeInsets = insets;
    self.statusFilterActiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.statusFilterActiveButton.contentEdgeInsets = insets;
    self.statusFilterScheduledButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.statusFilterScheduledButton.contentEdgeInsets = insets;
    self.statusFilterInactiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.statusFilterInactiveButton.contentEdgeInsets = insets;
    self.statusFilterImportantButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.statusFilterImportantButton.contentEdgeInsets = insets;
    
    // group filter view
    self.groupFilterViewBottomConstraint.constant = - self.groupFilterView.frame.size.height;
    
    // datetime filter view
    self.datetimeFilterViewBottomConstraint.constant = - self.datetimeFilterView.frame.size.height;
    datetimeFilters = [[NSArray alloc] initWithObjects:DT_ALL, DT_TODAY, DT_TOMORROW, DT_THIS_WEEK, DT_NEXT_WEEK, DT_THIS_MONTH, DT_SET_DATE, nil];
    self.datetimeFilterHeightConstraint.constant = datetimeFilters.count * 44.0;
    self.datetimeFilterViewBottomConstraint.constant = - self.datetimeFilterHeightConstraint.constant;
    self.datetimeFilterTableView.rowHeight = self.groupFilterTableView.rowHeight = 44.0;
    [self.datetimeFilterTableView reloadData];
}

- (void)setupSnoozeViewInitially
{
    self.snoozeRoundedRectangleView.layer.cornerRadius = 5.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSnoozeView)];
    [self.snoozeView addGestureRecognizer:tap];
    
    [self setupWizardViewInitially];
}
- (void)setupWizardViewInitially
{
    self.wizardRoundedRectangleView.layer.cornerRadius = 5.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideWizardView)];
    [self.wizardView addGestureRecognizer:tap];
}

- (void)setupDatePickers
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:DATETIME_FORMATS];

    // Date filter picker
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(datePickerDone)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self action:@selector(datePickerCancelled)];
    [pickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, spaceItem, doneButton, nil] animated:NO];
    
    startDatePicker = [[UIDatePicker alloc] init];
    [startDatePicker setDatePickerMode:UIDatePickerModeDate];
    [startDatePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.startDateTextField.inputView = startDatePicker;
    self.startDateTextField.inputAccessoryView = pickerToolbar;
    
    endDatePicker = [[UIDatePicker alloc] init];
    [endDatePicker setDatePickerMode:UIDatePickerModeDate];
    [endDatePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.endDateTextField.inputView = endDatePicker;
    self.endDateTextField.inputAccessoryView = pickerToolbar;
    
    // Snooze date picker
    UIToolbar *snoozePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *snoozeDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self action:@selector(snoozePickerDone)];
    [snoozePickerToolbar setItems:[NSArray arrayWithObjects:spaceItem, snoozeDoneButton, nil] animated:NO];
    
    snoozeDatePicker = [[UIDatePicker alloc] init];
    [snoozeDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    snoozeDatePicker.minimumDate = [self setOneMintueFast];
    
//    self.snoozeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:self.snoozeTextField];
    self.snoozeTextField.inputView = snoozeDatePicker;
    self.snoozeTextField.inputAccessoryView = snoozePickerToolbar;
}

- (void)setupStatusFilterView
{
    self.statusFilterAllCheckImageView.hidden = ([UserData instance].statusFilterType != allStatusFilter
                                                 || ! [UserData instance].isFilteringStatus);
    self.statusFilterActiveCheckImageView.hidden = ([UserData instance].statusFilterType != activeStatusFilter || ! [UserData instance].isFilteringStatus);
    self.statusFilterScheduledCheckImageView.hidden = ([UserData instance].statusFilterType != scheduledStatusFilter || ! [UserData instance].isFilteringStatus);
    self.statusFilterInactiveCheckImageView.hidden = ([UserData instance].statusFilterType != inactiveStatusFilter || ! [UserData instance].isFilteringStatus);
    self.statusFilterImportantCheckImageView.hidden = ([UserData instance].statusFilterType != importantStatusFilter || ! [UserData instance].isFilteringStatus);
    self.statusFilterCompletedCheckImageView.hidden = ([UserData instance].statusFilterType != completedStatusFilter || ! [UserData instance].isFilteringStatus);
}

- (void)setupActiveDormantArrays
{
    self.activeTasks = [[NSMutableArray alloc] init];
    self.scheduledTasks = [[NSMutableArray alloc] init];
    self.dormantTasks = [[NSMutableArray alloc] init];
    
    for (Reminder *task in [UserData instance].tasks) {
        BOOL meetsFilters = YES;
        if ([UserData instance].isFilteringDatetime) {
            meetsFilters = meetsFilters && [task doesMeetDatetimeFilter:[UserData instance].datetimeFilterType];
        }
        
        if ([UserData instance].isFilteringGroups) {
            meetsFilters = meetsFilters && ([[UserData instance].filterGroups containsObject:task.reminderGroup.objectId] || (!task.reminderGroup && [[UserData instance].filterGroups containsObject:@""]));
        }
        
        if ([UserData instance].isFilteringStatus) {
            
            switch ([UserData instance].statusFilterType) {
                case allStatusFilter:
                    // meetsFilters doesn't change
                    break;
                    
                case activeStatusFilter:
                    meetsFilters = meetsFilters && task.isActive
                    && (task.lastNotificationDate || task.triggerType == noTrigger)
                    && (! task.snoozedUntilDate || ! [Utils isDateInFuture:task.snoozedUntilDate]);
                    break;
                    
                case scheduledStatusFilter:
                    meetsFilters = meetsFilters && ( ! task.lastNotificationDate && task.triggerType != noTrigger) && task.isActive;
                    break;
                    
                case inactiveStatusFilter:
                    meetsFilters = meetsFilters && ! task.isActive;// && ( ! task.lastNotificationDate && task.triggerType != noTrigger);
                    break;
                    
                case importantStatusFilter:
                    meetsFilters = meetsFilters && task.isImportant;
                    break;
                    
                case completedStatusFilter:
                    meetsFilters = meetsFilters && ( ! task.lastNotificationDate && task.triggerType != noTrigger) && ! task.isActive;
                    break;
                default:
                    
                    break;
            }
        }
        
        if (meetsFilters) {
            // If task is dependent reminder waiting for its parent to completed must be in scheduled section
            if (task.isStatusActive) {
//                [task setAllStepsChecked:NO]; //To uncheck all steps if the task is already triggered Req:2.06 in v2.3 doc
                [self.activeTasks addObject:task];
            } else if (task.isActive) {
                [self.scheduledTasks addObject:task];
            } else {
                [self.dormantTasks addObject:task];
            }
        }
    }
    int badgeNumber=0;
    for(int j=0; j<[UserData instance].tasks.count; j++)
    {
        Reminder *task =((Reminder *)[[UserData instance].tasks objectAtIndex:j]);
        if(task.isActive
           && (task.lastNotificationDate || task.triggerType == noTrigger)
           && (! task.snoozedUntilDate || ! [Utils isDateInFuture:task.snoozedUntilDate]))
        {
            badgeNumber++;
        }
        
    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];// Setting badge count as the number of active reminders
    
    // CHECK IF FILTERS LEAVE NO TASKS => ALERT USER, REMOVE FILTER
    if (self.activeTasks.count == 0
        && self.scheduledTasks.count == 0
        && self.dormantTasks.count == 0
        && [UserData instance].tasks.count > 0
        && ([UserData instance].isFilteringDatetime || [UserData instance].isFilteringGroups || [UserData instance].isFilteringStatus)) {
        [Utils showSimpleAlertViewWithTitle:@"No Reminders Found" content:@"No reminders exist that match the filter criteria" andDelegate:nil];
    }
    
    [self.tableView reloadData];
}

- (void)setupUI
{
    // FILTER BUTTONS
    if ([UserData instance].isFilteringDatetime) {
        [self.datetimeView setBackgroundColor:COLOR_FREEMINDER_BLUE];
        self.datetimeImageView.highlighted = YES;
        [self applyFlickerEffect];
    } else {
        [self.datetimeView setBackgroundColor:COLOR_LIGHT_GREY];
        self.datetimeImageView.highlighted = NO;
    }
    
    if ([UserData instance].isFilteringGroups) {
        [self.groupView setBackgroundColor:COLOR_FREEMINDER_BLUE];
        self.groupImageView.highlighted = YES;
        [self applyFlickerEffect];
    } else {
        [self.groupView setBackgroundColor:COLOR_LIGHT_GREY];
        self.groupImageView.highlighted = NO;
    }
    
    if ([UserData instance].isFilteringStatus) {
        [self.statusView setBackgroundColor:COLOR_FREEMINDER_BLUE];
        self.statusImageView.highlighted = YES;
        [self applyFlickerEffect];
    } else {
        [self.statusView setBackgroundColor:COLOR_LIGHT_GREY];
        self.statusImageView.highlighted = NO;
    }
}

- (void)hideSnoozeView
{
    self.snoozeView.hidden = YES;
}
- (void)hideWizardView{
    self.wizardView.hidden = YES;
}

- (void)hideKeyboard
{
    if ([self.startDateTextField isEditing]) {
        [self.startDateTextField resignFirstResponder];
        NSLog(@"HIDE START");
    }
    
    if ([self.endDateTextField isEditing]) {
        [self.endDateTextField resignFirstResponder];
        NSLog(@"HIDE END");
    }
}

#pragma mark- UIGestureRecognizer methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.startDateTextField isEditing] || [self.endDateTextField isEditing]) {
        return YES;
    } else if ([self isShowingFilterView] && [touch.view isDescendantOfView:self.tableView]) {
        [self hideDatetimeFilterView];
        [self hideGroupFilterView];
        [self hideStatusFilterView];
        
        return NO;
    } else {
        return NO;
    }
}

#pragma mark- UITextField methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"TEXT: %@", textField.text);
}

- (IBAction)dateChanged:(UITextField *)sender
{
    UIDatePicker *picker = (UIDatePicker *) sender.inputView;
    [self datePickerChangedValue:picker];
}

- (void)datePickerChangedValue:(UIDatePicker *)picker
{
    if (picker == startDatePicker) {
        NSDate *dt = [Utils setHoursForDate:picker.date hours:0 minutes:0];
        [picker setDate:dt];
//        [UserData instance].datetimeFilterRangeStartDate = picker.date;
        self.startDateTextField.text = [dateFormatter stringFromDate:picker.date];
        
        int daysToAdd = 3;
        dt = [Utils setHoursForDate:[dt dateByAddingTimeInterval:60*60*24*daysToAdd] hours:11 minutes:59];
        [endDatePicker setDate:dt];
//        [UserData instance].datetimeFilterRangeEndDate = endDatePicker.date;
        self.endDateTextField.text = [dateFormatter stringFromDate:endDatePicker.date];
    } else if (picker == endDatePicker) {
        NSDate *dt = [Utils setHoursForDate:picker.date hours:11 minutes:59];
        [picker setDate:dt];
//        [UserData instance].datetimeFilterRangeEndDate = picker.date;
        self.endDateTextField.text = [dateFormatter stringFromDate:picker.date];
    }
}

- (void)datePickerDone
{
//    [UserData instance].datetimeFilterRangeStartDate = startDatePicker.date;
    self.startDateTextField.text = [dateFormatter stringFromDate:startDatePicker.date];
//    [UserData instance].datetimeFilterRangeEndDate = endDatePicker.date;
    self.endDateTextField.text = [dateFormatter stringFromDate:endDatePicker.date];
    [self hideKeyboard];
}

- (void)datePickerCancelled
{
    [self hideKeyboard];
}

- (void)snoozePickerDone
{
    [UserData instance].task.snoozedUntilDate = snoozeDatePicker.date;
    [UserData instance].task.nextNotificationDate = [UserData instance].task.snoozedUntilDate;
    [UserData instance].task.notificationSent = NO;
    [self.snoozeTextField resignFirstResponder];
    [[DataManager sharedInstance] saveReminder:[UserData instance].task withBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
//           [self performLoadTasks];
            [self setupActiveDormantArrays];
            [LocalNotificationManager setNotificationsForAllTasks];
        }
    }];
}

#pragma mark- PullToRefresh TableView methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self performLoadTasks];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return [MBProgressHUD HUDForView:self.view] != nil;
}

#pragma mark- UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark- UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == SECTION_ACTIVE)
            return self.activeTasks.count;
        else if (section == SECTION_SCHEDULED)
            return self.scheduledTasks.count;
        else if (section == SECTION_DORMANT)
            return self.dormantTasks.count;
        else
            return 0;
    } else if (tableView == self.groupFilterTableView) {
        return [UserData instance].taskSets.count+1;
    } else {
        return datetimeFilters.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        Reminder *task;
        
        if (indexPath.section == SECTION_ACTIVE)
            task = [self.activeTasks objectAtIndex:indexPath.row];
        else if (indexPath.section == SECTION_SCHEDULED)
            task = [self.scheduledTasks objectAtIndex:indexPath.row];
        else if (indexPath.section == SECTION_DORMANT)
            task = [self.dormantTasks objectAtIndex:indexPath.row];
        
        TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:TASK_CELL_IDENTIFIER forIndexPath:indexPath];
        __weak TaskCell *weakCell = cell;
        for (UIGestureRecognizer *gesture in cell.cellScrollView.gestureRecognizers) {
            if ([gesture isKindOfClass:[SWLongPressGestureRecognizer class]]) {
                [cell.cellScrollView removeGestureRecognizer:gesture];
            }
        }
        [cell setAppearanceWithBlock:^{
            weakCell.containingTableView = tableView;
            
            NSMutableArray *leftUtilityButtons = [NSMutableArray new];
            NSMutableArray *rightUtilityButtons = [NSMutableArray new];
            
            // SNOOZE
            if (indexPath.section == SECTION_ACTIVE) {
                [rightUtilityButtons sw_addUtilityButtonWithColor:
                 [UIColor colorWithWhite:0.0f alpha:0.0f]
                                                             icon:[UIImage imageNamed:@"slide_left_snooze_icon.png"]];
            }
            
            // EDIT
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithWhite:0.0f alpha:0.0f]
                                                         icon:[UIImage imageNamed:@"slide_left_edit_icon.png"]];
            
            // DISABLE
            NSString *disableImageName = task.isActive ? @"slide_left_disable_icon.png" : @"enable-icon.png";
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithWhite:0.0f alpha:0.0f]
                                                         icon:[UIImage imageNamed:disableImageName]];
            // DELETE
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithWhite:0.0f alpha:0.0f]
                                                         icon:[UIImage imageNamed:@"slide_left_delete_icon.png"]];
            
            // COMPLETE
            if (indexPath.section == SECTION_ACTIVE) {
                NSString *normalIconFilename = (!task.isMarkedDone)&&(task.lastNotificationDate || (task.triggerType == noTrigger && task.isActive)) ? @"slide_right_done_icon.png" : @"slide_left_undo_icon.png";
                NSString *selectedIconFilename = (!task.isMarkedDone)&&(task.lastNotificationDate || (task.triggerType == noTrigger && task.isActive)) ? @"slide_right_done_icon_activate.png" : @"slide_left_undo_icon_active.png";
                [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithWhite:0.0f alpha:0.0f] normalIcon:[UIImage imageNamed:normalIconFilename] selectedIcon:[UIImage imageNamed:selectedIconFilename]];
            } else if (indexPath.section == SECTION_DORMANT) {
                [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithWhite:0.0f alpha:0.0f] normalIcon:[UIImage imageNamed:@"enable-icon.png"] selectedIcon:[UIImage imageNamed:@"enable-icon-active.png"]];
            } else if (indexPath.section == SECTION_SCHEDULED) {
                [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithWhite:0.0f alpha:0.0f] normalIcon:[UIImage imageNamed:@"activate_icon.png"] selectedIcon:[UIImage imageNamed:@"activate_icon_active.png"]];
            }
            
            weakCell.leftUtilityButtons = leftUtilityButtons;
            weakCell.rightUtilityButtons = rightUtilityButtons;
            
            weakCell.delegate = self;
        } force:YES];
        
        [cell setCellHeight:cell.frame.size.height];
//        if(((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeating || ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).isRepeat|| ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRepeat)
//        {
//            task.lastNotificationDate=nil;
//        }
         NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:task.name];
        if ((task.isActive && !task.isMarkedDone)
            || indexPath.section != SECTION_ACTIVE) {
            cell.titleLabel.text = task.name;
            cell.titleLabel.textColor = [UIColor darkGrayColor];
           } else {
           [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@1
                                    range:NSMakeRange(0, [attributeString length])];
            cell.titleLabel.attributedText = attributeString;
            cell.titleLabel.textColor = [UIColor lightGrayColor];
        }
        ReminderGroup *remGroup = task.reminderGroup;//[Utils getTaskGroupNameForId:task.reminderGroupId];
        cell.groupLabel.text = remGroup.name.length?remGroup.name:@"none";
       
        CGRect rect = cell.triggerImageView.frame;
        [cell.triggerImageView setHidden:NO];
        [cell.triggerImageView setImage:[UIImage imageNamed:[Utils imageFilenameForTrigger:task.triggerType]]];
        rect.origin.x -= 21;
        [cell.localNotifcationImageView setHidden:!task.isNotificationEnable];
        if (task.isNotificationEnable) {
            cell.localNotifcationImageView.frame =rect;
            rect.origin.x -= 21;
        }
        [cell.emailImageView setHidden:task.userContacts.count?NO:YES];
        if (task.userContacts.count) {
            cell.emailImageView.frame = rect;
            rect.origin.x -= 21;
        }
        [cell.stepsImageView setHidden:(task.reminderSteps.count == 0)];
        if (task.reminderSteps.count != 0) {
            cell.stepsImageView.frame = rect;
            rect.origin.x -= 21;
        }
        [cell.importantImageView setHidden:!task.isImportant];
        if (task.isImportant) {
            cell.importantImageView.frame = rect;
            rect.origin.x -= 21;
        }
        [cell.dependImageView setHidden:!task.isDependentOnParent];
        if (task.isDependentOnParent) {
            cell.dependImageView.frame =rect;
            rect.origin.x -= 21;
        }
        [cell.snoozeImageView setHidden:task.snoozedUntilDate?NO:YES];
        if (task.snoozedUntilDate) {
            cell.snoozeImageView.frame = rect;
            rect.origin.x -= 21;
        }
        CGFloat width = rect.origin.x + rect.size.width;
        width = cell.triggerImageView.superview.frame.origin.x + width ;
/*        rect = cell.titleLabel.frame;
        rect.size.width = width;
        cell.titleLabel.frame = rect;*/
        width = cell.contentView.frame.size.width - width;
        cell.widthCon.constant = width;
        
//        NSLog(@"%ld",task.emailsToNotify.count);
        UIColor *colorCode = (indexPath.section == SECTION_ACTIVE)?[task color]:[UIColor lightGrayColor];
        [cell.colorView setBackgroundColor:colorCode];
        cell.dateLabel.textColor = colorCode;
        cell.dateLabel.text = [task daysSinceLastNotification];
        cell.dateLabel.hidden = ! task.lastNotificationDate;
        if(indexPath.section == SECTION_DORMANT)
        {
            cell.dateLabel.hidden=YES;
        }
//        [cell setNeedsDisplay];
       
        return cell;
    } else if (tableView == self.groupFilterTableView) {
        NSString *groupId = @"";
        NSString *groupName = @"(No Group)";
        if (indexPath.row > 0) {
            ReminderGroup *taskSet = [[UserData instance].taskSets objectAtIndex:indexPath.row-1];
            groupName = taskSet.name;
            groupId = taskSet.objectId;
        }
        
        GroupFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:GROUP_FILTER_IDENTIFIER forIndexPath:indexPath];
        
        cell.nameLabel.text = groupName;
        cell.checkmarkImageView.hidden = ! [[UserData instance].filterGroups containsObject:groupId];
        
        return cell;
    } else if (tableView == self.datetimeFilterTableView) {
        NSString *datetimeFilter = [datetimeFilters objectAtIndex:indexPath.row];
        GroupFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:DATETIME_FILTER_IDENTIFIER forIndexPath:indexPath];
        
        cell.nameLabel.text = datetimeFilter;
        
        if (! [UserData instance].isFilteringDatetime) {
            cell.checkmarkImageView.hidden = YES;
        } else if (([UserData instance].datetimeFilterType == allDatetimeFilter && [datetimeFilter isEqualToString:DT_ALL])
                   || ([UserData instance].datetimeFilterType == todayDatetimeFilter && [datetimeFilter isEqualToString:DT_TODAY])
                   || ([UserData instance].datetimeFilterType == tomorrowDatetimeFilter && [datetimeFilter isEqualToString:DT_TOMORROW])
                   || ([UserData instance].datetimeFilterType == thisWeekDatetimeFilter && [datetimeFilter isEqualToString:DT_THIS_WEEK])
                   || ([UserData instance].datetimeFilterType == nextWeekDatetimeFilter && [datetimeFilter isEqualToString:DT_NEXT_WEEK])
                   || ([UserData instance].datetimeFilterType == thisMonthDatetimeFilter && [datetimeFilter isEqualToString:DT_THIS_MONTH])
                   || ([UserData instance].datetimeFilterType == setDateDatetimeFilter && [datetimeFilter isEqualToString:DT_SET_DATE])) {
            cell.checkmarkImageView.hidden = NO;
        } else {
            cell.checkmarkImageView.hidden = YES;
        }
        
        return cell;
    } else {
        NSLog(@"UNKNOWN TABLEVIEW");
        return nil;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (! [self isShowingFilterView]) {
            if (indexPath.section == SECTION_ACTIVE) {
                [UserData instance].task = [self.activeTasks objectAtIndex:indexPath.row];
            } else if (indexPath.section == SECTION_SCHEDULED) {
                [UserData instance].task = [self.scheduledTasks objectAtIndex:indexPath.row];
            } else if (indexPath.section == SECTION_DORMANT) {
                [UserData instance].task = [self.dormantTasks objectAtIndex:indexPath.row];
            }
            [[UserData instance].task filterNullObjects];
/*            if ([UserData instance].task.reminderGroup.configJSON.length){//([Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].configJSON.length) {
                [self showConfigurationWindow:CONFIG_ALERT_MIN_TAG];
//                self.wizardView.hidden = NO;
            }
            else {*/
                [self.snoozeTextField resignFirstResponder];
                [self performSegueWithIdentifier:SEGUE_VIEW_OR_ADD sender:self];
//            }
        }
    } else if (tableView == self.groupFilterTableView) {
        ReminderGroup *taskSet;
        NSString *groupId;
        if (indexPath.row == 0){
            taskSet = nil;
            groupId = @"";
        }
        else {
            taskSet = [[UserData instance].taskSets objectAtIndex:indexPath.row-1];
            groupId = taskSet.objectId;
        }
        NSMutableArray *mutableFilterGroups = [[UserData instance].filterGroups mutableCopy];
        
        if([[UserData instance].filterGroups containsObject:groupId]) {
            [mutableFilterGroups removeObject:groupId];
        } else {
            [mutableFilterGroups addObject:groupId];
        }
        
        [UserData instance].filterGroups = [mutableFilterGroups copy];
        [UserData instance].isFilteringGroups = (mutableFilterGroups.count > 0);
        
        [self.groupFilterTableView reloadData];
        [self setupActiveDormantArrays];
        [self setupUI];
    } else if (tableView == self.datetimeFilterTableView) {
        NSString *datetimeFilter = [datetimeFilters objectAtIndex:indexPath.row];
//        [UserData instance].isFilteringDatetime = YES;
        if ([datetimeFilter isEqualToString:DT_NEXT_WEEK]) {
            [UserData instance].datetimeFilterType = nextWeekDatetimeFilter;
        } else if ([datetimeFilter isEqualToString:DT_SET_DATE]) {
            [dateFormatter setDateFormat:DATETIME_FORMATS];
            [UserData instance].datetimeFilterType = setDateDatetimeFilter;
            self.datetimeFilterDateRangeView.hidden = NO;
           if(![UserData instance].datetimeFilterRangeStartDate)
            {
                NSDate *today = [Utils setHoursForDate:[NSDate date] hours:0 minutes:0];
                
                [UserData instance].datetimeFilterRangeStartDate = today;
                int daysToAdd = 3;
                 NSDate *newDate = [Utils setHoursForDate:[today dateByAddingTimeInterval:60*60*24*daysToAdd] hours:11 minutes:59];
                
                [UserData instance].datetimeFilterRangeEndDate = newDate;
            }
            [startDatePicker setDate:[UserData instance].datetimeFilterRangeStartDate];
            self.startDateTextField.text = [dateFormatter stringFromDate:[UserData instance].datetimeFilterRangeStartDate];
            [endDatePicker setDate:[UserData instance].datetimeFilterRangeEndDate];
            self.endDateTextField.text = [dateFormatter stringFromDate:[UserData instance].datetimeFilterRangeEndDate];
            
        } else if ([datetimeFilter isEqualToString:DT_THIS_MONTH]) {
            [UserData instance].datetimeFilterType = thisMonthDatetimeFilter;
        } else if ([datetimeFilter isEqualToString:DT_THIS_WEEK]) {
            [UserData instance].datetimeFilterType = thisWeekDatetimeFilter;
        } else if ([datetimeFilter isEqualToString:DT_TODAY]) {
            [UserData instance].datetimeFilterType = todayDatetimeFilter;
        } else if ([datetimeFilter isEqualToString:DT_TOMORROW]) {
            [UserData instance].datetimeFilterType = tomorrowDatetimeFilter;
        } else {
            [UserData instance].datetimeFilterRangeStartDate = nil;
            [UserData instance].datetimeFilterRangeEndDate = nil;
            [UserData instance].datetimeFilterType = noDatetimeFilter;
            [UserData instance].isFilteringDatetime = NO;
        }
        [UserData instance].isFilteringDatetime = ([UserData instance].datetimeFilterType != noDatetimeFilter && [UserData instance].datetimeFilterType != setDateDatetimeFilter)?YES:[UserData instance].isFilteringDatetime;
        [self.datetimeFilterTableView reloadData];
        [self hideDatetimeFilterView];
        
        if (! [datetimeFilter isEqualToString:DT_SET_DATE]) {
            [self setupActiveDormantArrays];
            [self setupUI];
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 3;
    } else if (tableView == self.groupFilterTableView) {
        return 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.activeTasks.count == 0 && section == SECTION_ACTIVE) {
            return 0.0;
        } else if (self.scheduledTasks.count == 0 && section == SECTION_SCHEDULED) {
            return 0.0;
        } else if (self.dormantTasks.count == 0 && section == SECTION_DORMANT) {
            return 0.0;
        }
        
        return HEADER_HEIGHT;
    } else if (tableView == self.groupFilterTableView) {
        return 0.0;
    } else {
        return 0.0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == SECTION_ACTIVE) {
            return @"Active";
        } else if (section == SECTION_SCHEDULED) {
            return @"Scheduled";
        } else if (section == SECTION_DORMANT) {
            return @"Inactive";
        } else {
            return nil;
        }
    } else if (tableView == self.groupFilterTableView) {
        return nil;
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.activeTasks.count == 0 && section == SECTION_ACTIVE) {
            return [[UIView alloc] init];
        } else if (self.scheduledTasks.count == 0 && section == SECTION_SCHEDULED) {
            return [[UIView alloc] init];
        } else if (self.dormantTasks.count == 0 && section == SECTION_DORMANT) {
            return [[UIView alloc] init];
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
        [view setBackgroundColor:[UIColor colorWithWhite:235.0/255.0 alpha:1.0]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, view.frame.size.width, view.frame.size.height)];
        [titleLabel setText:[self tableView:tableView titleForHeaderInSection:section]];
        [titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [view addSubview:titleLabel];
        
        return view;
    } else if (tableView == self.groupFilterTableView) {
        return nil;
    } else {
        return nil;
    }
}

#pragma mark- SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    if (state == kCellStateLeft) {
        NSLog(@"STATE 1");
        UIButton *completeButton = cell.leftUtilityButtons.firstObject;
        if (completeButton.isSelected) { // far enough to be completed
            NSLog(@"TASK COMPLETE TOGGLED");
            Reminder *task;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath.section == SECTION_ACTIVE) {
                task = [self.activeTasks objectAtIndex:indexPath.row];
                
   /*             if (task.triggerType == noTrigger) {
                    task.isActive = ! task.isActive;
                    task.isMarkedDone = !task.isMarkedDone;
                    //                    self.undoLastNotificationDate = self.undoLastNotificationDate?nil:task.lastNotificationDate;
                    if (!task.lastNotificationDate) {
                        task.lastNotificationDate = [NSDate date];
                        
                    }
                    [_undoComplete objectForKey:task.objectId]?[_undoComplete removeObjectForKey:task.objectId]:[_undoComplete setObject:task.lastNotificationDate forKey:task.objectId];
                } else */if (task.lastNotificationDate) { // mark complete
//                    self.undoLastNotificationDate = task.lastNotificationDate;
                    [_undoComplete setObject:task.lastNotificationDate forKey:task.objectId];
                    task.lastNotificationDate = nil;
                    task.lastCompletionDate = [NSDate date];
                    
                    BOOL shouldGoToScheduledTasks = NO;
                    if (task.triggerType==datetimeTrigger && task.dateTimeTriggers && task.dateTimeTriggers.count && (! [[task.dateTimeTriggers objectAtIndex:0] isDataAvailable] || ((DateTimeTrigger *)[task.dateTimeTriggers objectAtIndex:0]).isRepeating))
                        shouldGoToScheduledTasks = YES;
                    else if (task.triggerType==weatherTrigger && task.weatherTriggers && task.weatherTriggers.count && (! [((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]) isDataAvailable] || ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isRepeat))
                        shouldGoToScheduledTasks = YES;
                    else if (task.triggerType==locationTrigger && task.locationTriggers && task.locationTriggers.count && (! [[task.locationTriggers objectAtIndex:0] isDataAvailable] || ((LocationTrigger *)[task.locationTriggers objectAtIndex:0]).isRepeat))
                        shouldGoToScheduledTasks = YES;
                    
                    task.isActive = shouldGoToScheduledTasks;
                    task.isMarkedDone = YES;
                } else {
//                    task.lastNotificationDate = self.undoLastNotificationDate?self.undoLastNotificationDate:[NSDate date];
                    task.lastNotificationDate = [_undoComplete objectForKey:task.objectId]?[_undoComplete objectForKey:task.objectId]:[NSDate date];
                    task.lastCompletionDate = nil;
//                    self.undoLastNotificationDate = nil;
                    [_undoComplete removeObjectForKey:task.objectId];
                    task.isMarkedDone = NO;
                    task.isActive = YES;
                }
                
                [[DataManager sharedInstance] saveReminder:task];
                [cell hideUtilityButtonsAnimated:NO];
                [self.tableView reloadData];
            } else if (indexPath.section == SECTION_DORMANT) {
                task = [self.dormantTasks objectAtIndex:indexPath.row];
                
                task.isActive = YES;
                task.lastNotificationDate = (task.triggerType == noTrigger)?[NSDate date]:nil;
                if(task.triggerType == noTrigger)
                {
                    [task setAllStepsChecked:NO];
                }
                task.lastCompletionDate = nil;
                
                [[DataManager sharedInstance] saveReminder:task];
                [cell hideUtilityButtonsAnimated:NO];
                [self performLoadTasks];
            } else if (indexPath.section == SECTION_SCHEDULED){
                task = [self.scheduledTasks objectAtIndex:indexPath.row];
                task.isActive = YES;
                [task setAllStepsChecked:NO];
                task.lastNotificationDate = [NSDate date];
                task.snoozedUntilDate = nil;
                [[DataManager sharedInstance] saveReminder:task];
                [cell hideUtilityButtonsAnimated:NO];
                [self performLoadTasks];
            }
        } else {
            [cell hideUtilityButtonsAnimated:YES];
        }
    } else if (state == kCellStateRight) {
        if (! [lastCellIndexPathSwiped isEqual:[self.tableView indexPathForCell:cell]]) {
            lastCellIndexPathSwiped = [self.tableView indexPathForCell:cell];
            
            for (SWTableViewCell *swCell in [self.tableView visibleCells]) {
                if (swCell != cell) {
                    [swCell hideUtilityButtonsAnimated:YES];
                }
            }
        }
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    NSLog(@"TAPPING LEFT BUTTONS SHOULD NOT DO ANYTHING");
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Reminder *task;
    UIAlertView *alertView;
    if (indexPath.section == SECTION_ACTIVE)
        task = [self.activeTasks objectAtIndex:indexPath.row];
    else if (indexPath.section == SECTION_SCHEDULED)
        task = [self.scheduledTasks objectAtIndex:indexPath.row];
    else if (indexPath.section == SECTION_DORMANT)
        task = [self.dormantTasks objectAtIndex:indexPath.row];
    
    if (indexPath.section != SECTION_ACTIVE) {
        index += 1; // anything not in Active is missing the snooze button
    }
    NSString *msg, *title;
    switch (index) {
        case 0:
            // snooze button was pressed
            [cell hideUtilityButtonsAnimated:YES];
            [UserData instance].task = task;
            self.snoozeView.hidden = NO;
            break;
        case 1:
            // edit button was pressed
            [task filterNullObjects];
            [UserData instance].task = task;
            [self performSegueWithIdentifier:SEGUE_EDIT sender:self];
            break;
        case 2:
            // disable button was pressed
            [UserData instance].task = task;
//            if(indexPath.section == SECTION_DORMANT)
//            {
//                isEnable=1;
//                alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Are you sure You want to enable this reminder \"%@\"?",task.name]delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
//                alertView.tag = disableAlert;
//                [alertView show];
//              
//            }
//            else
//            {
//                alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Are you sure You want to disable this reminder \"%@\"?",task.name]delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
//                alertView.tag = disableAlert;
//                [alertView show];
//            }
            [self enableOrDisableTask:[UserData instance].task];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        case 3:
            // delete button was pressed
            [UserData instance].task = task;
            if (task.isDependent && !task.isDependentOnParent) {
                msg = [NSString stringWithFormat:@"Deleting this reminder may prevent other reminders from activating without user intervention. Are you sure you would like to continue and delete the \"%@\" reminder?",task.name];
                title = @"Warning";
            }else{
                msg = [NSString stringWithFormat:@"Are you sure you want to delete the reminder \"%@\"? This cannot be undone.",task.name];
                title = @"";
            }
            alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            alertView.tag = deleteAlert;
            [alertView show];
            [cell hideUtilityButtonsAnimated:YES];
        default:
            break;
    }
}

#pragma mark- AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

//    if(isEnable && buttonIndex==1 && disableAlert)
//    {
//        isEnable=0;
//        [self enableOrDisableTask:[UserData instance].task];
//       
//    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ( alertView.tag == deleteAlert && buttonIndex==1) {
        [self performDeleteTask:[UserData instance].task];
    }
    else if (alertView.tag >= CONFIG_ALERT_MIN_TAG) {
        if (buttonIndex == 1) {
            [self configureReminderDuedate:(int)alertView.tag];
            [self showConfigurationWindow:(int)alertView.tag+1];
        }
        else {
            Reminder *task = [UserData instance].task;
            ReminderGroup *group = task.reminderGroup;//[Utils getTaskGroupNameForId:task.reminderGroupId];
            UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Canceling this mandatory input will remove the %@ group from your freeminders app. If you do cancel you may download this group again in the future with no additional charge. Would you like to proceed and cancel this group download?",group.name] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Go Back", nil];
            confirmAlert.tag = 99;
            [confirmAlert show];
        }
            
    }
    else if (alertView.tag == 99) {
        if (buttonIndex == 1) {
//            self.configAlert.tag -= 1;
            [self showConfigurationWindow:(int)self.configAlert.tag];
        }
        else {
            [self.configAlert textFieldAtIndex:0].text = @"";
            self.configAlert = nil;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [Utils performDeleteReminderGroupandReminders:[UserData instance].task.reminderGroup/*[Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId]*/ completionHandler:^(BOOL success, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    [self performLoadTasks];
                }
            }];
        }
    }
}
- (void)enableOrDisableTask:(Reminder* )task
{
    task.isActive = ! task.isActive;
    task.lastNotificationDate = (task.isActive && task.triggerType == noTrigger)?[NSDate date]:nil;
    if((task.isActive && task.triggerType == noTrigger))
    {
        [task setAllStepsChecked:NO];
  
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] saveReminder:task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self performLoadTasks];
    }];
    
}


#pragma mark- Actions

- (IBAction)menuButtonPressed
{
    [self.snoozeTextField resignFirstResponder];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)addTaskButtonPressed
{
    [UserData instance].task = [[Reminder alloc] init];
    [UserData instance].task.isActive = YES;
    [UserData instance].task.isNotificationEnable=YES;
    
    [UserData instance].task.userContacts = [[NSMutableArray alloc] init];
    for (int i = 0; i < [UserData instance].userContacts.count; i++) {
        UserContact *contact = [[UserData instance].userContacts objectAtIndex:i];
        if (contact.defaultBool && contact.email.length){
            [[UserData instance].task.userContacts addObject:contact];
        }
    }
    [self performSegueWithIdentifier:SEGUE_EDIT sender:self];
}

- (void)filterViewPressed:(UITapGestureRecognizer *)tap
{
    UIView *view = tap.view;
    self.datetimeFilterDateRangeView.hidden = YES;
    if (view == self.datetimeView) {
        [self hideStatusFilterView];
        [self hideGroupFilterView];
        [self toggleDatetimeFilterView];
    } else if (view == self.groupView) {
        [self hideDatetimeFilterView];
        [self hideStatusFilterView];
        [self toggleGroupFilterView];
    } else if (view == self.statusView) {
        [self hideDatetimeFilterView];
        [self hideGroupFilterView];
        [self toggleStatusFilterView];
    }
}

- (IBAction)statusFilterButtonPressed:(UIButton *)button
{
    [UserData instance].isFilteringStatus = YES;
    
    if (button == self.statusFilterAllButton) {
        [UserData instance].statusFilterType = allStatusFilter;
        [UserData instance].isFilteringStatus = NO;
    } else if (button == self.statusFilterActiveButton) {
        [UserData instance].statusFilterType = activeStatusFilter;
    } else if (button == self.statusFilterScheduledButton) {
        [UserData instance].statusFilterType = scheduledStatusFilter;
    } else if (button == self.statusFilterInactiveButton) {
        [UserData instance].statusFilterType = inactiveStatusFilter;
    } else if (button == self.statusFilterImportantButton) {
        [UserData instance].statusFilterType = importantStatusFilter;
    } else if (button == self.statusFilterCompletedtButton) {
        [UserData instance].statusFilterType = completedStatusFilter;
    }
    
    [self toggleStatusFilterView];
    [self setupActiveDormantArrays];
    [self setupUI];
}

- (IBAction)snoozeButtonPressed:(UIButton *)button
{
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *snoozeDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
    
    NSLog(@"SNOOZE");
    if (button == self.snoozeHourButton) {
        [UserData instance].task.snoozedUntilDate = [[NSDate date] dateByAddingTimeInterval:SECONDS_PER_HOUR];
    }  else if (button == self.snoozeMorningButton) {
        [snoozeDate setHour:7];
        [snoozeDate setMinute:0];
        NSCalendar *cal = [NSCalendar currentCalendar];
        if ([UserData instance].userSettings.inTheMorning) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[UserData instance].userSettings.inTheMorning];
            [snoozeDate setHour:components.hour];
            [snoozeDate setMinute:components.minute];
        }
        [UserData instance].task.snoozedUntilDate = [cal dateFromComponents:snoozeDate];
        NSDate *morningDate = [cal dateFromComponents:today];
        if ([morningDate compare:[UserData instance].task.snoozedUntilDate] == NSOrderedDescending) { // if it's after 6am, set alarm for tomorrow morning
            [UserData instance].task.snoozedUntilDate = [[UserData instance].task.snoozedUntilDate dateByAddingTimeInterval:SECONDS_PER_DAY];
        }
    } else if (button == self.snoozeTonightButton) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        [snoozeDate setHour:20];
        [snoozeDate setMinute:0];
        if ([UserData instance].userSettings.toNight) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[UserData instance].userSettings.toNight];
            [snoozeDate setHour:components.hour];
            [snoozeDate setMinute:components.minute];
        }
        [UserData instance].task.snoozedUntilDate = [cal dateFromComponents:snoozeDate];
        NSDate *toNightDate = [cal dateFromComponents:today];
        if ([toNightDate compare:[UserData instance].task.snoozedUntilDate] == NSOrderedDescending) { // if it's after 8pm, set alarm for tomorrow
            [UserData instance].task.snoozedUntilDate = [[UserData instance].task.snoozedUntilDate dateByAddingTimeInterval:SECONDS_PER_DAY];
        }
    } else if (button == self.snoozeDayButton) {
        [UserData instance].task.snoozedUntilDate = [[NSDate date] dateByAddingTimeInterval:SECONDS_PER_DAY];
    } else if (button == self.snoozeWeekButton) {
        [UserData instance].task.snoozedUntilDate = [[NSDate date] dateByAddingTimeInterval:SECONDS_PER_WEEK];
    } else if (button == self.snoozeDateButton) {
        [UserData instance].task.snoozedUntilDate = nil;
        [snoozeDatePicker setDate:[self setOneMintueFast]];
        [self.snoozeTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.7];
//        [NSThread sleepForTimeInterval:.006];
//        [self performSelector:nil withObject:self afterDelay:.006];
         NSLog(@"%@",self.snoozeTextField);
    }
    [UserData instance].task.nextNotificationDate = [UserData instance].task.snoozedUntilDate;
    [UserData instance].task.notificationSent = NO;
    [[DataManager sharedInstance] saveReminder:[UserData instance].task];
    [self setupActiveDormantArrays];
    
    self.snoozeView.hidden = YES;
}
-(NSDate *)setOneMintueFast
{
    NSDate *date=[NSDate date];
    NSDate *datePlusOneMinute = [date dateByAddingTimeInterval:60];
    return datePlusOneMinute;

}

- (IBAction)submitDateRangeButtonPressed
{
    [UserData instance].datetimeFilterRangeStartDate = startDatePicker.date;
    [UserData instance].datetimeFilterRangeEndDate = endDatePicker.date;
    [UserData instance].isFilteringDatetime = YES;
    [UserData instance].datetimeFilterType = setDateDatetimeFilter;
    self.datetimeFilterDateRangeView.hidden = YES;
    [self hideKeyboard];
    [self.datetimeFilterTableView reloadData];
    [self setupActiveDormantArrays];
    [self setupUI];
}

- (IBAction)cancelDateRangeButtonPressed
{
    [UserData instance].datetimeFilterRangeStartDate = nil;
    [UserData instance].datetimeFilterRangeEndDate = nil;
    [UserData instance].isFilteringDatetime = NO;
    [UserData instance].datetimeFilterType = noDatetimeFilter;
    self.datetimeFilterDateRangeView.hidden = YES;
    [self hideKeyboard];
    [self.datetimeFilterTableView reloadData];
    [self setupActiveDormantArrays];
    [self setupUI];
}

#pragma mark- Animations

- (void)toggleStatusFilterView
{
    [self setupStatusFilterView];
    [self.view layoutIfNeeded];
    
    if (self.statusFilterViewBottomConstraint.constant > 0) {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.statusFilterViewBottomConstraint.constant = - self.statusFilterView.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.statusFilterViewBottomConstraint.constant = FILTER_VIEW_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)toggleGroupFilterView
{
    if ([UserData instance].taskSets.count > 0) {
        CGFloat filterTableViewHeight = ([UserData instance].taskSets.count+1) * 44.0;
        if(filterTableViewHeight > 308)
        {
            filterTableViewHeight = 308;
        }
        filterTableViewHeight = MIN(filterTableViewHeight, self.view.frame.size.height - FILTER_VIEW_HEIGHT);
        self.groupFilterViewHeightConstraint.constant = filterTableViewHeight;
    }
    
    [self.groupFilterTableView reloadData];
    [self.view layoutIfNeeded];
    
    if (self.groupFilterViewBottomConstraint.constant > 0) {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.groupFilterViewBottomConstraint.constant = - self.groupFilterView.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.groupFilterViewBottomConstraint.constant = FILTER_VIEW_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)toggleDatetimeFilterView
{
//        [self setupDatetimeFilterViewUI];
        [self.view layoutIfNeeded];
    
    if (self.datetimeFilterViewBottomConstraint.constant > 0) {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.datetimeFilterViewBottomConstraint.constant = - self.datetimeFilterView.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.datetimeFilterViewBottomConstraint.constant = FILTER_VIEW_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideStatusFilterView
{
    [self.view layoutIfNeeded];
    
    if (self.statusFilterViewBottomConstraint.constant > 0) {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.statusFilterViewBottomConstraint.constant = - self.statusFilterView.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideGroupFilterView
{
    [self.view layoutIfNeeded];
    
    if (self.groupFilterViewBottomConstraint.constant > 0) {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.groupFilterViewBottomConstraint.constant = - self.groupFilterView.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideDatetimeFilterView
{
    [self.view layoutIfNeeded];
    
    if (self.datetimeFilterViewBottomConstraint.constant > 0) {
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.datetimeFilterViewBottomConstraint.constant = - self.datetimeFilterView.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    }
}

- (BOOL)isShowingFilterView
{
    return self.datetimeFilterViewBottomConstraint.constant > 0
    || self.groupFilterViewBottomConstraint.constant > 0
    || self.statusFilterViewBottomConstraint.constant > 0
    || self.datetimeFilterView.layer.animationKeys.count > 0
    || self.groupFilterView.layer.animationKeys.count > 0
    || self.statusFilterView.layer.animationKeys.count > 0;
}

- (void)setBackgroundColor:(UIColor *)color {
    if ([UserData instance].isFilteringDatetime) {
        [self.datetimeView setBackgroundColor:color];
    }
    if ([UserData instance].isFilteringGroups) {
        [self.groupView setBackgroundColor:color];
    }
    if ([UserData instance].isFilteringStatus) {
        [self.statusView setBackgroundColor:color];
    }
}
- (void)applyFlickerEffect {
    float interval = 0.3;
    [self performSelector:@selector(setBackgroundColor:) withObject:COLOR_LIGHT_GREY afterDelay:interval];
    [self performSelector:@selector(setBackgroundColor:) withObject:COLOR_FREEMINDER_BLUE afterDelay:2*interval];
    [self performSelector:@selector(setBackgroundColor:) withObject:COLOR_LIGHT_GREY afterDelay:3*interval];
    [self performSelector:@selector(setBackgroundColor:) withObject:COLOR_FREEMINDER_BLUE afterDelay:4*interval];
}

#pragma mark- Networking

- (void)performLoadTasks
{
    [_undoComplete removeAllObjects];
    for (Reminder *reminder in [UserData instance].tasks) {
        if(reminder.isDependent && reminder.isMarkedDone){
            [Utils scheduleDependentReminders:reminder];
        }
        reminder.isMarkedDone = NO;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] loadDetailedTasksWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        NSLog(@"TASKS LOADED IN Tasklist");
        PFObject *firstObject = (PFObject *)objects.firstObject;
//        if ([objects.firstObject isKindOfClass:[Reminder class]] || objects.count == 0) {
        if ([[firstObject parseClassName] isEqualToString:[Reminder parseClassName]] || objects.count == 0) {
            
            for (Reminder *task in objects) {
                NSMutableArray *mutableTaskIds = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_TAPPED_TASK_ID_ARRAY] mutableCopy];
                if ([mutableTaskIds containsObject:task.objectId]) {
                    task.lastNotificationDate = [NSDate date];
                    [[DataManager sharedInstance] saveReminder:task];
                    [mutableTaskIds removeObject:task.objectId];
                    [[NSUserDefaults standardUserDefaults] setObject:[mutableTaskIds copy] forKey:USER_DEFAULTS_TAPPED_TASK_ID_ARRAY];
                }
                if (task.snoozedUntilDate && ! [Utils isDateInFuture:task.snoozedUntilDate]) {
                    task.snoozedUntilDate = nil;
                    [[DataManager sharedInstance] saveReminder:task];
                } else if (task.nextNotificationDate && ! [Utils isDateInFuture:task.nextNotificationDate]) {
                    task.lastNotificationDate = task.nextNotificationDate;
                    task.nextNotificationDate = nil;
                    [task setAllStepsChecked:NO];
                    [[DataManager sharedInstance] saveReminder:task];
                }
            }
            
            [UserData instance].tasks = objects;
            
            // Determine if background updates are needed
            BOOL shouldRunLocationUpdates = NO;
            int i = 0;
            while (! shouldRunLocationUpdates && i < [UserData instance].tasks.count) {
                Reminder *task = [[UserData instance].tasks objectAtIndex:i];
                
                if (task.isActive) {
                    if (task.weatherTriggers && task.triggerType == weatherTrigger) {
                        shouldRunLocationUpdates = YES;
                    }
                    
                    if (task.locationTriggers && task.triggerType == locationTrigger) {
                        shouldRunLocationUpdates = YES;
                    }
                }
                
                i++;
            }
            [[NSUserDefaults standardUserDefaults] setBool:shouldRunLocationUpdates forKey:USER_DEFAULTS_SHOULD_RUN_LOCATION_UPDATES];
            
            [LocalNotificationManager setNotificationsForAllTasks];
            [self setupActiveDormantArrays];
            
            
            
        } else {
            NSLog(@"ERROR LOADING TASKS");
        }
    }];
    [self setupUI];
  
}

- (void)performLoadTaskSets
{
    
    [[DataManager sharedInstance] loadTaskSetsWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"TASK SETS LOADED");
        if ([objects.firstObject isKindOfClass:[ReminderGroup class]] || objects.count == 0)
            [UserData instance].taskSets = objects;
        
        [self.tableView reloadData];
        [self.groupFilterTableView reloadData];
    }];
}

- (void)performDeleteTask:(Reminder* )task
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DataManager sharedInstance] deleteObject:task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self performLoadTasks];
    }];
    
}

#pragma mark- Keyboard handling

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"KEYBOARD WILL SHOW");
    dateKeyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    /*else if (self.view.frame.origin.y < 0)
     {
     [self setViewMovedUp:NO];
     }*/
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSLog(@"KEYBOARD WILL HIDE");
    dateKeyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    /*if (self.view.frame.origin.y >= 0)
     {
     [self setViewMovedUp:YES];
     }
     else */if (self.view.frame.origin.y < 0)
     {
         [self setViewMovedUp:NO];
     }
}

/*-(void)textFieldDidBeginEditing:(UITextField *)sender
 {
 if  (self.view.frame.origin.y >= 0)
 {
 [self setViewMovedUp:YES];
 }
 }*/

- (void)setViewMovedUp:(BOOL)moveUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (moveUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= (dateKeyboardHeight - FILTER_VIEW_HEIGHT);
    } else {
        // revert back to the normal state.
        rect.origin.y += (dateKeyboardHeight - FILTER_VIEW_HEIGHT);
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark- Configuration Wizard

- (void)configureReminderDuedate:(int)index {
    index -= 100;
    NSString *date = [self.configAlert textFieldAtIndex:0].text;
    NSArray *ques = self.configDict[@"questions"];
    for (int i=0; i<[UserData instance].tasks.count; i++) {
        Reminder *task = [[UserData instance].tasks objectAtIndex:i];
        if ([task.key isEqualToString:[ques objectAtIndex:index][@"reminder"]]) {
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            NSLog(@"Set Trigger : %@",[dateFormatter dateFromString:date]);
            if (task.dateTimeTriggers && task.dateTimeTriggers.count) {
                ((DateTimeTrigger *)[task.dateTimeTriggers objectAtIndex:0]).date = [dateFormatter dateFromString:date];
            }
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
        }
    }
    [self.configAlert textFieldAtIndex:0].text = @"";
}

- (void)showConfigurationWindow:(int)tag {
    Reminder *task = [UserData instance].task;
    ReminderGroup *group = task.reminderGroup;//[Utils getTaskGroupNameForId:task.reminderGroupId];
    if (!self.configDict) {
        NSString *configData = group.configJSON;
        NSData *jsonData = [configData dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            self.configDict = [NSJSONSerialization
                               JSONObjectWithData:jsonData
                               options:kNilOptions
                               error:nil];
        }
        NSLog(@"Configuration : %@",self.configDict);
    }
    int index = tag-100;
    NSArray *ques = self.configDict[@"questions"];
    if (index < [ques count]){
        if (!self.configAlert) {
            self.configAlert = [[UIAlertView alloc] initWithTitle:@"Provide your Due Date" message:[NSString stringWithFormat:@"The %@ will use this to determine the specific dates for your checklist items",group.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [self.configAlert setTitle:[ques objectAtIndex:index][@"text"]];
        } else {
            [self.configAlert setTitle:[ques objectAtIndex:index][@"text"]];
        }
        self.configAlert.tag = tag;
        NSLog(@"Config Alert : %ld",(long)self.configAlert.tag);
        self.configAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        self.configPicker = [[UIDatePicker alloc] init];
        [self.configPicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [self.configPicker addTarget:self action:@selector(updateConfigField:) forControlEvents:UIControlEventValueChanged];
        [[self.configAlert textFieldAtIndex:0] setInputView:self.configPicker];
        
        [self.configAlert show];
    }else {
        group.configJSON = nil;
        NSMutableArray *configuredTasks = [[NSMutableArray alloc] initWithObjects:group, nil];
        for (int i=0; i<[UserData instance].tasks.count; i++) {
            Reminder *task = [[UserData instance].tasks objectAtIndex:i];
            if ([task.reminderGroup.objectId isEqualToString:group.objectId]) {
                [configuredTasks addObject:task];
            }
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DataManager sharedInstance] saveReminders:configuredTasks withBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }else {
                [Utils showSimpleAlertViewWithTitle:@"Error" content:@"An error occured while saving the data" andDelegate:nil];
            }
        }];
    }
}

- (void)updateConfigField:(UIDatePicker *)picker {
    if (self.configAlert) {
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [self.configAlert textFieldAtIndex:0].text = [dateFormatter stringFromDate:picker.date];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
}


#pragma mark- End of life cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@interface UINavigationItem(MultipleButtonsAddition)
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* rightBarButtonItemsCollection;
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* leftBarButtonItemsCollection;
@end

@implementation UINavigationItem(MultipleButtonsAddition)

- (void) setRightBarButtonItemsCollection:(NSArray *)rightBarButtonItemsCollection {
    self.rightBarButtonItems = [rightBarButtonItemsCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
}

- (void) setLeftBarButtonItemsCollection:(NSArray *)leftBarButtonItemsCollection {
    self.leftBarButtonItems = [leftBarButtonItemsCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
}

- (NSArray*) rightBarButtonItemsCollection {
    return self.rightBarButtonItems;
}

- (NSArray*) leftBarButtonItemsCollection {
    return self.leftBarButtonItems;
}

@end
