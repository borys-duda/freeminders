//
//  SettingsTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 6/5/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "SettingsTVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "MapAnnotation.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "AddressCell.h"
#import "Const.h"
#import "UserData.h"
#import "UserSetting.h"

#define DEFAULT_MAP_SPAN 0.10
#define NOTIFY_ME_BEFORE_NUMBER_LIMIT_IN_SETTINGS 121


@interface SettingsTVC ()

@property (weak,nonatomic) IBOutlet UITextField *alertTimeTextField;
@property (weak,nonatomic) IBOutlet UITextField *notifyMeTextField;
@property (weak,nonatomic) IBOutlet UITextField *inTheMorningTextField;
@property (weak,nonatomic) IBOutlet UITextField *tonightTextField;
@property (weak,nonatomic) IBOutlet UITextField *locationSleepTextField;
@property (weak,nonatomic) IBOutlet UITextField *temperatureTypeTextField;
@property (strong,nonatomic)UserSetting *userSettings;

@end

@implementation SettingsTVC


NSInteger PICKER_NUMBERS = 0, PICKER_UNITS = 1;

UIPickerView *notifyMePicker, *locSleepPicker, *tempTypePicker;
UIDatePicker *alertTimePicker, *intheMorningPicker, *toNightPicker;

NSString *DATETIME_FORMAT_INSETTINGS = @"h:mma";
NSDateFormatter *dateFormatter_InSettings;
NSArray *temperatureArry;
bool notifyMe,LocationSleep,temperature;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userSettings = [[UserSetting alloc] init];
    self.userSettings.alertTime = [UserData instance].userSettings.alertTime;
    self.userSettings.inTheMorning = [UserData instance].userSettings.inTheMorning;
    self.userSettings.toNight = [UserData instance].userSettings.toNight;
    self.userSettings.notifyMeNumber = [UserData instance].userSettings.notifyMeNumber;
    self.userSettings.notifyMeUnit = [UserData instance].userSettings.notifyMeUnit;
    self.userSettings.locationSleepNumber = [UserData instance].userSettings.locationSleepNumber;
    self.userSettings.locationSleepUnit = [UserData instance].userSettings.locationSleepUnit;
    self.userSettings.temperatureType = [UserData instance].userSettings.temperatureType;
    
//    [self performloadsettings];
    
    dateFormatter_InSettings=[[NSDateFormatter alloc] init];
    [dateFormatter_InSettings setDateFormat:DATETIME_FORMAT_INSETTINGS];
    temperatureArry=[[NSArray alloc] initWithObjects:@"Fahrenheit",@"Celsius", nil];
    [self setUpUiForPickers];

    [self setUpUi];

}

#pragma mark- Actions

