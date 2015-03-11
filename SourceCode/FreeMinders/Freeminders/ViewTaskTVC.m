//
//  ViewTaskTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 4/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "ViewTaskTVC.h"
#import "UserData.h"
#import "ReminderGroup.h"
#import "ReminderStep.h"
#import "Utils.h"
#import "Reminder.h"
#import "LocalNotificationManager.h"
#import "DataManager.h"

@interface ViewTaskTVC ()

@property (weak, nonatomic) IBOutlet UIImageView *triggerImageView;
@property (weak, nonatomic) IBOutlet UILabel *triggerLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *snoozeView;
@property (weak, nonatomic) IBOutlet UIView *snoozeRoundedRectangleView;
@property (weak, nonatomic) IBOutlet UIButton *snoozeHourButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeMorningButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeTonightButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeDayButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeWeekButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeDateButton;

@property (strong, nonatomic) NSMutableArray *activeTasks;
@property (strong, nonatomic) NSMutableArray *scheduledTasks;
@property (strong, nonatomic) NSMutableArray *dormantTasks;

@property (nonatomic)TaskStatus taskStatus;

@property (strong, nonatomic) UIView *actionMenu;

@end

@implementation ViewTaskTVC

NSString *SEGUE_EDIT_TASK = @"editTask", *SEGUE_STEP_DETAILS =@"stepDetails";
NSInteger SECTION_GROUP = 2, SECTION_TRIGGER = 5, SECTION_STEP = 3, SECTION_NOTES = 6;

UITextField *snoozeTextField;
bool isEnable;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    self.typeLabel.text = [UserData instance].task.isStoreTask?@"Downloaded":@"User Created";
    
    [self setupSnoozeViewInitially];
    [self setupDatePickers];
    
//    NSString *string=[UserData instance].task.name;
//    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName:@"Helvetica" size: 17]];
//    txtSz.width +=20;
//    CGRect lblFrame = CGRectMake(10 , 0 , txtSz.width, txtSz.height + 20);
//    int lineCount = txtSz.width/280;
//    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
//    strCount /= [@"\n" length];
//    if(txtSz.width > 280)
//    {
//        lineCount += 1;
//        lblFrame = CGRectMake(10, 0 , 280, txtSz.height*(lineCount+strCount + 1));
//    }
//    self.titleLabel.numberOfLines=0;
//    [self.titleLabel setFrame:CGRectMake(10, 0, 300, lblFrame.size.height)];
//    self.titleLabel.text = [UserData instance].task.name;

