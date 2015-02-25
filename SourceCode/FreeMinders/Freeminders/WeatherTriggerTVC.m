//
//  WeatherTriggerTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "WeatherTriggerTVC.h"
#import "Utils.h"
#import "MapAnnotation.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "AddressCell.h"
#import "UserLocation.h"
#import "UserLocation.h"

#define DEFAULT_MAP_SPAN 0.10

typedef enum {
    precipitationEditing,
    freezingEditing,
    severeEditing,
    skylineEditing,
    windEditing,
    temperatureEditing,
    noneEditing
} WeatherTypeEditing;

@interface WeatherTriggerTVC ()

// TYPE
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIImageView *precipitationImageView;
@property (weak, nonatomic) IBOutlet UILabel *precipitationLabel;
@property (weak, nonatomic) IBOutlet UIButton *precipitationButton;
@property (weak, nonatomic) IBOutlet UIButton *drizzleButton;
@property (weak, nonatomic) IBOutlet UIButton *rainButton;
@property (weak, nonatomic) IBOutlet UIButton *lightTStormsButton;
@property (weak, nonatomic) IBOutlet UIButton *thunderstormsButton;
@property (weak, nonatomic) IBOutlet UIButton *severeTStormsButton;

@property (weak, nonatomic) IBOutlet UIImageView *freezingImageView;
@property (weak, nonatomic) IBOutlet UILabel *freezingLabel;
@property (weak, nonatomic) IBOutlet UIButton *freezingButton;
@property (weak, nonatomic) IBOutlet UIButton *freezingDrizzleButton;
@property (weak, nonatomic) IBOutlet UIButton *freezingRainButton;
@property (weak, nonatomic) IBOutlet UIButton *sleetButton;
@property (weak, nonatomic) IBOutlet UIButton *snowFlurriesButton;
@property (weak, nonatomic) IBOutlet UIButton *lightSnowButton;
@property (weak, nonatomic) IBOutlet UIButton *snowButton;
@property (weak, nonatomic) IBOutlet UIButton *heavySnowButton;

@property (weak, nonatomic) IBOutlet UIImageView *severeImageView;
@property (weak, nonatomic) IBOutlet UILabel *severeLabel;
@property (weak, nonatomic) IBOutlet UIButton *severeButton;
@property (weak, nonatomic) IBOutlet UIButton *severeThunderstormsButton;
@property (weak, nonatomic) IBOutlet UIButton *tropicalStormButton;
@property (weak, nonatomic) IBOutlet UIButton *hurricaneButton;
@property (weak, nonatomic) IBOutlet UIButton *tornadoButton;
@property (weak, nonatomic) IBOutlet UIButton *hailButton;

@property (weak, nonatomic) IBOutlet UIImageView *skylineImageView;
@property (weak, nonatomic) IBOutlet UILabel *skylineLabel;
@property (weak, nonatomic) IBOutlet UIButton *skylineButton;
@property (weak, nonatomic) IBOutlet UIButton *sunnyButton;
@property (weak, nonatomic) IBOutlet UIButton *partiallyCloudyButton;
@property (weak, nonatomic) IBOutlet UIButton *cloudyButton;

@property (weak, nonatomic) IBOutlet UIImageView *windImageView;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UIButton *windButton;
@property (weak, nonatomic) IBOutlet UIButton *windyButton;
@property (weak, nonatomic) IBOutlet UIButton *blusteryButton;

@property (weak, nonatomic) IBOutlet UIImageView *temperatureImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *temperatureButton;
@property (weak, nonatomic) IBOutlet UILabel *tempDegreesLabel;
@property (weak, nonatomic) IBOutlet UISlider *tempSlider;
@property (weak, nonatomic) IBOutlet UIButton *tempAboveButton;
@property (weak, nonatomic) IBOutlet UIButton *tempBelowButton;
@property (weak, nonatomic) IBOutlet UIButton *tempMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *tempPlusButton;

@property (nonatomic) WeatherTypeEditing weatherTypeEditing;

// TIME
@property (weak, nonatomic) IBOutlet UITextField *notifySpecificTimeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *repeatTimeSwitch;

// LOCATION
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *suggestedAddressTextField;
@property (weak, nonatomic) IBOutlet UITableView *suggestedAddressTableView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) NSArray *suggestedAddresses;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MapAnnotation *mapAnnotation;
@property (weak, nonatomic) IBOutlet UILabel *englishTextLabel;
@property (nonatomic) BOOL isLocationSelected;

@property (nonatomic) AlertType alertType;

@property (strong, nonatomic) NSMutableString *proposedTextForSearch;

@end