- (IBAction)backButtonPressed
{
    [UserData instance].userSettings.alertTime = self.userSettings.alertTime;
    [UserData instance].userSettings.inTheMorning = self.userSettings.inTheMorning;
    [UserData instance].userSettings.toNight = self.userSettings.toNight;
    [UserData instance].userSettings.notifyMeNumber = self.userSettings.notifyMeNumber;
    [UserData instance].userSettings.notifyMeUnit = self.userSettings.notifyMeUnit;
    [UserData instance].userSettings.locationSleepNumber = self.userSettings.locationSleepNumber;
    [UserData instance].userSettings.locationSleepUnit = self.userSettings.locationSleepUnit;
    [UserData instance].userSettings.temperatureType = self.userSettings.temperatureType;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    [[UserData instance].userSettings saveInBackground];
}
-(void)cancelbuttonpressed
{
    [UserData instance].userSettings.alertTime = self.userSettings.alertTime;
    [UserData instance].userSettings.inTheMorning = self.userSettings.inTheMorning;
    [UserData instance].userSettings.toNight = self.userSettings.toNight;
    [UserData instance].userSettings.notifyMeNumber = self.userSettings.notifyMeNumber;
    [UserData instance].userSettings.notifyMeUnit = self.userSettings.notifyMeUnit;
    [UserData instance].userSettings.locationSleepNumber = self.userSettings.locationSleepNumber;
    [UserData instance].userSettings.locationSleepUnit = self.userSettings.locationSleepUnit;
    [UserData instance].userSettings.temperatureType = self.userSettings.temperatureType;
    [self setUpUi];
}
- (IBAction)saveSettings:(id)sender {
    [[UserData instance].userSettings saveInBackground];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)setUpUi
{
    NSNumber *number = [UserData instance].userSettings.notifyMeNumber;
    NSString *unitString = [UserData instance].userSettings.notifyMeUnit;
    if (number.intValue == 1 && unitString) unitString = [unitString substringToIndex:(unitString.length - 1)]; // remove plural for 1
    if (number && unitString)
        self.notifyMeTextField.text = [NSString stringWithFormat:@"%@ %@", number, unitString];
    
    NSNumber *numberForLocation = [UserData instance].userSettings.locationSleepNumber;
    NSString *unitStringForLocation = [UserData instance].userSettings.locationSleepUnit;
    if (numberForLocation.intValue == 1 && unitStringForLocation) unitStringForLocation = [unitStringForLocation substringToIndex:(unitStringForLocation.length - 1)]; // remove plural for 1
    if (numberForLocation && unitStringForLocation)
        self.locationSleepTextField.text = [NSString stringWithFormat:@"%@ %@", numberForLocation, unitStringForLocation];
    
    NSDate *toNight =[UserData instance].userSettings.toNight;
    self.tonightTextField.text = [dateFormatter_InSettings stringFromDate:toNight];
    
    NSDate *inTheMorning =[UserData instance].userSettings.inTheMorning;
    self.inTheMorningTextField.text = [dateFormatter_InSettings stringFromDate:inTheMorning];
    
    NSDate *alertTime =[UserData instance].userSettings.alertTime;
    self.alertTimeTextField.text = [dateFormatter_InSettings stringFromDate:alertTime];
    
    self.temperatureTypeTextField.text=[UserData instance].userSettings.temperatureType;
    
  // Notify me Picker
    NSInteger row = [UserData instance].userSettings.notifyMeNumber.integerValue;
    if (row > 0 && row <= NOTIFY_ME_BEFORE_NUMBER_LIMIT_IN_SETTINGS)
        [notifyMePicker selectRow:row inComponent:PICKER_NUMBERS animated:NO];
    row = [UNITS_OF_TIME indexOfObject:[UserData instance].userSettings.notifyMeUnit];
    if (row > 0 && row < UNITS_OF_TIME.count)
        [notifyMePicker selectRow:row inComponent:PICKER_UNITS animated:NO];
    
    // Location Picker Picker
    NSInteger rowForLoc = [UserData instance].userSettings.locationSleepNumber.integerValue;
    if (rowForLoc > 0 && rowForLoc <= NOTIFY_ME_BEFORE_NUMBER_LIMIT_IN_SETTINGS)
        [locSleepPicker selectRow:rowForLoc inComponent:PICKER_NUMBERS animated:NO];
      rowForLoc = [UNITS_OF_TIME indexOfObject:[UserData instance].userSettings.locationSleepUnit];
    if (rowForLoc > 0 && rowForLoc < UNITS_OF_TIME.count)
        [locSleepPicker selectRow:rowForLoc inComponent:PICKER_UNITS animated:NO];
    
    // temp picker
    if([[UserData instance].userSettings.temperatureType isEqualToString:[temperatureArry objectAtIndex:0]])
      [tempTypePicker selectRow:0 inComponent:0 animated:YES];
    else
      [tempTypePicker selectRow:1 inComponent:0 animated:YES];
    
    
}
-(void)performloadsettings
{
    PFQuery *userInfoQuery = [PFQuery queryWithClassName:[UserSetting parseClassName]];
    [userInfoQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userInfoQuery setLimit:1000];
    [userInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[UserSetting class]]) {
            [UserData instance].userSettings = objects.firstObject;
        }
        [self setUpUi];
    }];
}