/*    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UserData instance].task.triggerType == datetimeTrigger) {
        [self.triggerImageView setImage:[UIImage imageNamed:@"reminder_date_time_icon_active_blue.png"]];
        //self.triggerLabel.text = @"Date/Time";
        [self setTriggerText];
    } else if ([UserData instance].task.triggerType == weatherTrigger) {
        [self.triggerImageView setImage:[UIImage imageNamed:@"reminder_weather_icon_active_blue.png"]];
       // self.triggerLabel.text = @"Weather";
        [self setTriggerText];
    } else if ([UserData instance].task.triggerType == locationTrigger) {
        [self.triggerImageView setImage:[UIImage imageNamed:@"reminder_location_icon_active_blue.png"]];
        //self.triggerLabel.text = @"Location";
        [self setTriggerText];
    } else {
          [self.triggerImageView setImage:[UIImage imageNamed:@"reminder_notrigger_active.png"]];
          [self setTriggerText];
    }
//    if([Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].name.length > 0)
//    {
//    NSString *string= [Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].name;
//    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName:@"Helvetica" size: 17]];
//    txtSz.width +=20;
//    CGRect lblFrame = CGRectMake(10 , 0 , txtSz.width,txtSz.height + 20);
//    int lineCount = txtSz.width/280;
//    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
//    strCount /= [@"\n" length];
//    if(txtSz.width > 280)
//    {
//        lineCount += 1;
//        lblFrame = CGRectMake(10, 0 , 280, txtSz.height*(lineCount+strCount + 1));
//    }
//    self.groupLabel.frame=CGRectMake(10, 0, 300, lblFrame.size.height);
//    self.groupLabel.numberOfLines=lineCount;
//    }else
//    {
//        self.groupLabel.frame=CGRectMake(10, 0, 300, 44);
//        self.groupLabel.numberOfLines=1;
//    }
//    self.groupLabel.text = [Utils getTaskGroupNameForId:task.reminderGroupId].name.length?[Utils getTaskGroupNameForId:task.reminderGroupId].name:@"none";
    
    Reminder *task = [UserData instance].task;

    NSString *status;
    if (task.isActive
        && (task.lastNotificationDate || task.triggerType == noTrigger)
        && (! task.snoozedUntilDate || ! [Utils isDateInFuture:task.snoozedUntilDate])) {
        status = @"Active";
        self.taskStatus = taskStateActive;
    } else if (task.isActive) {
        status = @"Scheduled";
        self.taskStatus = taskStateScheduled;
    } else {
        status = @"Inactive";
        self.taskStatus = taskStateInactive;
    }
     self.statusLabel.text = status;
    [self setUpUiForbuttons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //self.navigationItem.title = @"Details";//[UserData instance].task.title;
    
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
//    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
//    [[mainWindow viewWithTag:119] removeFromSuperview];
    [_actionMenu removeFromSuperview];
    [self.snoozeView removeFromSuperview];
    [super viewWillDisappear:animated];
}

#pragma mark- UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_TRIGGER) {
       return [super tableView:tableView numberOfRowsInSection:section];
    } else if (section == SECTION_STEP) {
        return [UserData instance].task.reminderSteps.count > 4 ? 4 : [UserData instance].task.reminderSteps.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    }else if (section == SECTION_TRIGGER) {
       return  [super tableView:tableView heightForHeaderInSection:section];
    } else if (section == SECTION_STEP) {
        return [UserData instance].task.reminderSteps > 0 ? [super tableView:tableView heightForHeaderInSection:section] : 0.0;
    }else if (section == SECTION_NOTES){
        return [UserData instance].task.note.length > 0 ? [super tableView:tableView heightForHeaderInSection:section] : 0.0;
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section== 0){
        return [self reminderNameShowingWithSize];
    }else if (indexPath.section ==  SECTION_STEP) {
        return [self heightForStepCellAtIndexPath:indexPath];
    }else if(indexPath.section == SECTION_NOTES){
        return [self heightForNotesCellAtIndexPath:indexPath];
    }else if(indexPath.section == SECTION_GROUP){
        return [self reminderGroupNameShowingWithSize];
    }else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)heightForStepCellAtIndexPath:(NSIndexPath *)indexPath
{
//    ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:indexPath.row];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    textView.text = @"Single line Text";//step.name;
    textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0f];
    [textView sizeToFit];
    
    return textView.frame.size.height;
}
- (CGFloat)heightForNotesCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *note = [UserData instance].task.note;
    if(note.length > 0){
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        textView.text = note;
        textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0f];
        [textView sizeToFit];
        float hgt = textView.frame.size.height;
        return hgt + 10;
    }
    return 0;
}
-(CGFloat)reminderGroupNameShowingWithSize
{
    if([UserData instance].task.reminderGroup.name.length > 0)//([Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].name.length > 0)
    {
        NSString *string= [UserData instance].task.reminderGroup.name;//[Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].name;
        CGSize txtSz = [string sizeWithFont:[UIFont fontWithName:@"Helvetica" size: 17]];
        txtSz.width +=20;
        CGRect lblFrame = CGRectMake(10 , 0 , txtSz.width,txtSz.height + 20);
        int lineCount = txtSz.width/260;
        long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
        strCount /= [@"\n" length];
        if(txtSz.width > 260)
        {
            lineCount += 1;
            lblFrame = CGRectMake(10, 0 , 280, txtSz.height * (lineCount+strCount + 1));
        }
        if(lineCount > 1)
        {
            return lblFrame.size.height +10;
            
        }else{
            return lblFrame.size.height;
        }
    }else{
        return 44;
    }
}
-(CGFloat)reminderNameShowingWithSize
{
    NSString *string= [UserData instance].task.name;
    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName:@"Helvetica" size: 17]];
    txtSz.width +=20;
    CGRect lblFrame = CGRectMake(10 , 0 , txtSz.width,txtSz.height + 20);
    int lineCount = txtSz.width/260;
    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
    strCount /= [@"\n" length];
    if(txtSz.width > 260)
    {
        lineCount += 1;
        lblFrame = CGRectMake(10, 0 , 280, txtSz.height*(lineCount+strCount + 1));
    }
    
    return lblFrame.size.height +10;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0)
    {
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if ( ! cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text = [UserData instance].task.name;
        return cell;
        }
    if(section == SECTION_GROUP)
    {
        static NSString *cellIdentifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if ( ! cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = COLOR_FREEMINDER_BLUE;
        cell.textLabel.text = [UserData instance].task.reminderGroup.name.length?[UserData instance].task.reminderGroup.name:@"none";
//        cell.textLabel.text = [Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].name.length?[Utils getTaskGroupNameForId:[UserData instance].task.reminderGroupId].name:@"none";
//        cell.textLabel.textAlignment=NSTextAlignmentCenter;

        return cell;
    }
    if (section == SECTION_STEP) {
        static NSString *cellIdentifier = @"stepCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if ( ! cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:row];
        cell.textLabel.text = [NSString stringWithFormat:@"%i. %@", (int) (row + 1),step.name];
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0];
        cell.textLabel.textColor = COLOR_FREEMINDER_BLUE;
        cell.textLabel.numberOfLines = 0;
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i. %@", (int) (row + 1),step.name]];
        if(step.isComplete)
        {
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@1
                                    range:NSMakeRange(0, [attributeString length])];
            cell.textLabel.attributedText = attributeString;
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }else
        {
            [attributeString removeAttribute:NSStrikethroughStyleAttributeName range:NSMakeRange(0, [attributeString length])];
             cell.textLabel.attributedText = attributeString;
        }
        return cell;
    }else if(section == SECTION_TRIGGER){
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    }else if(indexPath.section == SECTION_NOTES){
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = [UserData instance].task.note;
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0];
        cell.textLabel.textColor = COLOR_FREEMINDER_BLUE;
        cell.textLabel.numberOfLines = 0;
//       [cell.textLabel sizeToFit];
        return cell;
    }
    else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == SECTION_STEP) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_STEP)
    {
        [self performSegueWithIdentifier: SEGUE_STEP_DETAILS sender:self];
    }
}

- (void)setTriggerText {
    
    self.triggerLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0];
    self.triggerLabel.textColor = COLOR_FREEMINDER_BLUE;
    self.triggerLabel.numberOfLines = 3;
    if (/*((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date*/ [UserData instance].task.triggerType == datetimeTrigger && [UserData instance].task.dateTimeTriggers.count) {
        NSString *DATETIME_FORMAT = @"EEEE MMM dd, yyyy h:mma";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DATETIME_FORMAT];
        self.triggerLabel.text = [dateFormatter stringFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date];
    }else if (/*((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address */ [UserData instance].task.triggerType == locationTrigger && [UserData instance].task.locationTriggers.count) {
        if ([((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address isEqualToString:@"Your Location"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mma 'on' MMMM dd yyyy"];
            self.triggerLabel.text = [NSString stringWithFormat:@"Your Location at %@",[formatter stringFromDate:[UserData instance].task.createdAt]];
        }
        else
            self.triggerLabel.text = [NSString stringWithFormat:@"When near %@",((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address];
    }else if ([UserData instance].task.triggerType == weatherTrigger && [UserData instance].task.weatherTriggers.count){
        Reminder *task = [UserData instance].task;
        bool weatherCondition=0;
        WeatherTrigger *weather = [task.weatherTriggers objectAtIndex:0];
        NSMutableString *string;
        NSString *daysBefore = [NSString stringWithFormat:@"%@",[weather.notifyDays intValue] > 0?[NSString stringWithFormat:@"%d %@",[weather.notifyDays intValue],[weather.notifyDays intValue]== 1?@"Day before":@"Days before"]:@"On the Day which"];
        
        string = [[NSMutableString alloc] initWithFormat:@"%d:%@ %@ %@ ",[weather.notifyHour intValue],([weather.notifyMin intValue]>10?weather.notifyMin:[NSString stringWithFormat:@"0%d",[weather.notifyMin intValue]]),weather.notifyAmPm,daysBefore];
        if (weather.isPrecipitation || weather.isDrizzleOption || weather.isRainOption || weather.isLightTStormsOption || weather.isTStormsOption || weather.isSevereTStormsOption) {
            
            if(!weatherCondition)
            {
                weatherCondition=1;
                [string appendString:@"1 or more "];
            }
            [string appendString:@"Precipitation or "];
        }
        if (weather.isFreezing || weather.isFreezingDrizzleOption || weather.isFreezingRainOption || weather.isSleetOption || weather.isSnowFlurriesOption || weather.isLightSnowOption || weather.isSnowOption || weather.isHeavySnowOption) {
            if(!weatherCondition)
            {
                weatherCondition=1;
                [string appendString:@"1 or more "];
            }
            [string appendString:@"Freezing or "];
        }
        if (weather.isSevere || weather.isSevereStormOption || weather.isTropicalStormOption || weather.isHurricaneOption || weather.isTornadoOption || weather.isHailOption) {
            if(!weatherCondition)
            {
                weatherCondition=1;
                [string appendString:@"1 or more "];
            }
            [string appendString:@"Severe or "];
        }
        if (weather.isSkyline || weather.isSunnyOption || weather.isPartiallyCloudyOption || weather.isCloudyOption) {
            if(!weatherCondition)
            {
                weatherCondition=1;
                [string appendString:@"1 or more "];
            }
            [string appendString:@"Skyline or "];
        }
        if (weather.isWind || weather.isWindyOption || weather.isBlusteryOption) {
            if(!weatherCondition)
            {
                weatherCondition=1;
                [string appendString:@"1 or more"];
            }
            [string appendString:@"Wind or "];
        }
        if(weatherCondition)
        {
            [string appendString:@"conditions occur."];
            NSString *immutableString = [NSString stringWithString:string];
            NSRange lastOr = [immutableString rangeOfString:@"or " options:NSBackwardsSearch];
            if(lastOr.location != NSNotFound) {
                immutableString = [immutableString stringByReplacingCharactersInRange:lastOr
                                                                           withString: @""];
            }
            string =[immutableString mutableCopy];
        }
        if (weather.isTemperature) {
            weatherCondition=1;
            [string appendString:@" has been predicted and when temperature "];
           [string appendString:weather.isAlertAboveTemp?[NSString stringWithFormat:@"above %d %@",[weather.temperature intValue],[NSString stringWithFormat:@"%@",[[UserData instance].userSettings.temperatureType isEqualToString:@"Fahrenheit"] ? @"Fahrenheit":@"degrees"]]:[NSString stringWithFormat:@"below %d %@ ",[weather.temperature intValue],[NSString stringWithFormat:@"%@",[[UserData instance].userSettings.temperatureType isEqualToString:@"Fahrenheit"] ? @"Fahrenheit":@"degrees"]]];
        }
        if(!weatherCondition)
            string  = [NSMutableString stringWithFormat:@"Please specify at least 1 weather condition above."];
           
        self.triggerLabel.text = string;
        self.triggerLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:11.0];
       }
    else if([UserData instance].task.triggerType == noTrigger)
    {
         NSString *DATETIME_FORMAT = @"EEEE MMM dd, yyyy h:mma";
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:DATETIME_FORMAT];
         self.triggerLabel.text=[dateFormatter stringFromDate:[UserData instance].task.createdAt];
    }
    if ([UserData instance].task.isDependentOnParent && ![Utils checkForOtherParentStatus:[UserData instance].task.parentReminders]) {
        Reminder *tsk = [UserData instance].task;
        int time = [tsk.timeAfterParent intValue];
        NSString *unit = time>1?tsk.timeAfterUnit:[tsk.timeAfterUnit stringByPaddingToLength:tsk.timeAfterUnit.length-1 withString:@"" startingAtIndex:0];
        self.triggerLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:12.0];
        self.triggerLabel.text = [NSString stringWithFormat:@"Due %d %@ after reminder ‘%@’ is completed",time,unit,[Utils getParentReminderNames:tsk]];
        if (time == 0)
            self.triggerLabel.text = [NSString stringWithFormat:@"Due when reminder ‘%@’ is completed",[Utils getParentReminderNames:tsk]];
    }
}


-(void)setUpUiForbuttons
{
    _actionMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 54)];
    _actionMenu.backgroundColor = [UIColor whiteColor];
    if(self.taskStatus == taskStateActive)
    {
        UIButton *doneButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 1, 63, 54)];
        doneButton.imageView.frame = CGRectMake(0, 0, 56, 54);
        doneButton.imageView.center = doneButton.center;
        [doneButton setImage:[UIImage imageNamed:@"slide_right_done_icon.png"]
                              forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:doneButton];
        
        
        UIButton *snoozeButton =[[UIButton alloc]initWithFrame:CGRectMake(64, 1, 63, 54)];
        
        [snoozeButton setImage:[UIImage imageNamed:@"slide_left_snooze_icon@2x.png"]
                                forState:UIControlStateNormal];
        [snoozeButton addTarget:self action:@selector(snoozeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:snoozeButton];
        
        
        UIButton *editButton =[[UIButton alloc]initWithFrame:CGRectMake(128, 1, 63, 54)];
        
        [editButton setImage:[UIImage imageNamed:@"slide_left_edit_icon@2x.png"]
                              forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:editButton];
        
        
        UIButton *disableButton =[[UIButton alloc]initWithFrame:CGRectMake(192, 1,63, 54)];
        
        [disableButton setImage:[UIImage imageNamed:@"slide_left_disable_icon@2x.png"]
                                 forState:UIControlStateNormal];
        [disableButton addTarget:self action:@selector(disableButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:disableButton];
        
        UIButton *deleteButton =[[UIButton alloc]initWithFrame:CGRectMake(256, 1,63, 54)];
        
        [deleteButton setImage:[UIImage imageNamed:@"slide_left_delete_icon@2x.png"]
                                forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:deleteButton];
        
    }
    else if(self.taskStatus == taskStateScheduled)
    {
        CGRect rect = CGRectMake(0, 1, 56, 54);
        CGPoint center;
        UIButton *activateButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 1, 79, 54)];
        center = activateButton.center;
        activateButton.frame = rect;
        activateButton.center = center;
        [activateButton setImage:[UIImage imageNamed:@"activate_icon@2x.png"]
                                  forState:UIControlStateNormal];
        [activateButton addTarget:self action:@selector(activateButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:activateButton];
        
        UIButton *editButton =[[UIButton alloc]initWithFrame:CGRectMake(80, 1, 79, 54)];
        rect = CGRectMake(80, 1, 56, 54);
        center = editButton.center;
        editButton.frame = rect;
        editButton.center = center;
        [editButton setImage:[UIImage imageNamed:@"slide_left_edit_icon@2x.png"]
                              forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:editButton];
        
        UIButton *disableButton =[[UIButton alloc]initWithFrame:CGRectMake(160, 1, 79, 54)];
        rect = CGRectMake(160, 1, 56, 54);
        center = disableButton.center;
        disableButton.frame = rect;
        disableButton.center = center;
        [disableButton setImage:[UIImage imageNamed:@"slide_left_disable_icon@2x.png"]
                                 forState:UIControlStateNormal];
        [disableButton addTarget:self action:@selector(disableButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:disableButton];
        
        UIButton *deleteButton =[[UIButton alloc]initWithFrame:CGRectMake(240, 1,79, 54)];
        rect = CGRectMake(240, 1, 56, 54);
        center = deleteButton.center;
        deleteButton.frame = rect;
        deleteButton.center = center;
        [deleteButton setImage:[UIImage imageNamed:@"slide_left_delete_icon@2x.png"]
                                forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:deleteButton];
    }
    else if (self.taskStatus == taskStateInactive)
    {
        CGRect rect = CGRectMake(0, 1, 56, 54);
        CGPoint center;

        UIButton *enableButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 1, 108, 54)];
        center = enableButton.center;
        enableButton.frame = rect;
        enableButton.center = center;
        [enableButton setImage:[UIImage imageNamed:@"enable-icon@2x.png"]
                      forState:UIControlStateNormal];
        [enableButton addTarget:self action:@selector(disableButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:enableButton];
        
        UIButton *editButton =[[UIButton alloc]initWithFrame:CGRectMake(110, 1, 108, 54)];
        rect = CGRectMake(110, 1, 56, 54);
        center = editButton.center;
        editButton.frame = rect;
        editButton.center = center;
        [editButton setImage:[UIImage imageNamed:@"slide_left_edit_icon@2x.png"]
                              forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:editButton];
        
        
        UIButton *deleteButton =[[UIButton alloc]initWithFrame:CGRectMake(220, 1, 108, 54)];
        rect = CGRectMake(220, 1, 56, 54);
        center = deleteButton.center;
        deleteButton.frame = rect;
        deleteButton.center = center;
        [deleteButton setImage:[UIImage imageNamed:@"slide_left_delete_icon@2x.png"]
                                forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_actionMenu addSubview:deleteButton];
    }
