//
//  DatetimeTriggerTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 5/7/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "DatetimeTriggerTVC.h"
#import "DateTimeTrigger.h"
#import "Utils.h"

#define NOTIFY_ME_BEFORE_NUMBER_LIMIT 121
#define TIME_AFTER_NUMBER_LIMIT 120
#define DEFAULT_NUMBER_LIMIT 15
#define TIME_AFTER_UNITS_OF_TIME [[NSArray alloc] initWithObjects:MINUTES, HOURS, DAYS, WEEKS, MONTHS, YEARS, nil]

@interface DatetimeTriggerTVC ()

@property (weak, nonatomic) IBOutlet UITextField *notifyMeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeAfterTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatEveryTextField;
@property (weak, nonatomic) IBOutlet UITextField *manyTimesUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthlyOptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *everyMonthsTextField;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *repeatFromDateSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *manyTimesSwitch;

@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet UIButton *mondayButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DatetimeTriggerTVC

NSInteger PICKER_NUMBER = 0, PICKER_UNIT = 1;
UIPickerView *notifyMePicker, *timeAfterPicker, *repeatEveryPicker, *manyTimesUnitsPicker, *monthlyOptionPicker,*everyMonthsPicker;
UIDatePicker *datePicker;
NSString *DATETIME_FORMAT = @"MMM dd, yyyy h:mma";
NSDateFormatter *dateFormatter;
NSArray *units, *monthlyOptions, *days;
bool everyMonthsBool;
int monthsOptionNumber;

NSInteger const SECTION_REPEAT = 1;
NSInteger const ROW_TIME_AFTER_COMPLETION = 1;
NSInteger const ROW_REPEAT_EVERY_UNIT = 3;
NSInteger const ROW_REPEAT_EVERY_NUMBER = 4;
NSInteger const ROW_DAYS_OF_WEEK = 5;
NSInteger const ROW_MONTHLY_OPTION = 6;
NSInteger const ROW_EVERYMONTH_OPTION = 7;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATETIME_FORMAT];
    everyMonthsBool=1;
    
    units = [[NSArray alloc] initWithObjects:MINUTES, HOURS, DAYS, WEEKS, MONTHS, YEARS, nil];
    monthlyOptions = [[NSArray alloc] initWithObjects:@"Every week", @"First week of each month", @"Second week of each month", @"Third week of each month", @"Fourth week of each month", @"Last week of each month", nil];
    days = [[NSArray alloc] initWithObjects:@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday", nil];
    if (![UserData instance].task.dateTimeTriggers || ![UserData instance].task.dateTimeTriggers.count || ! ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0])) {
        [UserData instance].task.dateTimeTriggers = [[NSMutableArray alloc] init];
        DateTimeTrigger *trigger = [[DateTimeTrigger alloc] init];
        trigger.notifyMeNumber = [UserData instance].userSettings.notifyMeNumber;
        trigger.notifyMeUnit = [UserData instance].userSettings.notifyMeUnit;
        trigger.repeatEveryUnit = [units firstObject];
        trigger.date= [NSDate date];
        
        // Setting default Alert time from User Settings
        NSDateComponents* tomorrowDateComponents = [NSDateComponents new] ;
        tomorrowDateComponents.day = 1 ;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* tomorrow = [calendar dateByAddingComponents:tomorrowDateComponents toDate:trigger.date options:0] ;
        NSDateComponents* tomorrowComponents = [calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:tomorrow] ;
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[UserData instance].userSettings.alertTime];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        tomorrowComponents.hour = hour ;
        tomorrowComponents.minute = minute;
        NSDate* tomorrowAlertTime = [calendar dateFromComponents:tomorrowComponents] ;
        trigger.date = tomorrowAlertTime;
        
        [[UserData instance].task.dateTimeTriggers addObject:trigger];
        [[UserData instance].task saveInBackground];
    }
    
    [self setupPickerViews];
    [self setupInitialUI];
    [self setupUI];
}