-(void)setUpUiForPickers
{
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self action:@selector(pickerCancelled)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, spaceItem, doneButton, nil] animated:NO];
    
    
    alertTimePicker = [[UIDatePicker alloc] init];
    [alertTimePicker setDatePickerMode:UIDatePickerModeTime];
    [alertTimePicker addTarget:self action:@selector(datePickerChangedValueinsettings:) forControlEvents:UIControlEventValueChanged];
    self.alertTimeTextField.inputView = alertTimePicker;
    self.alertTimeTextField.inputAccessoryView = pickerToolbar;
    
    notifyMePicker = [[UIPickerView alloc] init];
    notifyMePicker.dataSource = self;
    notifyMePicker.delegate = self;
    self.notifyMeTextField.inputView = notifyMePicker;
    self.notifyMeTextField.inputAccessoryView = pickerToolbar;
    
    intheMorningPicker = [[UIDatePicker alloc] init];
    [intheMorningPicker setDatePickerMode:UIDatePickerModeTime];
    [intheMorningPicker addTarget:self action:@selector(datePickerChangedValueinsettings:) forControlEvents:UIControlEventValueChanged];
    self.inTheMorningTextField.inputView = intheMorningPicker;
    self.inTheMorningTextField.inputAccessoryView = pickerToolbar;
    
    toNightPicker = [[UIDatePicker alloc] init];
    [toNightPicker setDatePickerMode:UIDatePickerModeTime];
    [toNightPicker addTarget:self action:@selector(datePickerChangedValueinsettings:) forControlEvents:UIControlEventValueChanged];
    self.tonightTextField.inputView = toNightPicker;
    self.tonightTextField.inputAccessoryView = pickerToolbar;
    
    locSleepPicker = [[UIPickerView alloc] init];
    locSleepPicker.dataSource = self;
    locSleepPicker.delegate = self;
    self.locationSleepTextField.inputView = locSleepPicker;
    self.locationSleepTextField.inputAccessoryView = pickerToolbar;
    
    tempTypePicker=[[UIPickerView alloc]init];
    tempTypePicker.dataSource= self;
    tempTypePicker.delegate=self;
    self.temperatureTypeTextField.inputView=tempTypePicker;
    self.temperatureTypeTextField.inputAccessoryView=pickerToolbar;
}
- (void)hideKeyboard
{
    [self.locationSleepTextField resignFirstResponder];
    [self.tonightTextField resignFirstResponder];
    [self.inTheMorningTextField resignFirstResponder];
    [self.alertTimeTextField resignFirstResponder];
    [self.notifyMeTextField resignFirstResponder];
    [self.temperatureTypeTextField resignFirstResponder];
    
}
-(void)pickerDone
{
/*    if ([self.notifyMeTextField isEditing])
    {
        notifyMe=1;
        [self pickerView:notifyMePicker_InSettings  didSelectRow:[notifyMePicker_InSettings selectedRowInComponent:0] inComponent:0];
        
    }
    else if ([self.locationSleepTextField isEditing])
    {
        LocationSleep=1;
        [self pickerView:notifyMePicker_InSettings  didSelectRow:[notifyMePicker_InSettings selectedRowInComponent:0] inComponent:0];
    }
    else if([self.temperatureTypeTextField isEditing])
    {
        temperature=1;
        
        [self pickerView:temperaturePicker  didSelectRow:[temperaturePicker selectedRowInComponent:0] inComponent:0];
        
    }
*/
    [self hideKeyboard];
}
-(void)pickerCancelled
{
    [self cancelbuttonpressed];
    [self hideKeyboard];
}
- (IBAction)dateChanged:(UITextField *)sender
{
    UIDatePicker *picker = (UIDatePicker *) sender.inputView;
    
    if ([picker.date timeIntervalSinceNow] > 0.0) {
        
        if([self.alertTimeTextField isEditing])
        {
            self.alertTimeTextField.text = [dateFormatter_InSettings stringFromDate:picker.date];
        }
        else if([self.tonightTextField isEditing])
        {
            self.tonightTextField.text = [dateFormatter_InSettings stringFromDate:picker.date];
            
        }
        else if([self.inTheMorningTextField isEditing])
        {
            self.inTheMorningTextField.text = [dateFormatter_InSettings stringFromDate:picker.date];
            
        }
        
    }
}

