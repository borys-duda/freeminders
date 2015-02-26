//
//  StepDetailsTVC.m
//  Freeminders
//
//  Created by Vegunta's on 11/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//
#define countTimers  1
#define stopTimers   0

#import "StepDetailsTVC.h"
#import "UserData.h"
#import "ReminderGroup.h"
#import "ReminderStep.h"
#import "AddEditTaskTVC.h"
#import "Utils.h"
#import <AVFoundation/AVFoundation.h>
#import "DataManager.h"

@interface StepDetailsTVC ()

@property (strong,nonatomic)  UIView *actionMenu;
@property (nonatomic) BOOL isChecked;
@property (nonatomic) BOOL isCheckedButtonPressed;
@property (nonatomic) BOOL isDone;
@property (strong,nonatomic) UIButton  *timeLabel;
@property (strong,nonatomic)  UIButton *timerStart;
@property (strong,nonatomic)  UIButton *timerReset;
@property (strong,nonatomic)  UIBarButtonItem *timerDown;
@property (strong,nonatomic)  UIBarButtonItem *timerCount;


@property (strong,nonatomic) UIButton *stepCounter;
@property (strong,nonatomic) UIButton *stepStopTimerWatch;


@end

@implementation StepDetailsTVC

NSInteger  SECTION_STEPDETAILS = 0;
NSString *SEGU_EDIT_TASKS=@"edittaskfromstepdetails";


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
    self.title = @"Steps";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self gettingStepDetailsTimerValues];
    [self  setActionViewButtons];
    [self setupPickerView];
    if([timerType intValue])
        [self didSelectTimerType:self.stepCounter];
    else
        [self didSelectTimerType:self.stepStopTimerWatch];

}
-(void)gettingStepDetailsTimerValues
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepTimers"];
    NSDictionary *timerDetails = (dict && [dict objectForKey:[UserData instance].task.objectId])?[NSMutableDictionary dictionaryWithDictionary:dict[[UserData instance].task.objectId]]:[[NSMutableDictionary alloc] init];
    
    NSLog(@"%@",timerDetails);
    
    startDate=[timerDetails objectForKey:@"startDate"];
    timerType = [timerDetails objectForKey:@"timerType"];
    timerIntervel=[timerDetails objectForKey:@"intervel"];
    timerIntervelForCountdown=[timerDetails objectForKey:@"timerIntervel"];
}
-(void)setActionViewButtons
{
 
    self.actionMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44)];
    self.actionMenu.backgroundColor = [UIColor whiteColor];
    
    self.stepStopTimerWatch =[[UIButton alloc]initWithFrame:CGRectMake(10,5,35, 35)];