//    self.tableView.tableFooterView = _actionMenu;
    _actionMenu.tag = 119;
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = _actionMenu.frame;
    rect.origin.y = mainWindow.frame.size.height - rect.size.height;
    _actionMenu.frame = rect;
    [mainWindow addSubview: _actionMenu];
    NSLog(@"FRAME : %@",NSStringFromCGRect(mainWindow.frame));
    NSLog(@"FRAME : %@",NSStringFromCGRect(self.view.frame));
}


- (void)setupSnoozeViewInitially
{
    self.snoozeRoundedRectangleView.layer.cornerRadius = 5.0;
    
    UIView *overLay = [[UIView alloc] initWithFrame:CGRectMake(0, self.snoozeView.frame.size.height, 320, 100)];
    overLay.backgroundColor = self.snoozeView.backgroundColor;
    overLay.userInteractionEnabled = YES;
    [self.snoozeView addSubview:overLay];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSnoozeView)];
    [self.snoozeView addGestureRecognizer:tap];
}

- (void)setupDatePickers
{

    // Date filter picker
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // Snooze date picker
    UIToolbar *snoozePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *snoozeDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self action:@selector(snoozePickerDone)];
    [snoozePickerToolbar setItems:[NSArray arrayWithObjects:spaceItem, snoozeDoneButton, nil] animated:NO];
    
    snoozeDatePicker = [[UIDatePicker alloc] init];
    [snoozeDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    snoozeDatePicker.minimumDate = [NSDate date];
    snoozeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:snoozeTextField];
    snoozeTextField.inputView = snoozeDatePicker;
    snoozeTextField.inputAccessoryView = snoozePickerToolbar;
}