@implementation WeatherTriggerTVC

NSArray *weatherImages, *weatherButtons, *weatherLabels;
NSInteger SECTION_WEATHER_TYPE = 1, SECTION_TIME = 2, SECTION_LOCATION = 3 ,SECTION_PLACEHOLDER = 4, SECTION_ENGLISHTEXT = 5;
NSInteger ROW_PRECIPITATION = 1, ROW_FREEZING = 2, ROW_SEVERE = 3, ROW_SKYLINE = 5, ROW_WIND = 6, ROW_TEMP = 7;
UIPickerView *specificTimePicker;
NSArray *SPECIFIC_TIME_NUMBERS, *SPECIFIC_TIME_AMPM, *SPECIFIC_TIME_DAYS, *HOURS_BEFORE,*SPECIFIC_TIME_MINTS;
bool forZeroinMInts;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // This will remove extra separators from tableviews
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.suggestedAddressTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
   
    if (![UserData instance].task.weatherTriggers.count) {
        [UserData instance].task.weatherTriggers = [[NSMutableArray alloc] init];
        [[UserData instance].task.weatherTriggers addObject:[[WeatherTrigger alloc] init]];
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature = [NSNumber numberWithInt:32];
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm = @"AM";
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour = [NSNumber numberWithInt:9];
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyDays = [NSNumber numberWithInt:0];
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin = [NSNumber numberWithInt:0];
        
        if ([UserData instance].userSettings.alertTime) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[UserData instance].userSettings.alertTime];
            NSInteger hour = [components hour];
            NSInteger mint =[components minute];
            NSString *ampm = @"AM";
            if (hour > 12) {
                ampm = @"PM";
                hour %= 12;
            }
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm = ampm;
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour = [NSNumber numberWithInt:hour];
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin = [NSNumber numberWithInt:mint];
        }
        // Location
        if([UserData instance].userLocations > 0)
        {
            for(int i = 0; i < [UserData instance].userLocations.count; i++)
            {
                if(((UserLocation *)([[UserData instance].userLocations objectAtIndex:i])).isDefault)
                {
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location=((UserLocation *)([[UserData instance].userLocations objectAtIndex:i])).location;
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).userLocation = ((UserLocation *)([[UserData instance].userLocations objectAtIndex:i]));
                    self.addressLabel.text=((UserLocation *)([[UserData instance].userLocations objectAtIndex:i])).address;
                }
            }
        }else if ([UserData instance].userInfo.defaultLocationPoint) {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = [UserData instance].userInfo.defaultLocationPoint;
             self.addressLabel.text=@"Your Location";
            
        } else {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
        }
        // Zip code
        if ([UserData instance].userInfo.defaultLocationZIP) {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).zipCode = [UserData instance].userInfo.defaultLocationZIP;
        } else {
            [self performGetPostalCodeForCoordinates];
        }
        // Address
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address = [UserData instance].userInfo.defaultLocationAddress;
        
        [((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]) saveInBackground];
    }
    UserLocation *usrLocation = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).userLocation;
    if (usrLocation && ![usrLocation isEqual:[NSNull null]]) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).userLocation.location;
    }
    
    weatherImages = [[NSArray alloc] initWithObjects:self.precipitationImageView, self.freezingImageView, self.severeImageView, self.skylineImageView, self.temperatureImageView, self.windImageView, nil];
    weatherButtons = [[NSArray alloc] initWithObjects:self.precipitationButton, self.freezingButton, self.severeButton, self.skylineButton, self.temperatureButton, self.windButton, nil];
    weatherLabels = [[NSArray alloc] initWithObjects:self.precipitationLabel, self.freezingLabel, self.severeLabel, self.skylineLabel, self.temperatureLabel, self.windLabel, nil];
    
    self.weatherTypeEditing = noneEditing;
    
    [self setupTimePickers];
//    [self setupGestureRecognizers];
    [self setupUI];
    [self Englishtext];
    [self setUpBoaderForButtons];
}
-(void)Englishtext
{
    // English text label Data
    
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
            [string appendString:@"1 or more "];
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
    self.englishTextLabel.numberOfLines=6;
    self.englishTextLabel.text = string;
    self.englishTextLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:12.0];
}