//    [self.stepStopTimerWatch setImage:[UIImage imageNamed:@"steps_stopwatch_white.png"] forState:UIControlStateSelected];
    [self.stepStopTimerWatch setImage:[UIImage imageNamed:@"steps_stopwatch_blue.png"] forState:UIControlStateNormal];
    self.stepStopTimerWatch.selected=YES;
    [self.stepStopTimerWatch addTarget:self action:@selector(didSelectTimerTypeSecondTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:self.stepStopTimerWatch];

     self.timerStart =[[UIButton alloc] initWithFrame:CGRectMake(50 ,7 ,55, 30)];
    [self.timerStart setTitle:@"Start" forState:UIControlStateNormal];
    [self.timerStart setTitle:@"Stop" forState:UIControlStateSelected];
    [self.timerStart setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
    [self.timerStart addTarget:self action:@selector(startPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:self.timerStart];
   
     self.timeLabel =[[UIButton alloc] initWithFrame:CGRectMake(110,7,100, 30)];
    [self.timeLabel setTitle:@"00:00:00.0" forState:UIControlStateNormal];
    [self.timeLabel setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
    [self.timeLabel addTarget:self action:@selector(setTimePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:self.timeLabel];//setTimePressed

    self.timerReset =[[UIButton alloc] initWithFrame:CGRectMake(210,7,50, 30)];
    [self.timerReset setTitle:@"Reset" forState:UIControlStateNormal];
    [self.timerReset setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
    [self.timerReset addTarget:self action:@selector(resetPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:self.timerReset];//resetPressed
    
    UIImage *downImage = [UIImage imageNamed:@"steps_countdown_blue.png"];
    self.stepCounter =[[UIButton alloc]initWithFrame:CGRectMake(275,5,35, 35)];
    [self.stepCounter setImage:downImage forState:UIControlStateNormal];
    [self.stepCounter setImage:[UIImage imageNamed:@"steps_countdown_white.png"] forState:UIControlStateSelected];
    [self.stepCounter addTarget:self action:@selector(didSelectTimerTypeSecondTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionMenu addSubview:self.stepCounter];
    
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect actionmenurect = _actionMenu.frame;
    actionmenurect.origin.y = mainWindow.frame.size.height - actionmenurect.size.height;
    _actionMenu.frame = actionmenurect;
    [mainWindow addSubview: _actionMenu];
    NSLog(@"FRAME : %@",NSStringFromCGRect(mainWindow.frame));
    NSLog(@"FRAME : %@",NSStringFromCGRect(self.view.frame));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview: _actionMenu];
//    remCopy = [[UserData instance].task copy];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:SEGU_EDIT_TASKS]){
        AddEditTaskTVC *controller = (AddEditTaskTVC *)segue.destinationViewController;
        controller.isFromSteps = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
//    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setToolbarHidden:YES animated:YES];
     [self.actionMenu removeFromSuperview];
}
- (IBAction)cancelButtonPressed
{
//    [UserData instance].task = remCopy;
    [self isruning];
    [self savingInNSUserDeFaults];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveButtonAction
{
    for (int i=0; i< [UserData instance].task.reminderSteps.count; i++) {
        ((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:i]).order = [NSNumber numberWithInt:i];
    }
    [self isruning];
    [self savingInNSUserDeFaults];
     NSMutableArray * arry =[NSMutableArray arrayWithArray:[UserData instance].task.reminderSteps];
    [arry addObject:[UserData instance].task];
//    [PFObject saveAllInBackground:arry];
    [[DataManager sharedInstance] saveDatas:arry];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)editButtonAction
{
    [self performSegueWithIdentifier:SEGU_EDIT_TASKS sender:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_STEPDETAILS) {
        return [UserData instance].task.reminderSteps.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==  SECTION_STEPDETAILS) {
        return [self heightForStepCellAtIndexPath:indexPath];
    }
    return 0;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_STEPDETAILS) {
        return 40;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(section == SECTION_STEPDETAILS)
    {
        
        UIView *stepview =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,40)];
        stepview.userInteractionEnabled=YES;
        stepview.backgroundColor = [UIColor whiteColor];
        UILabel *title =[[UILabel alloc]initWithFrame:CGRectMake(15, 0, 190,40)];
        title.center = stepview.center;
        title.text = [UserData instance].task.name;
        title.textAlignment = NSTextAlignmentCenter;
//        title.font = [UIFont boldSystemFontOfSize:14];
        [stepview addSubview:title];
        
        UIButton *checked = [[UIButton alloc]initWithFrame:CGRectMake(15, 4,50,32)];
        [checked setImage:[UIImage imageNamed:@"step_checked_icon.png"] forState:UIControlStateNormal];
        [checked setImage:[UIImage imageNamed:@"step_unchecked_icon.png"] forState:UIControlStateSelected];
//        [ checked setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
//        [ checked.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [ checked  addTarget:self action:@selector(checkedpressed:) forControlEvents:UIControlEventTouchUpInside];
        [stepview addSubview: checked];
        int count=0;
        for (int i=0; i< [UserData instance].task.reminderSteps.count; i++) {
            ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:i];
            if(step.isComplete)
            {
                count++;
            }
        }
        if(count==[UserData instance].task.reminderSteps.count)
        {
            checked.selected=YES;
        }
        if(self.isChecked)
        {
            checked.selected=YES;
        }
        
        UIButton *editButton =[[UIButton alloc]initWithFrame:CGRectMake(255, 4, 60,32)];
        [editButton setTitle: @"Edit" forState: UIControlStateNormal];
//        [editButton setTitle: @"Done" forState: UIControlStateSelected];
        [editButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
        [editButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        editButton.layer.cornerRadius = 10.0f;
        editButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
        editButton.layer.borderWidth = 1.0f;
        [editButton  addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [stepview addSubview:editButton];
        if(self.isDone)
        {
            editButton.selected=YES;
        }
        return stepview;
        
    }
    return nil;
    
    
}
-(void)checkedpressed:(UIButton *)sender

{
    NSLog(@"checkedpressed");
    
    if(self.tableView)
    {
        _isCheckedButtonPressed=1;
        
        if(!sender.selected)
        {
            sender.selected = !sender.selected;
            for(int i=0; i<[UserData instance].task.reminderSteps.count; i++)
            {
                _isChecked=1;
                [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:SECTION_STEPDETAILS]];
            }
            
        }
        else
        {
            sender.selected=NO;
            for(int i=0; i<[UserData instance].task.reminderSteps.count; i++)
            {
                _isChecked=0;
                [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:SECTION_STEPDETAILS]];
                
            }
            
        }
        
    }
    [self.tableView reloadData];
    _isCheckedButtonPressed=0;
    
    
}
-(void)editButtonpressed:(UIButton *)sender
{
    NSLog(@"EditBUttonpressed");
/*    if(!sender.selected)
    {
        self.isDone=YES;
        sender.selected = !sender.selected;
        [self.tableView setEditing:YES animated:YES];
    }
    else
    {     self.isDone=NO;
        sender.selected = !sender.selected;
        [self.tableView setEditing:NO animated:NO];
        
    }
*/
}


- (CGFloat)heightForStepCellAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:indexPath.row];
    if(!step.isComplete)
    {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
    textView.text = [NSString stringWithFormat:@"%i.%@", (int) (indexPath.row),step.name];
    textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0f];
    [textView sizeToFit];
    
    return textView.frame.size.height;
    }else{
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 265, 50)];
        textView.text = [NSString stringWithFormat:@"%i.%@", (int) (indexPath.row),step.name];
        textView.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0f];
        [textView sizeToFit];
        
        return textView.frame.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == SECTION_STEPDETAILS) {
        static NSString *cellIdentifier = @"stepCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if ( ! cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ReminderStep *step = [[UserData instance].task.reminderSteps objectAtIndex:row];
        cell.textLabel.text = [NSString stringWithFormat:@"%i.%@", (int) (row + 1),step.name];
        cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:17.0];
        cell.textLabel.textColor = COLOR_FREEMINDER_BLUE;
        cell.textLabel.numberOfLines = 0;
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i.%@", (int) (row + 1),step.name]];
        if(step.isComplete)
        {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
            
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@1
                                    range:NSMakeRange(0, [attributeString length])];
            cell.textLabel.attributedText = attributeString;
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }else {
            cell.accessoryType=UITableViewCellAccessoryNone;
            [attributeString removeAttribute:NSStrikethroughStyleAttributeName range:NSMakeRange(0, [attributeString length])];
            cell.textLabel.attributedText = attributeString;
        }
        
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(_isCheckedButtonPressed)
    {
        if(_isChecked)
        {
            if (indexPath.section == SECTION_STEPDETAILS) {
                ((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:indexPath.row]).isComplete=YES;
                newCell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
        }
        else
        {
            if (indexPath.section == SECTION_STEPDETAILS) {
                ((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:indexPath.row]).isComplete=NO;
                newCell.accessoryType=UITableViewCellAccessoryNone;
            }
        }
        
        
    }
    else{
        if (indexPath.section == SECTION_STEPDETAILS) {
            if (newCell.accessoryType == UITableViewCellAccessoryNone) {
                ((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:indexPath.row]).isComplete=YES;
                newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else {
                ((ReminderStep *)[[UserData instance].task.reminderSteps objectAtIndex:indexPath.row]).isComplete=NO;
                newCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        [self.tableView reloadData];
    }
    
}




-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView
          editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (self.tableView.editing) {
        return 0;
    }
    return 0;
}

-(BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_STEPDETAILS) {
        return YES;
    }
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_STEPDETAILS) {
        return YES;
    }
    return NO;}