- (void)snoozePickerDone
{
    [UserData instance].task.snoozedUntilDate = snoozeDatePicker.date;
    [snoozeTextField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] saveReminder:[UserData instance].task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
}

//snoze button action
-(void)snoozeButtonAction
{
//    self.tableView.hidden = YES;
    self.snoozeView.hidden = NO;
    CGPoint point = self.view.center;
    point.y -= 32;
    self.snoozeView.center = point;
//    [self.view bringSubviewToFront:self.snoozeView];
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:self.snoozeView];
    [mainWindow bringSubviewToFront:self.snoozeView];
//    [mainWindow sendSubviewToBack:self.actionMenu];
}
- (void)hideSnoozeView{
    [self.snoozeView removeFromSuperview];
}

- (IBAction)snoozeButtonPressed:(UIButton *)button
{
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *snoozeDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
    BOOL showPicker = NO;
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
        if ([morningDate compare:[UserData instance].task.snoozedUntilDate] == NSOrderedDescending) { // if it's after 8am, set alarm for tomorrow morning
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
        if ([toNightDate compare:[UserData instance].task.snoozedUntilDate] == NSOrderedDescending) { // if it's after the time set for, set alarm for tomorrow
            [UserData instance].task.snoozedUntilDate = [[UserData instance].task.snoozedUntilDate dateByAddingTimeInterval:SECONDS_PER_DAY];
        }
    } else if (button == self.snoozeDayButton) {
        [UserData instance].task.snoozedUntilDate = [[NSDate date] dateByAddingTimeInterval:SECONDS_PER_DAY];
    } else if (button == self.snoozeWeekButton) {
        [UserData instance].task.snoozedUntilDate = [[NSDate date] dateByAddingTimeInterval:SECONDS_PER_WEEK];
    } else if (button == self.snoozeDateButton) {
        showPicker = YES;
        [UserData instance].task.snoozedUntilDate = nil;
        [snoozeTextField becomeFirstResponder];
    }
    if (!showPicker) {
        //    [[UserData instance].task saveInBackground];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DataManager sharedInstance] saveReminder:[UserData instance].task withBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];

        }];
    }
    self.snoozeView.hidden = YES;
    [self.snoozeView removeFromSuperview];
}