- (void)setupPickerViews
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];
  /*  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self action:@selector(pickerCancelled)];*/
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:[NSArray arrayWithObjects:spaceItem, doneButton, spaceItem,nil] animated:NO];
    
    notifyMePicker = [[UIPickerView alloc] init];
    notifyMePicker.dataSource = self;
    notifyMePicker.delegate = self;
    self.notifyMeTextField.inputView = notifyMePicker;
    self.notifyMeTextField.inputAccessoryView = pickerToolbar;
    
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date];
    [datePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
    //    [datePicker setDatePickerMode:UIDatePickerModeDate];
    self.dateTextField.inputView = datePicker;
    self.dateTextField.inputAccessoryView = pickerToolbar;
    if (!((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date) {
        [self datePickerChangedValue:datePicker];    
    }
    
    timeAfterPicker = [[UIPickerView alloc] init];
    timeAfterPicker.dataSource = self;
    timeAfterPicker.delegate = self;
    self.timeAfterTextField.inputView = timeAfterPicker;
    self.timeAfterTextField.inputAccessoryView = pickerToolbar;
    
    repeatEveryPicker = [[UIPickerView alloc] init];
    repeatEveryPicker.dataSource = self;
    repeatEveryPicker.delegate = self;
    self.repeatEveryTextField.inputView = repeatEveryPicker;
    self.repeatEveryTextField.inputAccessoryView = pickerToolbar;
    
    manyTimesUnitsPicker = [[UIPickerView alloc] init];
    manyTimesUnitsPicker.dataSource = self;
    manyTimesUnitsPicker.delegate = self;
    self.manyTimesUnitTextField.inputView = manyTimesUnitsPicker;
    self.manyTimesUnitTextField.inputAccessoryView = pickerToolbar;
    
    monthlyOptionPicker = [[UIPickerView alloc] init];
    monthlyOptionPicker.dataSource = self;
    monthlyOptionPicker.delegate = self;
    self.monthlyOptionTextField.inputView = monthlyOptionPicker;
    self.monthlyOptionTextField.inputAccessoryView = pickerToolbar;
    
    everyMonthsPicker= [[UIPickerView alloc] init];
    everyMonthsPicker.dataSource = self;
    everyMonthsPicker.delegate = self;
    self.everyMonthsTextField.inputView = everyMonthsPicker;
    self.everyMonthsTextField.inputAccessoryView = pickerToolbar;
}

- (void)setupInitialUI
{
    [self.repeatSwitch setOn:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeating];
    [self.repeatFromDateSwitch setOn:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeatFromLastDate];
    [self.manyTimesSwitch setOn:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeatManyTimes];
    
    self.sundayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isSundayRepeat;
    self.mondayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isMondayRepeat;
    self.tuesdayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isTuesdayRepeat;
    self.wednesdayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isWednesdayRepeat;
    self.thursdayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isThursdayRepeat;
    self.fridayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isFridayRepeat;
    self.saturdayButton.selected = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isSaturdayRepeat;
    
    NSString *monthlyOptionText = @"";
     NSNumber *number=((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryNumber;
     switch (((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType) {
        case repeatEveryWeek:
            monthlyOptionText = [NSString stringWithFormat:@"%@ of every %@ %@",[Utils suffixOfDateNumber:[Utils valueFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date returnType:NSCalendarUnitDay]],number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"];
            break;
        case repeatFirstWeek:
            monthlyOptionText = [monthlyOptions objectAtIndex:1];
            break;
        case repeatSecondWeek:
            monthlyOptionText = [monthlyOptions objectAtIndex:2];
            break;
        case repeatThirdWeek:
            monthlyOptionText = [monthlyOptions objectAtIndex:3];
            break;
        case repeatFourthWeek:
            monthlyOptionText = [monthlyOptions objectAtIndex:4];
            break;
        case repeatLastWeek:
            monthlyOptionText = [monthlyOptions objectAtIndex:5];
            break;
        default:
            break;
    }
    if (monthlyOptionText.length) {
       NSString *string = [monthlyOptionText stringByReplacingOccurrencesOfString:@"week" withString:[days objectAtIndex:([Utils dayOfTheWeek:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date]-1)]];
    self.monthlyOptionTextField.text=[string stringByReplacingOccurrencesOfString:@"each month" withString:[NSString stringWithFormat:@"every %@ %@",number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"]];
    }
    

    // NOTIFY ME BEFORE
    NSInteger row = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeNumber.integerValue;
    if (row > 0 && row <= NOTIFY_ME_BEFORE_NUMBER_LIMIT)
        [notifyMePicker selectRow:row inComponent:PICKER_NUMBER animated:NO];
    row = [UNITS_OF_TIME indexOfObject:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeUnit];
    if (row > 0 && row < UNITS_OF_TIME.count)
        [notifyMePicker selectRow:row inComponent:PICKER_UNIT animated:NO];
    
    // TIME AFTER
    row = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterNumber.integerValue;
    if (row > 0 && row <= DEFAULT_NUMBER_LIMIT)
        [timeAfterPicker selectRow:(row - 1) inComponent:PICKER_NUMBER animated:NO];
    row = [UNITS_OF_TIME indexOfObject:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterUnit];
    if (row > 0 && row < UNITS_OF_TIME.count)
        [timeAfterPicker selectRow:row inComponent:PICKER_UNIT animated:NO];
    
    // REPEAT EVERY
    row = [units indexOfObject:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit];
    if (row > 0 && row < units.count)
        [manyTimesUnitsPicker selectRow:row inComponent:0 animated:NO];
    
    row = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryNumber.integerValue;
    if (row > 0 && row <= DEFAULT_NUMBER_LIMIT)
        [repeatEveryPicker selectRow:(row - 1) inComponent:0 animated:NO];
    
    [self.tableView reloadData];
}

- (void)setupUI
{
    self.sundayButton.backgroundColor = self.sundayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    self.mondayButton.backgroundColor = self.mondayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    self.tuesdayButton.backgroundColor = self.tuesdayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    self.wednesdayButton.backgroundColor = self.wednesdayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    self.thursdayButton.backgroundColor = self.thursdayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    self.fridayButton.backgroundColor = self.fridayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    self.saturdayButton.backgroundColor = self.saturdayButton.selected ? COLOR_FREEMINDER_BLUE : [UIColor whiteColor];
    
    NSNumber *number = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeNumber;
    NSString *unitString = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeUnit;
    if (number.intValue == 1 && unitString) unitString = [unitString substringToIndex:(unitString.length - 1)]; // remove plural for 1
    if (!number || !unitString) {
        number = [NSNumber numberWithInt:0];
        unitString = MINUTES;
    }
    self.notifyMeTextField.text = [NSString stringWithFormat:@"%@ %@ Before", number, unitString];
    
    if (((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date) {
        self.dateTextField.text = [dateFormatter stringFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date];
    }
    
    number = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterNumber;
    unitString = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterUnit;
    if (number && unitString)
        self.timeAfterTextField.text = [NSString stringWithFormat:@"%@ %@ After", number, unitString];
    
    number = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryNumber;
    unitString = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit;
    if (number.intValue == 1 && unitString) unitString = [unitString substringToIndex:(unitString.length - 1)]; // remove plural for 1
    
    if (number && unitString){
        NSString *title = [NSString stringWithFormat:@"Every %@ %@", number, unitString];
        if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:5]]) { // Years picker titles
            if (number.intValue<10) {
                title = [NSString stringWithFormat:@"%@ %@",[[self.dateTextField.text componentsSeparatedByString:@","] objectAtIndex:0],title.lowercaseString];
            }
            else {
                int date = [Utils valueFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date returnType:NSCalendarUnitDay];
                int dayOfWeek = [Utils dayOfTheWeek:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date];
                NSString *month = [Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:@"MMM"];
                title = [NSString stringWithFormat:@"%@ %@ of %@ every %i %@",[Utils suffixOfDateNumber:((date+6)/7)],[days objectAtIndex:dayOfWeek-1],month,number.intValue-10,unitString];
            }
        }
        self.repeatEveryTextField.text = title;
    }
    if(number && everyMonthsBool)
    {
        NSString * string;
        if(!monthsOptionNumber)
        {
            string=[NSString stringWithFormat:@"%@ of every %@ %@",[Utils suffixOfDateNumber:[Utils valueFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date returnType:NSCalendarUnitDay]],number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"];
            self.monthlyOptionTextField.text=[string stringByReplacingOccurrencesOfString:@"each month" withString:[NSString stringWithFormat:@"every %@ %@",number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"]];
            everyMonthsBool=0;
        }else{
            string = [[monthlyOptions objectAtIndex:monthsOptionNumber] stringByReplacingOccurrencesOfString:@"week" withString:[days objectAtIndex:([Utils dayOfTheWeek:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date]-1)]];
            
            self.monthlyOptionTextField.text=[string stringByReplacingOccurrencesOfString:@"each month" withString:[NSString stringWithFormat:@"every %@ %@",number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"]];
            everyMonthsBool=0;
        }
        [monthlyOptionPicker reloadAllComponents];
 
    }
    self.manyTimesUnitTextField.text = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit;
    //[Utils adjectiveFromPluralNoun:[UserData instance].task.datetimeTrigger.repeatEveryUnit];
    
    [self setPlainTextForOptions];
}

- (void)setPlainTextForOptions {
    
    NSMutableString *plainText = [[NSMutableString alloc] initWithString:@"Set for "];
    NSString *dtFormat = @"EEEE MMM dd, yyyy h:mma";
    NSString *timeFormat = @"h:mma";
    if (self.repeatSwitch.isOn) {
        if(!(self.repeatFromDateSwitch.isOn || self.manyTimesSwitch.isOn))
        {
            [plainText appendFormat:@"%@ And %@ Me %@ .",[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
        }
        else if(self.repeatFromDateSwitch.isOn) {
            [plainText appendFormat:@"every %@ the date of last completion. %@ %@ And %@ Me %@",self.timeAfterTextField.text,[self addingDataForOccurences],[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
        }
        else if(self.manyTimesSwitch.isOn) {
            NSString *unitString = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit;
            if ([unitString isEqualToString:DAYS]){
                [plainText appendFormat:@" %@ %@. %@ %@ And %@ Me %@",[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:timeFormat],self.repeatEveryTextField.text,[self addingDataForOccurences],[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
            }
            else if ([unitString isEqualToString:WEEKS]) {
                [plainText appendFormat:@"%@ ",[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:timeFormat]];
                NSMutableArray *daysArr = [[NSMutableArray alloc] init];
                self.sundayButton.selected?[daysArr addObject:@"Sunday"]:nil;
                self.mondayButton.selected?[daysArr addObject:@"Monday"]:nil;
                self.tuesdayButton.selected?[daysArr addObject:@"Tuesday"]:nil;
                self.wednesdayButton.selected?[daysArr addObject:@"Wednesday"]:nil;
                self.thursdayButton.selected?[daysArr addObject:@"Thursday"]:nil;
                self.fridayButton.selected?[daysArr addObject:@"Friday"]:nil;
                self.saturdayButton.selected?[daysArr addObject:@"Saturday"]:nil;
                for (int i=0; i<[daysArr count]; i++) {
                    [plainText appendString:[daysArr objectAtIndex:i]];
                    if (i == [daysArr count]-2) {
                        [plainText appendString:@" & "];
                    }else if (i!=[daysArr count]-1){
                        [plainText appendString:@", "];
                    }
                }
                [plainText appendFormat:@" of %@. %@ %@ And %@ Me %@",self.repeatEveryTextField.text,[self addingDataForOccurences],[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
            } else if ([unitString isEqualToString:MONTHS]) {
                [plainText appendFormat:@"%@ %@. %@ %@ And %@ Me %@",[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:timeFormat],self.monthlyOptionTextField.text,[self addingDataForOccurences],[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
            } else if ([unitString isEqualToString:YEARS]) {
                [plainText appendFormat:@"%@ %@. %@ %@ And %@ Me %@",[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:timeFormat],self.repeatEveryTextField.text,[self addingDataForOccurences],[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
            } else {
                [plainText appendFormat:@"%@. %@ %@ And %@ Me %@",self.repeatEveryTextField.text,[self addingDataForOccurences],[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
            }
        }
    } else {
        [plainText appendFormat:@"%@ And %@ Me %@ .",[Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:dtFormat],[self addingDataForNotify],self.notifyMeTextField.text];
    }
    self.descriptionLabel.text = plainText;//[NSString stringWithFormat:@"%@",self.dateTextField.text];
}
-(NSString *)addingDataForOccurences
{
    if([UserData instance].task.lastNotificationDate)
    {
        return @"Most recently occurred on";
    }
    else{
        return @"Next occurring";
    }
}
-(NSString *)addingDataForNotify
{
    if([UserData instance].task.lastNotificationDate)
    {
        return @"Notified";
    }
    else{
        return @"Notify";
    }
}
- (void)hideKeyboard
{
    if ([self.notifyMeTextField isEditing])
        [self.notifyMeTextField resignFirstResponder];
    else if ([self.timeAfterTextField isEditing])
        [self.timeAfterTextField resignFirstResponder];
    else if ([self.repeatEveryTextField isEditing])
        [self.repeatEveryTextField resignFirstResponder];
    else if ([self.manyTimesUnitTextField isEditing])
        [self.manyTimesUnitTextField resignFirstResponder];
    else if ([self.dateTextField isEditing])
        [self.dateTextField resignFirstResponder];
    else if ([self.monthlyOptionTextField isEditing])
        [self.monthlyOptionTextField resignFirstResponder];
    else if ([self.everyMonthsTextField isEditing])
        [self.everyMonthsTextField resignFirstResponder];
}

- (NSString *)titleForDateAndMonthlyOption:(int)row {
   
    NSNumber *number=((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryNumber;
    if (row==0) {
        return [NSString stringWithFormat:@"%@ of every %@ %@",[Utils suffixOfDateNumber:[Utils valueFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date returnType:NSCalendarUnitDay]],number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"];
    }else{
        NSString *string;
       string = [[monthlyOptions objectAtIndex:row] stringByReplacingOccurrencesOfString:@"week" withString:[days objectAtIndex:([Utils dayOfTheWeek:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date]-1)]];
       
        return [string stringByReplacingOccurrencesOfString:@"each month" withString:[NSString stringWithFormat:@"every %@ %@",number,([number isEqualToNumber:[NSNumber numberWithInt:1]])?@"month":@"months"]];
}
}
- (NSString *)titleForEveryMonthOption:(int)row {
    
    int num = row+1;
    return [NSString stringWithFormat:@"every %d %@",num,((num==1)?@"month":@"months")];
    
}

#pragma mark- UITableView methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_REPEAT) {
        if ( ! self.repeatSwitch.isOn) {
            return 0.0;
        }
        
        NSInteger row = indexPath.row;
        
        if (row == ROW_TIME_AFTER_COMPLETION) {
            return self.repeatFromDateSwitch.isOn ? [super tableView: tableView heightForRowAtIndexPath:indexPath] : 0.0;
        }
        
        if (row == ROW_REPEAT_EVERY_UNIT) {
            return self.manyTimesSwitch.isOn ? [super tableView: tableView heightForRowAtIndexPath:indexPath] : 0.0;
        }
        
        if (row == ROW_REPEAT_EVERY_NUMBER) {
            return (self.manyTimesSwitch.isOn && ! [((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:MONTHS]) ? [super tableView: tableView heightForRowAtIndexPath:indexPath] : 0.0;
        }
        
        if (row == ROW_DAYS_OF_WEEK) {
            NSLog(@"HEIGHT: %f", [super tableView: tableView heightForRowAtIndexPath:indexPath]);
            
            return (self.manyTimesSwitch.isOn
                    && [((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:WEEKS]) ? [super tableView: tableView heightForRowAtIndexPath:indexPath] : 0.0;
        }
        
        if (row == ROW_MONTHLY_OPTION) {
            return (self.manyTimesSwitch.isOn
                    && [((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:MONTHS]) ? [super tableView: tableView heightForRowAtIndexPath:indexPath] : 0.0;
        }
        if (row == ROW_EVERYMONTH_OPTION) {
            return (self.manyTimesSwitch.isOn
                    && [((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:MONTHS]) ? [super tableView: tableView heightForRowAtIndexPath:indexPath] : 0.0;
        }
        
        return [super tableView: tableView heightForRowAtIndexPath:indexPath];
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_REPEAT && ! self.repeatSwitch.isOn) {
        return 0.0;
    } else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

#pragma mark- UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == manyTimesUnitsPicker
        || pickerView == repeatEveryPicker
        || pickerView == monthlyOptionPicker
        ||pickerView == everyMonthsPicker) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == manyTimesUnitsPicker) {
        return units.count;
    } else if (pickerView == repeatEveryPicker) {
        if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:0]]) {
            return 116;
        }if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:1]]) {
            return 100;
        }if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:2]]) {
            return 100;
        }if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:3]]) {
            return 104;
        }if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:4]]) {
            return 36;
        }if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:5]]) {
            return 20;
        }
        
        return 0;
    } else if (pickerView == monthlyOptionPicker) {
        return monthlyOptions.count;
    }else if(pickerView == everyMonthsPicker){
         return 36;
    }else if (pickerView == notifyMePicker) {
        if (component == PICKER_NUMBER) {
            return NOTIFY_ME_BEFORE_NUMBER_LIMIT;
        } else {
            return [UNITS_OF_TIME count];
        }
    } else if (pickerView == timeAfterPicker) {
        if (component == PICKER_NUMBER) {
            return TIME_AFTER_NUMBER_LIMIT;
        } else {
            return [TIME_AFTER_UNITS_OF_TIME count];
        }
    } else {
        return 0; // shouldn't ever happen
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == manyTimesUnitsPicker) {
        return [units objectAtIndex:row];//[Utils adjectiveFromPluralNoun:[units objectAtIndex:row]];
    } else if (pickerView == everyMonthsPicker) {
        return [self titleForEveryMonthOption:row];
    } else if (pickerView == monthlyOptionPicker) {
        return [self titleForDateAndMonthlyOption:row];
    } else if (pickerView == repeatEveryPicker) {
        NSNumber *number = [NSNumber numberWithInt:((int)row + 1)];
        NSString *unitString = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit;
        if ([unitString isEqualToString:MINUTES]) number = [NSNumber numberWithInt:((int)row + 5)];
        if (number.intValue == 1 && unitString) unitString = [unitString substringToIndex:(unitString.length - 1)]; // remove plural for 1
        
        NSString *title = [NSString stringWithFormat:@"Every %i %@", number.intValue, unitString];
        if ([((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit isEqualToString:[units objectAtIndex:5]]) { // Years picker titles
            if (row<10) {
                title = [NSString stringWithFormat:@"%@ %@",[[self.dateTextField.text componentsSeparatedByString:@","] objectAtIndex:0],title.lowercaseString];
            }
            else {
                int date = [Utils valueFromDate:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date returnType:NSCalendarUnitDay];
                int dayOfWeek = [Utils dayOfTheWeek:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date];
                NSString *month = [Utils dateToText:((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date format:@"MMM"];
                title = [NSString stringWithFormat:@"%@ %@ of %@ every %i %@",[Utils suffixOfDateNumber:((date+6)/7)],[days objectAtIndex:dayOfWeek-1],month,number.intValue-10,unitString];
            }
        }
        NSLog(@"%@",title);
        return title;
    } else {
        if (component == PICKER_NUMBER) {
            if (pickerView == notifyMePicker) {
                return [NSString stringWithFormat:@"%i", (int) row];
            } else {
                return [NSString stringWithFormat:@"%i", (int) (row + 1)];
            }
        } else {
            if (pickerView == notifyMePicker) {
                return [NSString stringWithFormat:@"%@ Before", [UNITS_OF_TIME objectAtIndex:row]];
            } else if (pickerView == timeAfterPicker) {
                return [NSString stringWithFormat:@"%@ After", [TIME_AFTER_UNITS_OF_TIME objectAtIndex:row]];
            } else {
                return [UNITS_OF_TIME objectAtIndex:row];
            }
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == notifyMePicker) {
        if (component == PICKER_NUMBER) {
            ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeNumber = [NSNumber numberWithInt:((int) row)];
            if (! ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeUnit)
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeUnit = [UNITS_OF_TIME objectAtIndex:0];
        } else {
            ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeUnit = [UNITS_OF_TIME objectAtIndex:row];
            if (! ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeNumber)
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).notifyMeNumber = [NSNumber numberWithInt:0];
        }
    } else if (pickerView == timeAfterPicker) {
        if (component == PICKER_NUMBER) {
            ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterNumber = [NSNumber numberWithInt:((int)row + 1)];
            if (! ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterUnit)
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterUnit = [TIME_AFTER_UNITS_OF_TIME objectAtIndex:0];
        } else {
            ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterUnit = [TIME_AFTER_UNITS_OF_TIME objectAtIndex:row];
            if (! ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterNumber)
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).timeAfterNumber = [NSNumber numberWithInt:1];
        }
    } else if (pickerView == repeatEveryPicker) {
        NSInteger number = row+1;
        NSString *unitString = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit;
        if ([unitString isEqualToString:MINUTES]) number = row+5;

        ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryNumber = [NSNumber numberWithInteger:number];
    } else if (pickerView == monthlyOptionPicker) {
        monthsOptionNumber=row;
        self.monthlyOptionTextField.text = [self titleForDateAndMonthlyOption:row];
        switch (row) {
            case 0:
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType = repeatEveryWeek;
                break;
                
            case 1:
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType = repeatFirstWeek;
                break;
                
            case 2:
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType = repeatSecondWeek;
                break;
                
            case 3:
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType = repeatThirdWeek;
                break;
                
            case 4:
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType = repeatFourthWeek;
                break;
                
            case 5:
                ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).weeklyRepeatType = repeatLastWeek;
                break;
                
            default:
                
                break;
        }
        
    }else if (pickerView == everyMonthsPicker) {
         everyMonthsBool=1;
         self.everyMonthsTextField.text = [self titleForEveryMonthOption:row];
        ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryNumber = [NSNumber numberWithInteger:row+1];
        [monthlyOptionPicker reloadAllComponents];

    }else if (pickerView == manyTimesUnitsPicker) {
        ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).repeatEveryUnit = [units objectAtIndex:row];
        [repeatEveryPicker reloadAllComponents];
        [repeatEveryPicker selectRow:0 inComponent:0 animated:NO];
        [self pickerView:repeatEveryPicker didSelectRow:0 inComponent:0];
        NSArray *rowsToReload = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:ROW_REPEAT_EVERY_NUMBER inSection:SECTION_REPEAT], [NSIndexPath indexPathForRow:ROW_DAYS_OF_WEEK inSection:SECTION_REPEAT], [NSIndexPath indexPathForRow:ROW_MONTHLY_OPTION inSection:SECTION_REPEAT],[NSIndexPath indexPathForRow:ROW_EVERYMONTH_OPTION inSection:SECTION_REPEAT], nil];
         [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self setupUI];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (pickerView == notifyMePicker) {
        if (component == PICKER_NUMBER) {
            return 50.0;
        } else {
            return 270.0;
        }
    } else if (pickerView == timeAfterPicker) {
        if (component == PICKER_NUMBER) {
            return 50.0;
        } else {
            return 270.0;
        }
    } else {
        return 320.0;
    }
}

#pragma mark- UITextField methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  
    if (textField == self.manyTimesUnitTextField)
        [self pickerView:manyTimesUnitsPicker didSelectRow:[manyTimesUnitsPicker selectedRowInComponent:0] inComponent:0];
  
}

- (IBAction)dateChanged:(UITextField *)sender
{
    UIDatePicker *picker = (UIDatePicker *) sender.inputView;
    
    if ([picker.date timeIntervalSinceNow] > 0.0) {
        ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date = picker.date;
        self.dateTextField.text = [dateFormatter stringFromDate:picker.date];
    }
}

- (void)datePickerChangedValue:(UIDatePicker *)picker
{
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date = picker.date;
    self.dateTextField.text = [dateFormatter stringFromDate:picker.date];
    [self setPlainTextForOptions];
}

#pragma mark- Actions

- (IBAction)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)donePressed
{
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeating = self.repeatSwitch.isOn;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeatFromLastDate = self.repeatFromDateSwitch.isOn;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isRepeatManyTimes = self.manyTimesSwitch.isOn;
    
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isSundayRepeat = self.sundayButton.selected;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isMondayRepeat = self.mondayButton.selected;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isTuesdayRepeat = self.tuesdayButton.selected;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isWednesdayRepeat = self.wednesdayButton.selected;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isThursdayRepeat = self.thursdayButton.selected;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isFridayRepeat = self.fridayButton.selected;
    ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).isSaturdayRepeat = self.saturdayButton.selected;
    NSDate *triggerDate = ((DateTimeTrigger *)[[UserData instance].task.dateTimeTriggers objectAtIndex:0]).date;
    [UserData instance].task.lastNotificationDate = [Utils isDateInFuture:triggerDate]?nil:triggerDate;
    [UserData instance].didChangeTrigger = YES;

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchValueChanged:(UISwitch *)theSwitch
{
    if (theSwitch == self.repeatSwitch) {
        
    } else if (theSwitch == self.repeatFromDateSwitch) {
        [self.manyTimesSwitch setOn:NO];
    } else if (theSwitch == self.manyTimesSwitch) {
        [self.repeatFromDateSwitch setOn:NO];
    }
    
    [self.tableView reloadData];
    [self setPlainTextForOptions];
}

- (IBAction)dayButtonToggled:(UIButton *)button
{
    button.selected = ! button.selected;
    
    [self setupUI];
}

- (void)pickerDone
{
    if ([self.notifyMeTextField isEditing])
        [self pickerView:notifyMePicker didSelectRow:[notifyMePicker selectedRowInComponent:0] inComponent:0];
    else if ([self.timeAfterTextField isEditing])
        [self pickerView:timeAfterPicker didSelectRow:[timeAfterPicker selectedRowInComponent:0] inComponent:0];
    else if ([self.repeatEveryTextField isEditing])
        [self pickerView:repeatEveryPicker didSelectRow:[repeatEveryPicker selectedRowInComponent:0] inComponent:0];
    else if ([self.manyTimesUnitTextField isEditing])
        [self pickerView:manyTimesUnitsPicker didSelectRow:[manyTimesUnitsPicker selectedRowInComponent:0] inComponent:0];
    else if ([self.monthlyOptionTextField isEditing])
        [self pickerView:monthlyOptionPicker didSelectRow:[monthlyOptionPicker selectedRowInComponent:0] inComponent:0];
    else if ([self.everyMonthsTextField isEditing])
        [self pickerView:everyMonthsPicker didSelectRow:[everyMonthsPicker selectedRowInComponent:0] inComponent:0];
    
    [self hideKeyboard];
}

- (void)pickerCancelled
{
    [self hideKeyboard];
}

#pragma mark- end of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