-(void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
     toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    ReminderStep *itemToMove = [[UserData instance].task.reminderSteps objectAtIndex:sourceIndexPath.row];
    NSMutableArray *stepsArr = [UserData instance].task.reminderSteps;
    [stepsArr removeObjectAtIndex:sourceIndexPath.row];
    [stepsArr insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
    
}
-(NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    if (proposedDestinationIndexPath.section == sourceIndexPath.section) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}



#pragma mark - Timer Logic

-(void)didSelectTimerType:(UIButton *)sender {
    [self.stepStopTimerWatch setImage:[UIImage imageNamed:@"steps_stopwatch_blue.png"] forState:UIControlStateNormal];
    [self.stepCounter setImage:[UIImage imageNamed:@"steps_countdown_blue.png"] forState:UIControlStateNormal];
    if (sender == self.stepStopTimerWatch) {
        [self.stepStopTimerWatch setImage:[UIImage imageNamed:@"steps_stopwatch_white.png"] forState:UIControlStateNormal];
        isStopwatch = YES;
        sender.selected=YES;
        self.stepCounter.selected=NO;
        timerType = [NSNumber numberWithInt:stopTimers];
        if (startDate) {
            stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                         target:self
                                                       selector:@selector(updateTimer)
                                                       userInfo:nil
                                                        repeats:YES];
            self.timerStart.selected=YES;
//            [self.timerReset setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//            [self.timerReset setEnabled:NO];
            [self.stepCounter setEnabled:NO];
            [self.stepStopTimerWatch setEnabled:NO];
            running = YES;
        }else if([timerIntervel doubleValue] > 0)
        {
            startDate=[NSDate date];
            NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:[timerIntervel doubleValue]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm:ss.S"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
            NSString *timeString=[dateFormatter stringFromDate:timerDate];
            [self.timeLabel setTitle:timeString forState:UIControlStateNormal];
            running = NO;
            
        }else {
            [self.timeLabel setTitle:@"00:00:00.0" forState:UIControlStateNormal];
        }
    }else {
        [self.stepCounter setImage:[UIImage imageNamed:@"steps_countdown_white.png"] forState:UIControlStateNormal];
        timerType=[NSNumber numberWithInt:countTimers];
        isStopwatch = NO;
        sender.selected=YES;
        self.stepStopTimerWatch.selected=NO;
        if([timerIntervel intValue] > 0){
            interval=[timerIntervel doubleValue];
            startDate=[NSDate date];
            startDate=[startDate dateByAddingTimeInterval:interval];
//            [self updateCounter:stopTimer];

            NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:interval];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
            NSString *timeString=[dateFormatter stringFromDate:timerDate];
            [self.timeLabel setTitle:timeString forState:UIControlStateNormal];
            running = NO;

        }else if(startDate){
            NSDate *currentDate = [NSDate date];
            NSTimeInterval timeIntervalpresent = [startDate timeIntervalSinceDate:currentDate];
            interval = timeIntervalpresent;
            NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:interval];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
            NSString *timeString=[dateFormatter stringFromDate:timerDate];
            self.timerStart.selected=YES;
//            [self.timerReset setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//            [self.timerReset setEnabled:NO];
            [self.stepCounter setEnabled:NO];
            [self.stepStopTimerWatch setEnabled:NO];
            running = YES;
            if(interval > 0)
            {
              [self.timeLabel setTitle:timeString forState:UIControlStateNormal];
              stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
            }else
                [self updateCounter:stopTimer];

        }else{
            [self.timeLabel setTitle:@"00:00:00" forState:UIControlStateNormal];
            if(interval <= 0)
            {
                interval=[timerIntervelForCountdown doubleValue];
                int hours = interval / 3600;
                int minutes = ((int)interval % 3600) / 60;
                int seconds = ((int)interval % 3600) % 60;
                timerIntervel=[NSNumber numberWithDouble:interval];
                [self.timeLabel setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds] forState:UIControlStateNormal];
            }
        }
        
        
    }
}
-(void)didSelectTimerTypeSecondTime:(UIButton *)sender {
    [self.stepStopTimerWatch setImage:[UIImage imageNamed:@"steps_stopwatch_blue.png"] forState:UIControlStateNormal];
    [self.stepCounter setImage:[UIImage imageNamed:@"steps_countdown_blue.png"] forState:UIControlStateNormal];

    if (sender == self.stepStopTimerWatch) {
        [self.stepStopTimerWatch setImage:[UIImage imageNamed:@"steps_stopwatch_white.png"] forState:UIControlStateNormal];
        isStopwatch = YES;
        sender.selected=YES;
        self.stepCounter.selected=NO;
        timerType = [NSNumber numberWithInt:stopTimers];
    }
    else{
        [self.stepCounter setImage:[UIImage imageNamed:@"steps_countdown_white.png"] forState:UIControlStateNormal];
        timerType=[NSNumber numberWithInt:countTimers];
        isStopwatch = NO;
        sender.selected=YES;
        self.stepStopTimerWatch.selected=NO;
    }
    [self resetPressed:nil];
}
-(void)isruning
{
     if(running){
         timerIntervel= 0;
     }else{
        startDate = nil;
     }
    [stopTimer invalidate];

}
-(void)startTimerWithPresentTime
{
    NSTimeInterval intervals = [timerIntervel doubleValue];
    NSDate *currentDate = [NSDate date];
    startDate=[currentDate dateByAddingTimeInterval:-intervals];
    NSLog(@"step when start timer %ld ",(long)intervals);

}
-(void)startWithPreviousTime
{
    NSTimeInterval diff = [endDate timeIntervalSinceDate:startDate];
    timerIntervel=[NSNumber numberWithDouble:diff];
    NSLog(@"step when stop timer %ld ",(long)timerIntervel);
    NSDate *presntDate = [NSDate dateWithTimeIntervalSince1970:diff];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.S"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:presntDate];
    [self.timeLabel setTitle:timeString forState:UIControlStateNormal];
}
-(void)startPressed:(UIButton *)sender{
    if(!running){
        if (stopTimer == nil) {
            if (isStopwatch) {
                if(!timerIntervel)
                    startDate=[NSDate date];
                [self startTimerWithPresentTime];
                timerType = [NSNumber numberWithInt:stopTimers];
                stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                             target:self
                                                           selector:@selector(updateTimer)
                                                           userInfo:nil
                                                            repeats:YES];
            }else {
                if(!timerIntervel)
                    startDate=[NSDate date];
                [self startTimerWithPresentCountDownTime];
                timerType = [NSNumber numberWithInt:countTimers];
                if(interval <= 0)
                {
                    interval=[timerIntervelForCountdown doubleValue];
                    int hours = interval / 3600;
                    int minutes = ((int)interval % 3600) / 60;
                    int seconds = ((int)interval % 3600) % 60;
                    timerIntervel=[NSNumber numberWithDouble:interval];
                    [self.timeLabel setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds] forState:UIControlStateNormal];
                }
                stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
            }
        }
        running = YES;
        self.timerStart.selected=YES;