//edit button action
-(void)editButtonAction
{
    //    [UserData instance].task = task;
    [self performSegueWithIdentifier:SEGUE_EDIT_TASK sender:self];
    
}
// done button action
-(void)doneButtonAction
{
    Reminder *task=[UserData instance].task;
    
    if (task.triggerType == noTrigger) {
        task.isActive = ! task.isActive;
    } else if (task.lastNotificationDate) { // mark complete
        task.lastNotificationDate = nil;
        task.lastCompletionDate = [NSDate date];
        
        BOOL shouldGoToScheduledTasks = NO;
        if (task.dateTimeTriggers && task.dateTimeTriggers.count && (! [[task.dateTimeTriggers objectAtIndex:0] isDataAvailable] || ((DateTimeTrigger *)[task.dateTimeTriggers objectAtIndex:0]).isRepeating))
            shouldGoToScheduledTasks = YES;
        else if (task.weatherTriggers && task.weatherTriggers.count && (! [[task.weatherTriggers objectAtIndex:0] isDataAvailable] || ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isRepeat))
            shouldGoToScheduledTasks = YES;
        else if (task.locationTriggers && task.locationTriggers.count && (! [[task.locationTriggers objectAtIndex:0] isDataAvailable] || ((LocationTrigger *)[task.locationTriggers objectAtIndex:0]).isRepeat))
            shouldGoToScheduledTasks = YES;
        
        task.isActive = shouldGoToScheduledTasks;
        if (task.isDependent)
            [Utils scheduleDependentReminders:task];
    } else {
        task.lastNotificationDate = [NSDate date];
    }
    
    [[DataManager sharedInstance] saveReminder:task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
-(IBAction)cancelButtonAction
{
   [self.navigationController popViewControllerAnimated:YES];   
}
//disable Button Action
-(void)disableButtonAction
{
    Reminder *task=[UserData instance].task;
    [self enableOrDisableTask:task];
//    if (task.isActive){
//       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Are you sure You want to disable this reminder \"%@\"?",task.name]delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
//        alertView.tag = disableAlert;
//        [alertView show];
//       
//    } else{
//        
//        isEnable=1;
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Are you sure You want to enable this reminder \"%@\"?",task.name]delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
//        alertView.tag = disableAlert;
//        [alertView show];
//        
//    }
}
//delete Button Action
-(void)deleteButtonAction
{
    NSString *msg;
    if ([UserData instance].task.isDependent && ![UserData instance].task.isDependentOnParent) {
        msg = [NSString stringWithFormat:@"Deleting this reminder may prevent other reminders from activating without user intervention. Are you sure you would like to continue and delete the \"%@\" reminder?",[UserData instance].task.name];
    }else{
        msg = [NSString stringWithFormat:@"Are you sure you want to delete the reminder \"%@\"? This cannot be undone.",[UserData instance].task.name];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = deleteAlert;
    [alertView show];
}

//activate Button Action
-(void)activateButtonAction
{
    Reminder *task=[UserData instance].task;
    task.snoozedUntilDate = nil;
    task.isActive = YES;
    [task setAllStepsChecked:NO];
    task.lastNotificationDate = [NSDate date];
//    [task save];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] saveReminder:task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)performDeleteTask:(Reminder* )task
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] deleteReminder:task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
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
        [self.navigationController popViewControllerAnimated:YES];
    }];

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    Reminder *task=[UserData instance].task;
    if (buttonIndex == 1) {
//        if (alertView.tag == disableAlert) {
//            [self enableOrDisableTask:task];
//        }
//        else if(isEnable && alertView.tag == deleteAlert)
//        {
//            [self enableOrDisableTask:task];
//            isEnable=0;
//        }
        if (alertView.tag == deleteAlert){
            [self performDeleteTask:task];
        }
    }
}


#pragma mark- end of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