- (void)setupTimePickers
{
     SPECIFIC_TIME_MINTS= [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59",nil];
    SPECIFIC_TIME_NUMBERS = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
    SPECIFIC_TIME_AMPM = [[NSArray alloc] initWithObjects:@"AM", @"PM", nil];
    SPECIFIC_TIME_DAYS = [[NSArray alloc] initWithObjects:@"The Day Of", @"1 Day Before", @"2 Days Before", @"3 Days Before",@"4 Days Before",@"5 Days Before", nil];
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                  target:self action:@selector(pickerCancelled)];
    [pickerToolbar setItems:[NSArray arrayWithObjects: spaceItem, doneButton, spaceItem ,nil] animated:NO];
    
    specificTimePicker = [[UIPickerView alloc] init];
    specificTimePicker.dataSource = self;
    specificTimePicker.delegate = self;
    self.notifySpecificTimeTextField.inputView = specificTimePicker;
    self.notifySpecificTimeTextField.inputAccessoryView = pickerToolbar;
    
    HOURS_BEFORE = [[NSArray alloc] initWithObjects:@"1 Hour Before", @"2 Hours Before", @"3 Hours Before", @"4 Hours Before", @"5 Hours Before", @"6 Hours Before", nil];
    
    // SET SELECTED ROWS
    [specificTimePicker selectRow:(((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin.intValue - 1) inComponent:1 animated:NO];
    [specificTimePicker selectRow:(((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour.intValue - 1) inComponent:0 animated:NO];
    if ([((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm.lowercaseString isEqualToString:@"pm"])
        [specificTimePicker selectRow:1 inComponent:2 animated:NO];
    [specificTimePicker selectRow:((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyDays.intValue inComponent:3 animated:NO];
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}
-(void)setUpBoaderForButtons
{
    [[self.drizzleButton layer] setBorderWidth:1.0f];
    [[self.drizzleButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.drizzleButton layer] setMasksToBounds:YES];
    
    [[self.rainButton layer] setBorderWidth:1.0f];
    [[self.rainButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.rainButton layer] setMasksToBounds:YES];
    
    [[self.lightTStormsButton layer] setBorderWidth:1.0f];
    [[self.lightTStormsButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.lightTStormsButton layer] setMasksToBounds:YES];
    
    [[self.thunderstormsButton layer] setBorderWidth:1.0f];
    [[self.thunderstormsButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.thunderstormsButton layer] setMasksToBounds:YES];
    
    [[self.severeTStormsButton layer] setBorderWidth:1.0f];
    [[self.severeTStormsButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.severeTStormsButton layer] setMasksToBounds:YES];
    
    [[self.freezingDrizzleButton layer] setBorderWidth:1.0f];
    [[self.freezingDrizzleButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.freezingDrizzleButton layer] setMasksToBounds:YES];
    
    [[self.freezingRainButton layer] setBorderWidth:1.0f];
    [[self.freezingRainButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.freezingRainButton layer] setMasksToBounds:YES];
    
    [[self.sleetButton layer] setBorderWidth:1.0f];
    [[self.sleetButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.sleetButton layer] setMasksToBounds:YES];
    
    [[self.snowFlurriesButton layer] setBorderWidth:1.0f];
    [[self.snowFlurriesButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.snowFlurriesButton layer] setMasksToBounds:YES];
    
    [[self.lightSnowButton layer] setBorderWidth:1.0f];
    [[self.lightSnowButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.lightSnowButton layer] setMasksToBounds:YES];
    
    [[self.snowButton layer] setBorderWidth:1.0f];
    [[self.snowButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.snowButton layer] setMasksToBounds:YES];
    
    [[self.heavySnowButton layer] setBorderWidth:1.0f];
    [[self.heavySnowButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.heavySnowButton layer] setMasksToBounds:YES];
    
    [[self.severeThunderstormsButton layer] setBorderWidth:1.0f];
    [[self.severeThunderstormsButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.severeThunderstormsButton layer] setMasksToBounds:YES];
    
    [[self.tropicalStormButton layer] setBorderWidth:1.0f];
    [[self.tropicalStormButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.tropicalStormButton layer] setMasksToBounds:YES];
    
    [[self.hurricaneButton layer] setBorderWidth:1.0f];
    [[self.hurricaneButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.hurricaneButton layer] setMasksToBounds:YES];
    
    [[self.tornadoButton layer] setBorderWidth:1.0f];
    [[self.tornadoButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.tornadoButton layer] setMasksToBounds:YES];
    
    [[self.hailButton layer] setBorderWidth:1.0f];
    [[self.hailButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.hailButton layer] setMasksToBounds:YES];
    
    [[self.sunnyButton layer] setBorderWidth:1.0f];
    [[self.sunnyButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.sunnyButton layer] setMasksToBounds:YES];
    
    [[self.partiallyCloudyButton layer] setBorderWidth:1.0f];
    [[self.partiallyCloudyButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.partiallyCloudyButton layer] setMasksToBounds:YES];
    
    [[self.cloudyButton layer] setBorderWidth:1.0f];
    [[self.cloudyButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.cloudyButton layer] setMasksToBounds:YES];
    
    [[self.windyButton layer] setBorderWidth:1.0f];
    [[self.windyButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.windyButton layer] setMasksToBounds:YES];
    
    [[self.blusteryButton layer] setBorderWidth:1.0f];
    [[self.blusteryButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.blusteryButton layer] setMasksToBounds:YES];
    
    [[self.tempAboveButton layer] setBorderWidth:1.0f];
    [[self.tempAboveButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.tempAboveButton layer] setMasksToBounds:YES];
    
    [[self.tempBelowButton layer] setBorderWidth:1.0f];
    [[self.tempBelowButton layer] setBorderColor:COLOR_FREEMINDER_BLUE.CGColor];
    [[self.tempBelowButton layer] setMasksToBounds:YES];
}

- (void)hideKeyboard
{
    [self.suggestedAddressTextField resignFirstResponder];
    [self.notifySpecificTimeTextField resignFirstResponder];
}
- (IBAction)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupMap
{
    if (((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.latitude != 0.0
        && ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.longitude != 0.0) {
        float lat = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.latitude;
        float lng = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.longitude;
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        self.mapAnnotation = [[MapAnnotation alloc] init];
        [self.mapAnnotation setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
        [self.mapView addAnnotation:self.mapAnnotation];
        
        MKCoordinateSpan span = MKCoordinateSpanMake(DEFAULT_MAP_SPAN, DEFAULT_MAP_SPAN);
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lng), span);
        [self.mapView setRegion:region animated:NO];
        
        if (((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address.length > 0) {
            self.addressLabel.text = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address;
            self.addressLabel.hidden = NO;
        }
    }
}

- (void)setupUI
{
    // weather buttons
    [self updateButtonsImageViewsAndLabelsForWeatherSubtypes];
    
    self.drizzleButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isDrizzleOption;
    self.rainButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRainOption;
    self.lightTStormsButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightTStormsOption;
    self.thunderstormsButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTStormsOption;
    self.severeTStormsButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereTStormsOption;
    
    self.freezingDrizzleButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingDrizzleOption;
    self.freezingRainButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingRainOption;
    self.sleetButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSleetOption;
    self.snowFlurriesButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowFlurriesOption;
    self.lightSnowButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightSnowOption;
    self.snowButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowOption;
    self.heavySnowButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHeavySnowOption;
    
    self.severeThunderstormsButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereStormOption;
    self.tropicalStormButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTropicalStormOption;
    self.hurricaneButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHurricaneOption;
    self.tornadoButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTornadoOption;
    self.hailButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHailOption;
    
    self.sunnyButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSunnyOption;
    self.partiallyCloudyButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPartiallyCloudyOption;
    self.cloudyButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isCloudyOption;
    
    self.windyButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWindyOption;
    self.blusteryButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isBlusteryOption;
    
    self.tempAboveButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp;
    self.tempBelowButton.selected = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp;
    if (((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature) {
        NSString *unit = [UserData instance].userSettings.temperatureType?[[UserData instance].userSettings.temperatureType substringToIndex:1]:@"F";
        self.tempDegreesLabel.text = [NSString stringWithFormat:@"%@˚%@",((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.stringValue, unit];
        [self.tempSlider setValue:((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.floatValue];
    }
    
    // time labels
    [self Englishtext];
    [self setupNotifyLabels];
    [self.repeatTimeSwitch setOn:((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRepeat];
    
    // location
    [self setupMap];
  
    
    [self.tableView reloadData];
}

- (void)setupNotifyLabels
{
    int indexOfDaysBefore = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyDays.intValue;
    self.notifySpecificTimeTextField.text = [NSString stringWithFormat:@"%@:%@%@ %@",((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour, ([((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin intValue]>10?((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin:[NSString stringWithFormat:@"0%d",[((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin intValue]]), ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm, [SPECIFIC_TIME_DAYS objectAtIndex:indexOfDaysBefore]];
}

- (void)pickerDone
{
    [self pickerView:specificTimePicker didSelectRow:[specificTimePicker selectedRowInComponent:0] inComponent:0];
    [self pickerView:specificTimePicker didSelectRow:[specificTimePicker selectedRowInComponent:1] inComponent:1];
    [self pickerView:specificTimePicker didSelectRow:[specificTimePicker selectedRowInComponent:2] inComponent:2];
    [self pickerView:specificTimePicker didSelectRow:[specificTimePicker selectedRowInComponent:3] inComponent:3];
    [self hideKeyboard];
}

- (void)pickerCancelled
{
    [self hideKeyboard];
}

#pragma mark- UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView] && ! [self.suggestedAddressTextField isEditing]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark- Actions

- (IBAction)weatherButtonPressed:(UIButton *)button
{
    [self setWeatherTypeForButton:button];
    
    [self setupUI];
}

- (IBAction)weatherOptionButtonPressed:(UIButton *)button
{
    if (button == self.drizzleButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isDrizzleOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isDrizzleOption;
    } else if (button == self.rainButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRainOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRainOption;
    } else if (button == self.lightTStormsButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightTStormsOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightTStormsOption;
    } else if (button == self.thunderstormsButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTStormsOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTStormsOption;
    } else if (button == self.severeTStormsButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereTStormsOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereTStormsOption;
    } else if (button == self.freezingDrizzleButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingDrizzleOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingDrizzleOption;
    } else if (button == self.freezingRainButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingRainOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingRainOption;
    } else if (button == self.sleetButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSleetOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSleetOption;
    } else if (button == self.snowFlurriesButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowFlurriesOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowFlurriesOption;
    } else if (button == self.lightSnowButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightSnowOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightSnowOption;
    } else if (button == self.snowButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowOption;
    } else if (button == self.heavySnowButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHeavySnowOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHeavySnowOption;
    } else if (button == self.severeThunderstormsButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereStormOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereStormOption;
    } else if (button == self.tropicalStormButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTropicalStormOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTropicalStormOption;
    } else if (button == self.hurricaneButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHurricaneOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHurricaneOption;
    } else if (button == self.tornadoButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTornadoOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTornadoOption;
    } else if (button == self.hailButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHailOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHailOption;
    } else if (button == self.sunnyButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSunnyOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSunnyOption;
    } else if (button == self.partiallyCloudyButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPartiallyCloudyOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPartiallyCloudyOption;
    } else if (button == self.cloudyButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isCloudyOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isCloudyOption;
    } else if (button == self.windyButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWindyOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWindyOption;
    } else if (button == self.blusteryButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isBlusteryOption = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isBlusteryOption;
    } else if (button == self.tempAboveButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp;
        
        if (((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp)
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp = NO;
        
    } else if (button == self.tempBelowButton) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp = ! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp;
        
        if (((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp)
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp = NO;
    }
    
    [self setupUI];
}

- (IBAction)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    [self.tableView reloadData];
}

- (IBAction)tempSliderChanged:(UISlider *)slider
{
    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature = [NSNumber numberWithInt:(int) slider.value];
    self.tempDegreesLabel.text = [NSString stringWithFormat:@"%@˚%@",((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.stringValue, [[UserData instance].userSettings.temperatureType substringToIndex:1]];
    [self Englishtext];
}
- (IBAction)tempButtonPressed:(UIButton *)button
{
    if (button == self.tempMinusButton
        && ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.floatValue > self.tempSlider.minimumValue) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature = [NSNumber numberWithInt:(((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.intValue - 1)];
    } else if (button == self.tempPlusButton
               && ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.floatValue < self.tempSlider.maximumValue) {
        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature = [NSNumber numberWithInt:(((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.intValue + 1)];
    }
    
    self.tempDegreesLabel.text = [NSString stringWithFormat:@"%@˚%@",((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.stringValue, [[UserData instance].userSettings.temperatureType substringToIndex:1]];
    [self.tempSlider setValue:((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).temperature.floatValue];
}

- (IBAction)doneButtonPressed
{
    [UserData instance].didChangeTrigger = YES;
    [UserData instance].task.lastNotificationDate=nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)repeatSwitchValueChanged:(UISwitch *)sender
{
    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRepeat = sender.isOn;
    
}

#pragma mark- UITextField methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.suggestedAddressTextField) {
        [self hideKeyboard];
        
//        if (textField.text.length > 0)
//            [self performSearchForAddresses:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _proposedTextForSearch = [NSMutableString stringWithString:textField.text];
    [_proposedTextForSearch replaceCharactersInRange:range withString:string];
    [self performSearchForAddresses:_proposedTextForSearch];
    // Do stuff.
    return YES; // Or NO. Whatever. It's your function.
}
#pragma mark- UIPickerView methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == specificTimePicker) {
        if(component == 1)
        {
            return SPECIFIC_TIME_MINTS.count;
        }
        else if (component == 0) {
            return SPECIFIC_TIME_NUMBERS.count;
        } else if (component == 2) {
            return SPECIFIC_TIME_AMPM.count;
        } else {
            return SPECIFIC_TIME_DAYS.count;
        }
    } else {
        return HOURS_BEFORE.count;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == specificTimePicker) {
        return 4;
    } else {
        return 1;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == specificTimePicker) {
        if(component == 1)
        {
            return [SPECIFIC_TIME_MINTS objectAtIndex:row];
        }
        else if (component == 0) {
            return [SPECIFIC_TIME_NUMBERS objectAtIndex:row];
        } else if (component == 2) {
            return [SPECIFIC_TIME_AMPM objectAtIndex:row];
        } else {
            return [SPECIFIC_TIME_DAYS objectAtIndex:row];
        }
    } else {
        return [HOURS_BEFORE objectAtIndex:row];
    }}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == specificTimePicker) {
        
        
        if(component == 1)
        {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin = [NSNumber numberWithInt:[[SPECIFIC_TIME_MINTS objectAtIndex:row] intValue]];
        }else if (component == 0) {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour = [NSNumber numberWithInt:[[SPECIFIC_TIME_NUMBERS objectAtIndex:row] intValue]];
        } else if (component == 2) {
           ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm = [SPECIFIC_TIME_AMPM objectAtIndex:row];
        } else {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyDays = [NSNumber numberWithInteger:row];
        }
        
        if (! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour) {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyHour = [NSNumber numberWithInt:[[SPECIFIC_TIME_NUMBERS objectAtIndex:row] intValue]];
        }
        if (! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin) {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyMin = [NSNumber numberWithInt:[[SPECIFIC_TIME_MINTS objectAtIndex:row] intValue]];
        }
        if (! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm) {
           ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyAmPm = [SPECIFIC_TIME_AMPM objectAtIndex:0];
        }
        if (! ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyDays) {
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).notifyDays = [NSNumber numberWithInteger:0];
        }
    }
      [self setupNotifyLabels];
      [self Englishtext];
    
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return 45.0;
    } else if (component == 1) {
        return 45.0;
    } else if(component == 2)
    {
        return 50.0;
    }else{
        return 180.0;
    }
}

#pragma mark- UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [super numberOfSectionsInTableView:tableView];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [super tableView:tableView numberOfRowsInSection:section];
    } else {
        if(_proposedTextForSearch.length>0)
        {
            return self.suggestedAddresses.count;
        }
        else{
            return [[UserData instance].userLocations count] + 1;
        }
       
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        if(_proposedTextForSearch.length>0)
        {
//        if (indexPath.row == 0) {
//            NSString *CELL_IDENTIFIER = @"currentLocationCell";
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
//            
//            if (cell == nil)
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
//            
//            return cell;
//        }
        NSString *CELL_IDENTIFIER = @"addressCell";
        AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        
        if (cell == nil)
            cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    
            SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row)];
            cell.textLabel.text = place.name;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:11];
            return cell;
        }
        else{
            if (indexPath.row == 0) {
                NSString *CELL_IDENTIFIER = @"currentLocationCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
                
                if (cell == nil)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
                
                return cell;
            }
            
            NSString *CELL_IDENTIFIER = @"addressCell";
            AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
            
            if (cell == nil)
                cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
            
            if (indexPath.row < [[UserData instance].userLocations count]+1) {
                UserLocation *location = [[UserData instance].userLocations objectAtIndex:indexPath.row-1];
                NSString *address = [NSString stringWithFormat:@"%@ %@",location.name, location.isDefault?@"(Default)":@""];
                cell.textLabel.text = address;
                cell.textLabel.textColor = [UIColor grayColor];
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                
            }
            return cell;
        }
        
        
    }
    
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        NSInteger row = indexPath.row;
        NSInteger section = indexPath.section;
        
        if (section == SECTION_WEATHER_TYPE) {
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                if (row == ROW_PRECIPITATION && self.weatherTypeEditing != precipitationEditing) {
                    return 0.0;
                } else if (row == ROW_FREEZING && self.weatherTypeEditing != freezingEditing) {
                    return 0.0;
                } else if (row == ROW_SEVERE && self.weatherTypeEditing != severeEditing) {
                    return 0.0;
                } else if (row == ROW_SKYLINE && self.weatherTypeEditing != skylineEditing) {
                    return 0.0;
                } else if (row == ROW_WIND && self.weatherTypeEditing != windEditing) {
                    return 0.0;
                } else if (row == ROW_TEMP && self.weatherTypeEditing != temperatureEditing) {
                    return 0.0;
                } else {
                    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
                }
            } else {
                return 0.0;
            }
        } else if (section == SECTION_TIME) {
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            } else {
                return 0.0;
            }
        }
        else if(section == SECTION_ENGLISHTEXT ){
            if(self.segmentedControl.selectedSegmentIndex == 0)
            {
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }else
            {
                return 0.0;
            }
        }else if (section == SECTION_LOCATION) {
            if (self.segmentedControl.selectedSegmentIndex == 1) {
                int addition = [[UIScreen mainScreen] bounds].size.height == 568 ? 88 : 0;
                return [super tableView:tableView heightForRowAtIndexPath:indexPath] + addition;
            } else {
                return 0.0;
            }
        } else if (section == SECTION_PLACEHOLDER) {
            return 0.0;
        } else {
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    } else {
        return 40.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == SECTION_WEATHER_TYPE) {
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                return [super tableView:tableView heightForHeaderInSection:section];
            } else {
                return 0.0;
            }
        } else if (section == SECTION_TIME) {
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                return [super tableView:tableView heightForHeaderInSection:section];
            } else {
                return 0.0;
            }
        }
        else if (section == SECTION_ENGLISHTEXT) {
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                return [super tableView:tableView heightForHeaderInSection:section];
            }else
            {
                return 0.0;
            }
        }else if (section == SECTION_LOCATION) {
            if (self.segmentedControl.selectedSegmentIndex == 1) {
                return [super tableView:tableView heightForHeaderInSection:section];
            } else {
                return 0.0;
            }
        } else if (section == SECTION_PLACEHOLDER) {
            return 0.0;
        } else {
            return [super tableView:tableView heightForHeaderInSection:section];
        }
    } else {
        return 0.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == self.tableView) {
        // DO NOTHING
    } else {
                [self hideKeyboard];
        if(self.suggestedAddressTextField.text.length > 0)
        {
            //        if (indexPath.row == 0) {
            //            double lat = [UserData instance].location.coordinate.latitude;
            //            double lng = [UserData instance].location.coordinate.longitude;
            //            if (lat != 0.0 && lng != 0.0) {
            //                ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
            //                ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address = @"Your Location";
            //                [self performGetPostalCodeForCoordinates];
            //                [self setupMap];
            //            } else {
            //                self.alertType = locationServices;
            //                [Utils showSimpleAlertViewWithTitle:@"Allow Location Services" content:@"Allow location services to center on your location" andDelegate:self];
            //            }
            //        }else {
            //        {
            if([self.suggestedAddresses count] > indexPath.row)            {
                SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row)];
                if (place) {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                        NSLog(@"Placemark: %@", placemark);
                        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:placemark.location];
                        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address = addressString;
                        ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).userLocation = nil;
                        if (placemark.postalCode)
                            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).zipCode = placemark.postalCode;
                        else if (((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.latitude != 0.0
                                 && ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.longitude != 0.0)
                            [self performGetPostalCodeForCoordinates];
                        else
                            [Utils showSimpleAlertViewWithTitle:@"Invalid Address" content:@"Please choose a different location. There was a problem getting data on the chosen location" andDelegate:self];
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [self setupMap];
                    }];
                }
                
            }
        }else
        {
            if (indexPath.row == 0) {
                double lat = [UserData instance].location.coordinate.latitude;
                double lng = [UserData instance].location.coordinate.longitude;
                if (lat != 0.0 && lng != 0.0) {
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address = @"Your Location";
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).userLocation = nil;
                    [self performGetPostalCodeForCoordinates];
                    [self setupMap];
                } else {
                    self.alertType = locationServices;
                    [Utils showSimpleAlertViewWithTitle:@"Allow Location Services" content:@"Allow location services to center on your location" andDelegate:self];
                }
            }else
            {
                if(indexPath.row < [[UserData instance].userLocations count]+1){
                    UserLocation *location = [[UserData instance].userLocations objectAtIndex:indexPath.row-1];
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location = location.location;
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).address = location.address;
                    ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).userLocation = location;
                    [self setupMap];
                }
                
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
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

#pragma mark- Alertview methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == locationServices) {
        NSURL*url=[NSURL URLWithString:@"prefs://"];
        [[UIApplication sharedApplication] openURL:url];
        [self getUserLocation];
        
    }
    
    self.alertType = none;
}
- (void)getUserLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark- Utils

- (UIButton *)buttonForWeatherImageView:(UIImageView *)imageView
{
    NSInteger index = [weatherImages indexOfObject:imageView];
    
    if (index < 0 || index >= weatherButtons.count) {
        return nil;
    } else {
        return [weatherButtons objectAtIndex:index];
    }
}

- (UIImageView *)imageViewForWeatherButton:(UIButton *)button
{
    NSInteger index = [weatherButtons indexOfObject:button];
    
    if (index < 0 || index >= weatherImages.count) {
        return nil;
    } else {
        return [weatherImages objectAtIndex:index];
    }
}

- (UILabel *)labelForWeatherButton:(UIButton *)button
{
    NSInteger index = [weatherButtons indexOfObject:button];
    
    if (index < 0 || index >= weatherLabels.count) {
        return nil;
    } else {
        return [weatherLabels objectAtIndex:index];
    }
}

- (void)setWeatherTypeForButton:(UIButton *)button
{
    if (button == self.precipitationButton) {
        if (self.weatherTypeEditing == precipitationEditing)
            self.weatherTypeEditing = noneEditing;
        else
            self.weatherTypeEditing = precipitationEditing;
    } else if (button == self.freezingButton) {
        if (self.weatherTypeEditing == freezingEditing)
            self.weatherTypeEditing = noneEditing;
        else
            self.weatherTypeEditing = freezingEditing;
    } else if (button == self.severeButton) {
        if (self.weatherTypeEditing == severeEditing)
            self.weatherTypeEditing = noneEditing;
        else
            self.weatherTypeEditing = severeEditing;
    } else if (button == self.skylineButton) {
        if (self.weatherTypeEditing == skylineEditing)
            self.weatherTypeEditing = noneEditing;
        else
            self.weatherTypeEditing = skylineEditing;
    } else if (button == self.windButton) {
        if (self.weatherTypeEditing == windEditing)
            self.weatherTypeEditing = noneEditing;
        else
            self.weatherTypeEditing = windEditing;
    } else if (button == self.temperatureButton) {
        if (self.weatherTypeEditing == temperatureEditing)
            self.weatherTypeEditing = noneEditing;
        else
            self.weatherTypeEditing = temperatureEditing;
    }
}

- (void)updateButtonsImageViewsAndLabelsForWeatherSubtypes
{
    for (UIImageView *imageView in weatherImages) {
        if (imageView == self.precipitationImageView) {
            
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPrecipitation = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isDrizzleOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isRainOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightTStormsOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTStormsOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereTStormsOption;
            self.precipitationImageView.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPrecipitation;
            self.precipitationLabel.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPrecipitation;
            
        } else if (imageView == self.freezingImageView) {
            
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezing = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingDrizzleOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezingRainOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSleetOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowFlurriesOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isLightSnowOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSnowOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHeavySnowOption;
            
            self.freezingImageView.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezing;
            self.freezingLabel.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isFreezing;
            
        } else if (imageView == self.severeImageView) {
            
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevere = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevereStormOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTropicalStormOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHurricaneOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTornadoOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isHailOption;
            
            self.severeImageView.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevere;
            self.severeLabel.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSevere;
            
        } else if (imageView == self.skylineImageView) {
            
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSkyline = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSunnyOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isPartiallyCloudyOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isCloudyOption;
            
            self.skylineImageView.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSkyline;
            self.skylineLabel.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isSkyline;
            
        } else if (imageView == self.windImageView) {
            
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWind = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWindyOption
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isBlusteryOption;
            
            self.windImageView.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWind;
            self.windLabel.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isWind;
            
        } else if (imageView == self.temperatureImageView) {
            
            ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTemperature = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp
            || ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp;
            
            self.temperatureImageView.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTemperature;
            self.temperatureLabel.highlighted = ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).isTemperature;
            
        }
    }
}

#pragma mark- Networking

- (void)performSearchForAddresses:(NSString *)queryString
{
    self.suggestedAddresses = [[NSArray alloc] init];
    [self.suggestedAddressTableView reloadData];
    
    SPGooglePlacesAutocompleteQuery *query = [SPGooglePlacesAutocompleteQuery query];
    query.input = queryString;
    query.language = @"en";
    query.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    query.sensor = YES;
    
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        NSLog(@"Places returned %@", places);
        
        self.suggestedAddresses = places;
        [self.suggestedAddressTableView reloadData];
    }];
}

- (void)performGetPostalCodeForCoordinates
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.latitude longitude:((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).location.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error)) {
             CLPlacemark *placemark = [placemarks firstObject];
             if (placemark.postalCode) {
                 ((WeatherTrigger *)[[UserData instance].task.weatherTriggers objectAtIndex:0]).zipCode = placemark.postalCode;
             } else {
                 NSLog(@"COULDN'T GET ZIP CODE FOR LOCATION");
             }
         } else {
             NSLog(@"Geocode failed with error %@", error);
         }
         
         [[UserData instance].task saveInBackground];
     }];
}

#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