//        [self.timerReset setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [self.timerReset setEnabled:NO];
        [self.stepCounter setEnabled:NO];
        [self.stepStopTimerWatch setEnabled:NO];
        
    }else{
        endDate=[NSDate date];
        running = NO;
        self.timerStart.selected=NO;
        [self.timerReset setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
        [self.timerReset setEnabled:YES];
        [self.stepCounter setEnabled:YES];
        [self.stepStopTimerWatch setEnabled:YES];
        [stopTimer invalidate];
        stopTimer = nil;
        if (isStopwatch)
        {
            [self startWithPreviousTime];
        }
    }
    [self savingInNSUserDeFaults];
}
-(void)startTimerWithPresentCountDownTime
{
    NSTimeInterval intervals = [timerIntervel doubleValue];
    NSDate *currentDate = [NSDate date];
    startDate=[currentDate dateByAddingTimeInterval:intervals];
    NSLog(@"step when start timer %ld ",(long)intervals);
    
}
-(void)updateTimer{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.S"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    [self.timeLabel setTitle:timeString forState:UIControlStateNormal];
}
- (void)updateCounter:(NSTimer *)theTimer {
    NSLog(@"counter : %f",interval);
    if(interval > 0 ){
        interval -- ;
        running = YES;
        int hours = interval / 3600;
        int minutes = ((int)interval % 3600) / 60;
        int seconds = ((int)interval % 3600) % 60;
        timerIntervel=[NSNumber numberWithDouble:interval];
        [self.timeLabel setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds] forState:UIControlStateNormal];
    }else {
        [self.timeLabel setTitle:@"00:00:00" forState:UIControlStateNormal];
        [self startPressed:self.stepCounter];
        NSError* error;
        [[AVAudioSession sharedInstance]
         setCategory:AVAudioSessionCategoryPlayback
         error:&error];
        if (error == nil) {
            SystemSoundID myAlertSound = 1100;
            NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/new-mail.caf"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &myAlertSound);
            
            AudioServicesPlaySystemSound(myAlertSound);
            
        }
    }
}
-(void)savingInNSUserDeFaults
{
    NSMutableDictionary *timerDetails = [[NSMutableDictionary alloc] init];
    [timerDetails setValue:startDate forKey:@"startDate"];
    [timerDetails setValue:timerIntervel forKey:@"intervel"];
    [timerDetails setValue:timerType forKey:@"timerType"];
    if([timerType intValue]) {
        [timerDetails setValue:timerIntervelForCountdown forKey:@"timerIntervel"];
      }
//    [NSDictionary dictionaryWithObjectsAndKeys:startDate,@"startDate",timerIntervel,@"intervel",timerType,@"timerType", nil];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"stepTimers"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dic setObject:timerDetails forKey:[UserData instance].task.objectId];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"stepTimers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)resetPressed:(id)sender{
    [stopTimer invalidate];
    stopTimer = nil;
    [self settingToZero];
    [self savingInNSUserDeFaults];
      startDate = [NSDate date];
    if(![timerType intValue]) {
        [self.timeLabel setTitle:@"00:00:00.0" forState:UIControlStateNormal];
    }else {
        interval= [timerIntervelForCountdown doubleValue];
        int hours = interval / 3600;
        int minutes = ((int)interval % 3600) / 60;
        int seconds = ((int)interval % 3600) % 60;
        timerIntervel=[NSNumber numberWithDouble:interval];
        [self.timeLabel setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds] forState:UIControlStateNormal];
    }
    if (running) {
        running = NO;
        [self startPressed:nil];
    }else {
        running = NO;
    }
}
-(void)settingToZero
{
    startDate=0;
    timerIntervel=0;
}
-(void)setTimePressed:(UIButton *)sender{
    if (!running && !isStopwatch){
        [dummyField becomeFirstResponder];
    }
}