- (void)datePickerChangedValueinsettings:(UIDatePicker *)picker
{
    
    if([self.alertTimeTextField isEditing])
    {
        [UserData instance].userSettings.alertTime = picker.date;
        self.alertTimeTextField.text = [dateFormatter_InSettings stringFromDate:picker.date];
        
        
    }
    else if([self.tonightTextField isEditing])
    {
        [UserData instance].userSettings.toNight=picker.date;
         self.tonightTextField.text = [dateFormatter_InSettings stringFromDate:picker.date];
        
    }
    else if([self.inTheMorningTextField isEditing])
    {
        [UserData instance].userSettings.inTheMorning=picker.date;
        
        self.inTheMorningTextField.text = [dateFormatter_InSettings stringFromDate:picker.date];
        
    }
    [self setUpUi];
    
}
// picker view delagate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView==notifyMePicker || pickerView==locSleepPicker)
    {
        return 2;
    }
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView==notifyMePicker || pickerView==locSleepPicker)
    {
        if(component==PICKER_NUMBERS)
            return NOTIFY_ME_BEFORE_NUMBER_LIMIT_IN_SETTINGS;
        else
            return (pickerView==notifyMePicker)?[UNITS_OF_TIME count]:3;
    }
    else
    {
        return [temperatureArry count];
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component== PICKER_NUMBERS)
    {
        if (pickerView==notifyMePicker || pickerView==locSleepPicker) {
            return [NSString stringWithFormat:@"%i", (int) row];
        } else if(pickerView== tempTypePicker)
        {
            return [temperatureArry objectAtIndex:row];
        }
    }
    else if (pickerView==notifyMePicker || pickerView==locSleepPicker) {
            return [NSString stringWithFormat:@"%@", [UNITS_OF_TIME objectAtIndex:row]];
    }
    
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == notifyMePicker) {
        if(component==PICKER_NUMBERS)
        {
            [UserData instance].userSettings.notifyMeNumber=[NSNumber numberWithInt:(int)row];
            if(! [UserData instance].userSettings.notifyMeUnit)
            {
                [UserData instance].userSettings.notifyMeUnit = [UNITS_OF_TIME objectAtIndex:0];
            }
        }
        else{
            [UserData instance].userSettings.notifyMeUnit=[NSString stringWithFormat:@"%@", [UNITS_OF_TIME objectAtIndex:row]];
            if (! [UserData instance].userSettings.notifyMeNumber)
                [UserData instance].userSettings.notifyMeNumber = [NSNumber numberWithInt:0];
        }
    }
    else if (pickerView == locSleepPicker) {
        if(component==PICKER_NUMBERS)
        {
            [UserData instance].userSettings.locationSleepNumber=[NSNumber numberWithInt:(int)row];
            if(! [UserData instance].userSettings.locationSleepUnit)
            {
                [UserData instance].userSettings.locationSleepUnit = [UNITS_OF_TIME objectAtIndex:0];
            }
        }
        else{
            [UserData instance].userSettings.locationSleepUnit=[NSString stringWithFormat:@"%@", [UNITS_OF_TIME objectAtIndex:row]];
            if (! [UserData instance].userSettings.locationSleepNumber)
                [UserData instance].userSettings.locationSleepNumber = [NSNumber numberWithInt:0];
        }
    }
    else if(pickerView==tempTypePicker) {
        [UserData instance].userSettings.temperatureType=[temperatureArry objectAtIndex:row];
    }
    
    [self setUpUi];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (pickerView==notifyMePicker || pickerView==locSleepPicker) {
        if (component == 0) {
            return 50.0;
        } else {
            return 270.0;
        }
    }
    else{
        return 160;
    }
}

#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