- (void)setupPickerView
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];

    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:[NSArray arrayWithObjects:spaceItem, doneButton, nil] animated:NO];
    
    
    UIPickerView *countDownPicker = [[UIPickerView alloc] init];
//    countDownPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    countDownPicker.delegate = self;
    countDownPicker.dataSource = self;
//    CGSize pickerSize = [countDownPicker sizeThatFits:CGSizeZero];
//    countDownPicker.frame = CGRectMake(0.0, 250, pickerSize.width, 460);
    
    dummyField = [[UITextField alloc] init];
    [dummyField setInputView:countDownPicker];
    [dummyField setInputAccessoryView:pickerToolbar];
    [self.view addSubview:dummyField];
}

#pragma mark - picker

- (void)pickerDone{
    [dummyField resignFirstResponder];
}

//Method to define how many columns/dials to show
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}


// Method to define the numberOfRows in a component using the array.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent :(NSInteger)component
{
    if (component==0)
    {
        return 24; //hours
    }
    else
    {
        return 60; //Minutes & Seconds
    }
}


// Method to show the title of row for a component.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d %@",row, component==0?@"hours":(component == 1?@"min":@"sec")];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int hoursInt = [pickerView selectedRowInComponent:0];
    int minsInt = [pickerView selectedRowInComponent:1];
    int secsInt = [pickerView selectedRowInComponent:2];
    
    interval = secsInt + (minsInt*60) + (hoursInt*3600);
    timerIntervelForCountdown =[NSNumber numberWithDouble:interval];
    startDate=[NSDate date];
    startDate=[startDate dateByAddingTimeInterval:interval];
    timerIntervel=[NSNumber numberWithDouble:interval];
    NSLog(@"hours: %d ... mins: %d .... sec: %d .... interval: %f", hoursInt, minsInt, secsInt, interval);
    [self.timeLabel setTitle:[NSString stringWithFormat:@"%02d:%02d:%02d",hoursInt,minsInt,secsInt] forState:UIControlStateNormal];
}

@end
