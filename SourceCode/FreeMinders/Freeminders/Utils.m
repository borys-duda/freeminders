//
//  Utils.m
//  Stadium Guide
//
//  Created by Spencer Morris on 11/6/13.
//  Copyright (c) 2013 Scalpr. All rights reserved.
//

#import "Utils.h"
#import "UserData.h"
#import "WeatherTrigger.h"
#import "DateTimeTrigger.h"
#import "StoreItem.h"
#import "ReminderStep.h"
#import "UserInfo.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import "UserContact.h"
#import "UserLocation.h"
#import "UserSetting.h"
#import "UserPurchase.h"
#import "StoreHelper.h"

#import "Interpreter.h"
#import "InterpreterAdapter.h"

@implementation Utils

+ (void)registerAllParseClasses
{
    [Reminder registerSubclass];
    [ReminderGroup registerSubclass];
    [WeatherTrigger registerSubclass];
    [DateTimeTrigger registerSubclass];
    [LocationTrigger registerSubclass];
    [StoreItem registerSubclass];
//    [UserInfo registerSubclass];
    [ReminderStep registerSubclass];
    [UserLocation registerSubclass];
    [UserContact registerSubclass];
    [UserSetting registerSubclass];
    [UserPurchase registerSubclass];
}

+ (NSString *)milesStringBetweenLocation:(CLLocation *)loc1 andLocation:(Location *)loc2
{
    NSNumber *distance = [Utils milesBetweenLocation:loc1 andLocation:loc2];
    
    return [NSString stringWithFormat:@"%.1f", distance.floatValue];
}

+ (NSNumber *)milesBetweenLocation:(CLLocation *)loc1 andLocation:(Location *)loc2
{
    if (! loc1 || ! loc2)
        return nil;
    
    double lat1 = loc1.coordinate.latitude;
    double long1 = loc1.coordinate.longitude;
    double lat2 = loc2.latitude.doubleValue;
    double long2 = loc2.longitude.doubleValue;
    double dlong = (long2 - long1)*PI/180;
    double dlat  = (lat2 - lat1)*PI/180;
    
    // Haversine formula:
    double R = 3959;
    double a = sin(dlat/2)*sin(dlat/2) + cos(lat1)*cos(lat2)*sin(dlong/2)*sin(dlong/2);
    double c = 2 * atan2( sqrt(a), sqrt(1-a) );
    double d = R * c;
    
    return [NSNumber numberWithDouble:d];
}

+ (ReminderGroup *)getTaskGroupNameForId:(NSString *)groupId
{
    for (ReminderGroup *set in [UserData instance].taskSets) {
        if ([set.objectId isEqualToString:groupId])
            return set;
    }
    
    return nil;
}

+ (NSString *)imageFilenameForTrigger:(TriggerType)triggerType
{
    switch (triggerType) {
        case noTrigger:
            return @"task_line_Notrigger_Icon.png";
            break;
            
        case weatherTrigger:
            return @"task_line_sun_icon_blue.png";
            break;
            
        case locationTrigger:
            return @"task_line_pin_icon_blue.png";
            break;
            
        case datetimeTrigger:
            return @"task_line_clock_icon_blue.png";
            break;
            
        default:
            break;
    }
}

+ (NSString *)adjectiveFromPluralNoun:(NSString *)noun
{
    if ([noun isEqualToString:@"Days"]) {
        return @"Daily";
    }
    
    NSString *adj = noun;
    
    if ([adj hasSuffix:@"s"]) {
        NSRange lastS = [adj rangeOfString:@"s" options:NSBackwardsSearch];
        adj = [adj stringByReplacingCharactersInRange:lastS withString:@"ly"];
    }
    
    return adj;
}
+ (NSString *)suffixOfDateNumber:(int)date
{
    NSMutableString *abbreviation = [NSMutableString stringWithFormat:@"%d",date];
    NSArray *ends = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
    if ((date%100) >= 11 && (date%100) <= 13)
        [abbreviation appendString:@"th"];
    else
        [abbreviation appendString:[ends objectAtIndex:date%10]];
    
    return abbreviation;
}
+ (NSString *)dateToText:(NSDate *)date format:(NSString *)format
{
//    NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
//    [weekdayFormatter setDateFormat: @"EEEE"];
    
    NSString *formattedDate = [NSString stringWithFormat:@"%@",[formatter stringFromDate: date]];
    return formattedDate;
}

#pragma mark- data methods

+ (BOOL)stringIsInteger:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (NSNumber *)stringToNumber:(NSString *)string
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    return [f numberFromString:string];
}

+ (NSString *)getHtmlStringFromString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    
    return string;
}

#pragma mark- NSDate methods

+ (BOOL)isDate:(NSDate *)date1 beforeDate:(NSDate *)date2
{
    return [date2 timeIntervalSinceDate:date1] > 0.0;
}

+ (BOOL)isDateInFuture:(NSDate *)date
{
    return [date timeIntervalSinceNow] > 0.0;
}

+ (NSDate *)earlierOfDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    return [self isDate:date1 beforeDate:date2] ? date1 : date2;
}

+ (NSDate *)laterOfDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    return [self isDate:date1 beforeDate:date2] ? date2 : date1;
}

+ (int)dayOfTheWeek:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [comps weekday];
    return weekday;
}
+ (int)valueFromDate:(NSDate *)date returnType:(int)type {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    switch (type) {
        case NSCalendarUnitDay:
            return [components day];
            break;
        case NSCalendarUnitMonth:
            return [components month];
            break;
        case NSCalendarUnitYear:
            return [components year];
            break;
        default:
            break;
    }
    return 0;
}

+ (NSDate *)setHoursForDate:(NSDate *)date hours:(int)hour minutes:(int)minute {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    [components setHour:hour];
    [components setMinute:minute];
    return [calendar dateFromComponents:components];
}

#pragma mark- Trigger methods

+ (BOOL)isInLocationTriggerBounds:(LocationTrigger *)locationTrigger
{
    PFGeoPoint *location = locationTrigger.location;
    if (locationTrigger.userLocation && ![locationTrigger.userLocation isEqual:[NSNull null]]) {
        location = locationTrigger.userLocation.location;
    }
    double milesBetween = [location distanceInMilesTo:[PFGeoPoint geoPointWithLocation:[UserData instance].location]];
    
    BOOL isInBounds = milesBetween < locationTrigger.radius.doubleValue;
    
    return isInBounds;
}

#pragma mark- Login/Signup

+ (void)setParseEmailForFacebookLogin
{
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *email = userData[@"email"];
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"username"];
            [[PFUser currentUser] setEmail:email];
            [[PFUser currentUser] saveEventually];
        }
    }];
}

#pragma mark- Setting Defaults on first launch

+(void)setUpDefaultSettings
{
    if (![UserData instance].userSettings.objectId){
        [UserData instance].userSettings = [[UserSetting alloc] init];
        [UserData instance].userSettings.user = [PFUser currentUser];
        [UserData instance].userSettings.notifyMeNumber = [NSNumber numberWithInt:0];
        [UserData instance].userSettings.notifyMeUnit = MINUTES;
        [UserData instance].userSettings.locationSleepNumber= [NSNumber numberWithInt:24];
        [UserData instance].userSettings.locationSleepUnit = HOURS;
        
        [UserData instance].userSettings.temperatureType =@"Fahrenheit";
        
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
        NSCalendar *cal = [NSCalendar currentCalendar];
        [today setMinute:0];
        [today setHour:7];
        NSDate *morningDate = [cal dateFromComponents:today];
        [today  setHour:9];
        NSDate *alerttimeDefault = [cal dateFromComponents:today];
        [today setHour:20];
        NSDate *toNightDefault = [cal dateFromComponents:today];
        
        [UserData instance].userSettings.inTheMorning=morningDate;
        [UserData instance].userSettings.toNight=toNightDefault;
        [UserData instance].userSettings.alertTime=alerttimeDefault;
        [[UserData instance].userSettings saveInBackground];
    }
}

+ (void)saveDefaultsForUser {
   
    if (![UserData instance].userLocations.count) {
        UserLocation *currentLocation = [[UserLocation alloc] init];
        currentLocation.location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
        currentLocation.name = @"Your Location";
        currentLocation.address = @"User Location";
        currentLocation.user=[PFUser currentUser];
        currentLocation.isDefault = YES;
        currentLocation.radius = [NSNumber numberWithFloat:3.0];
         NSLog(@"%@",[UserData instance].userLocations);
        [[UserData instance].userLocations addObject:currentLocation];
        NSLog(@"%@",[UserData instance].userLocations);
        [PFObject saveAllInBackground:[UserData instance].userLocations block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"User Locations saved");
            }
        }];
    }
}

#pragma mark- Networking

+ (BOOL)isInternetAvailable
{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}

+ (void)loadUserInfoForLogin
{   
    PFQuery *purchaseQuery = [PFQuery queryWithClassName:[UserPurchase parseClassName]];
    [purchaseQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [purchaseQuery setLimit:1000];
    [purchaseQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [UserData instance].userPurchases = objects;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"subscriptionExpireDate"];
        if ([objects.firstObject isKindOfClass:[UserPurchase class]]) {
            for (UserPurchase *purchase in objects) {
                if ([purchase.itemType isEqualToNumber:[NSNumber numberWithInt:typeSubscription]]) {
                    [UserData instance].userSubscription = purchase;
                    [[NSUserDefaults standardUserDefaults] setObject:purchase.expireDate forKey:@"subscriptionExpireDate"];
                } else if ([purchase.itemType isEqualToNumber:[NSNumber numberWithInt:typeIndividual]]) {
                    if (!purchase.expireDate) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:purchase.storeItemId];
                    }
                } else {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:purchase.storeItemId];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
    
/*    PFQuery *userInfoQuery = [PFQuery queryWithClassName:[UserInfo parseClassName]];
    [userInfoQuery whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [userInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[UserInfo class]]) {
            [UserData instance].userInfo = objects.firstObject;
        } else {
            [UserData instance].userInfo = [[UserInfo alloc] init];
            [UserData instance].userInfo.userId = [PFUser currentUser].objectId;
        }
    }];*/
    
    PFQuery *userSettingsQuery = [PFQuery queryWithClassName:[UserSetting parseClassName]];
    [userSettingsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [userSettingsQuery includeKey:@"userLocations"];
    [userSettingsQuery includeKey:@"userContacts"];
    [userSettingsQuery setLimit:1000];
    [userSettingsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[UserSetting class]]) {
            [UserData instance].userSettings = objects.firstObject;
        } else {
            [self setUpDefaultSettings];
        }
    }];
    
    PFQuery *locationsQuery = [PFQuery queryWithClassName:[UserLocation parseClassName]];
    [locationsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [locationsQuery orderByDescending:@"createdAt"];
    [locationsQuery setLimit:1000];
    [locationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[UserLocation class]]) {
            [UserData instance].userLocations = objects;
        }
        [Utils saveDefaultsForUser];
    }];
    
    PFQuery *contactsQuery = [PFQuery queryWithClassName:[UserContact parseClassName]];
    [contactsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [contactsQuery setLimit:1000];
    [contactsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[UserContact class]]) {
            [UserData instance].userContacts = objects;
        }
    }];
/*
    PFQuery *query = [PFUser query];
    [query includeKey:@"userLocations"];
    [query includeKey:@"userContacts"];
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        PFUser *userAgain = (PFUser *)object;
        if ([userAgain objectForKey:@"userLocations"])
            [UserData instance].userLocations = [userAgain objectForKey:@"userLocations"];
        if ([userAgain objectForKey:@"userContacts"])
            [UserData instance].userContacts = [userAgain objectForKey:@"userContacts"];
        [Utils saveDefaultsForUser];
    }];*/
}
+ (int)performLoadTasks
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if ([objects.firstObject isKindOfClass:[Reminder class]])
            [UserData instance].tasks = objects;
        }];
    NSLog(@"number of tasks %lu",(unsigned long)[UserData instance].tasks.count);
    return [UserData instance].tasks.count;
}
+ (void)loadDefaultTasks:(LoginVC *)target selector:(SEL)sel
{
    // Reminder one - Press + & Create a reminder
    ReminderGroup *newTaskSet = [[ReminderGroup alloc] init];
    newTaskSet.name = @"Example";
    newTaskSet.user = [PFUser currentUser];
    [newTaskSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSMutableArray *exampleReminders = [[NSMutableArray alloc] init];
            
            Reminder *task = [[Reminder alloc] init];
            task.isActive = YES;
            task.name=@"Press \"+\" & Create A Reminder";
            task.triggerType=noTrigger;
            task.user = [PFUser currentUser];
            task.isNotificationEnable=YES;
            
            task.reminderGroup = newTaskSet;
            [UserData instance].taskSets = [[UserData instance].taskSets arrayByAddingObject:newTaskSet];
            
            task.note=@"Back on the main screen in the top right is a \"+\" sign. To get started and create a new reminder simply touch that and configure the rest as you desire. Done with this reminder, swipe right from the main screen to mark \"Done\" or swipe left and delete outright.";
            if (task.triggerType == noTrigger)
                task.lastNotificationDate = [NSDate date];
            
            [exampleReminders addObject:task];
            
            
            // Reminder two - Grab An Umbrella - Rain Tomorrow
            task = [[Reminder alloc] init];
            task.isActive = YES;
            task.name=@"Grab An Umbrella - Rain Tomorrow";
            task.triggerType=weatherTrigger;
            task.user = [PFUser currentUser];
            task.reminderGroup = newTaskSet;
            task.isNotificationEnable=YES;
            task.reminderSteps = [[NSMutableArray alloc] init];
            task.note=@"This weather reminder is scheduled to remind you the night before it rains to grab an umbrella. Check out the steps and learn how to create this reminder on your own.";
            
            task.weatherTriggers = [[NSMutableArray alloc] init];
            [task.weatherTriggers addObject:[[WeatherTrigger alloc] init]];
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).notifyAmPm = @"PM";
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).notifyHour = [NSNumber numberWithInt:8];
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).notifyDays = [NSNumber numberWithInt:1];
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).notifyMin = [NSNumber numberWithInt:0];
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSleetOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isHurricaneOption=false;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isFreezingDrizzleOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isFreezing=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isFreezingRainOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isHailOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isLightTStormsOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isPrecipitation=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isRainOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isRepeat=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSevere=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSkyline=false;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isTStormsOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isTemperature=false;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isTropicalStormOption=true;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isWind=false;
            ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSevereTStormsOption=true;
            
            NSMutableArray *mutableSteps = [task.reminderSteps mutableCopy];
            for(int i=0 ;i<11;i++)
            {
                ReminderStep *step = [[ReminderStep alloc] init];
                switch (i)
                {
                    case 0:
                        step.name = @"Follow the steps below to create this reminder from scratch.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                        
                    case  1:
                        step.name = @"From the main screen touch the \"+\"";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 2:
                        step.name = @"Touch the Reminder Name field to input a Reminder Name, in this case \"Grab an Umbrella - Rain Tomorrow\"";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 3:
                        step.name = @"Tap the Reminder Group field to select a group. (Optional)";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 4:
                        step.name = @"Tap the Notes Field to input a description, comments, notes or any other free text you like about this reminder. (Optional)";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 5:
                        step.name = @"Touch the \"Weather\" icon under the Trigger section to launch the weather trigger configuration.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 6:
                        step.name = @"Expand the various weather categories and select the rain related items; Rain, Light T-Storms, Thunderstorms, etc.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 7:
                        step.name = @"In the Notify Me section touch the Specific Time and select the desired time and noticed to be notified of this event.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 8:
                        step.name = @"Touch the Repeat option to have this reminder notify you each time these weather conditions occur.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 9:
                        step.name = @"Next touch the Location tab towards the top to select a physical location to monitor for this weather event.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                    case 10:
                        step.name = @"Finally hit Save (Top-Right) and Save again to return to the main screen with your newly configured reminder displayed.";
                        step.isComplete = NO;
                        step.order = [NSNumber numberWithInt:i];
                        [mutableSteps addObject:step];
                        break ;
                }
            }
            task.reminderSteps = [mutableSteps mutableCopy];
            [exampleReminders addObject:task];
            
            // Reminder three - Install freeminders
            task = [[Reminder alloc] init];
            task.isActive = NO;
            task.name=@"Install freeminders";
            task.triggerType=noTrigger;
            task.user = [PFUser currentUser];
            task.reminderGroup = newTaskSet;
            task.isNotificationEnable=YES;
            
            task.note=@"You have already done this! This reminder is now inactive/disabled. Delete this reminder to remove it entirely.";
            if (task.triggerType == noTrigger)
                task.lastNotificationDate = [NSDate date];
            [exampleReminders addObject:task];
            if (target)
                [PFObject saveAllInBackground:exampleReminders target:target selector:sel];
            else
                [PFObject saveAllInBackground:exampleReminders];
        }
    }];
    
}
#pragma mark- Alert View

+ (void)showSimpleAlertViewWithTitle:(NSString*)title content:(NSString*)content andDelegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

#pragma mark- Location methods

+ (void)updateUserLocation
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (! error && geoPoint) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            [UserData instance].location = location;
        }
    }];
}

#pragma mark- Store methods

+ (void)addTasksFromStoreGroup:(UIView *)view
{
    //to avoid multiple downloads at the same time
    if ([UserData instance].purchaseInProgress) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:view animated:YES];
    [UserData instance].purchaseInProgress = YES;
    for (ReminderGroup *group in [UserData instance].storeGroup.reminderGroups){
        ReminderGroup *taskSet = [group copy];//[[ReminderGroup alloc] init];
        taskSet.user = [PFUser currentUser];
        taskSet.storeItem = [UserData instance].storeGroup;
        taskSet.desc = [UserData instance].storeGroup.desc;
        taskSet.isSubscribed = [[StoreHelper sharedInstance] isProductPurchased:[UserData instance].storeGroup.objectId]?NO:[UserData instance].isHavingActiveSubscription;
        // Saving reminder group initially to avoid circular dependency error whie saving reminders
        [taskSet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                NSMutableArray *groups = [[UserData instance].taskSets mutableCopy];
                [groups addObject:taskSet];
                [UserData instance].taskSets = groups;
                // determine time interval to add datetime trigger date to
                NSMutableArray *tasksDownloaded = [[NSMutableArray alloc] init];
                for (Reminder *task in taskSet.reminders) {
                    Reminder *newTask = [task copy];
                    newTask.isStoreTask = YES;
                    newTask.isSubscribed = NO;
                    newTask.user = [PFUser currentUser];
                    newTask.reminderGroup = taskSet; // Here it cause circular dependency error if the reminder group is not created
                    newTask.lastCompletionDate = nil;
                    newTask.lastNotificationDate = nil;
                    newTask.isActive = YES;
                    newTask.isNotificationEnable = YES;
                    newTask.isSubscribed = [UserData instance].isHavingActiveSubscription;
                    
                    if (task.triggerType == datetimeTrigger && [newTask.dateTimeTriggers count]) {
                        if (task.isDependentOnParent)
                            ((DateTimeTrigger *)[newTask.dateTimeTriggers objectAtIndex:0]).date = nil;
                        else
                            ((DateTimeTrigger *)[newTask.dateTimeTriggers objectAtIndex:0]).date = [[NSDate date] dateByAddingTimeInterval:0];//[((DateTimeTrigger *)[newTask.dateTimeTriggers objectAtIndex:0]).date dateByAddingTimeInterval:timeIntervalToAppend];
                    } else if (task.triggerType == locationTrigger && [newTask.locationTriggers count]) {
                        ((LocationTrigger *)[newTask.locationTriggers objectAtIndex:0]).location = [UserData instance].userInfo.defaultLocationPoint;
                        ((LocationTrigger *)[newTask.locationTriggers objectAtIndex:0]).address = [UserData instance].userInfo.defaultLocationAddress;
                    } else if (task.triggerType == weatherTrigger && [newTask.weatherTriggers count]) {
                        ((WeatherTrigger *)[newTask.weatherTriggers objectAtIndex:0]).location = [UserData instance].userInfo.defaultLocationPoint;
                        ((WeatherTrigger *)[newTask.weatherTriggers objectAtIndex:0]).zipCode = [UserData instance].userInfo.defaultLocationZIP;
                        ((WeatherTrigger *)[newTask.weatherTriggers objectAtIndex:0]).address = [UserData instance].userInfo.defaultLocationAddress;
                    }else {
                        newTask.lastNotificationDate = [NSDate date];
                    }
                    [tasksDownloaded addObject:newTask];
                }
                
                [PFObject saveAllInBackground:tasksDownloaded block:^(BOOL succeeded, NSError *error) {
                    if (!succeeded) {
                        [Utils showSimpleAlertViewWithTitle:@"Error" content:@"Problem while adding new reminders" andDelegate:nil];
                        [UserData instance].purchaseInProgress = NO;
                    }else {
                        taskSet.reminders = tasksDownloaded;
                        if (taskSet.configJSON.length) {
                            
                            // Reset and then set the user preferences.  I don't want to access any static classes inside
                            // the interpreter.  All data should be passed to it.  This makes it easier to unit test and
                            // easier to maintain.
                            [[Interpreter instance] resetUserSettings];
                            
                            if ([UserData instance].userSettings) {
                                [Interpreter instance].my_timeAlert = [TimeSpan timeOnlyFromDate:[UserData instance].userSettings.alertTime];
                                [Interpreter instance].my_timeMorning = [TimeSpan timeOnlyFromDate:[UserData instance].userSettings.inTheMorning];
                                [Interpreter instance].my_timeNight = [TimeSpan timeOnlyFromDate:[UserData instance].userSettings.toNight];
                            }
                            
                            [Interpreter instance].adapter = [[InterpreterAdapter alloc] init];
                            [Interpreter instance].complete = ^(BOOL cancelled) {
                                if (!cancelled) {
                                    // Script complete. I think we can just say save all and it will only save those that
                                    // have changed since it has built in change tracking.  If not, we'll need to loop thru
                                    // tasksDownloaded and look at the dirty/changed, add to an array and then save those
                                    [PFObject saveAllInBackground:tasksDownloaded block:^(BOOL success, NSError *error) {
                                        [MBProgressHUD hideAllHUDsForView:view animated:YES];
                                        [UserData instance].purchaseInProgress = NO;
                                        [Utils showSimpleAlertViewWithTitle:@"Reminder Group Added" content:[NSString stringWithFormat:@"The %@ is being downloaded. Please allow up to 5 minutes for integration into your account.", [UserData instance].storeGroup.name] andDelegate:self];
                                    }];
                                }
                                else {
                                    // They cancelled the script.
                                    [Utils performDeleteReminderGroupandReminders:taskSet completionHandler:^(BOOL success, NSError *error) {
                                        [MBProgressHUD hideAllHUDsForView:view animated:YES];
                                        [UserData instance].purchaseInProgress = NO;
                                        if (success)
                                            [self performLoadTasks];
                                    }];
                                }
                                [Interpreter instance].adapter = nil;
                            };
                            
                            [[Interpreter instance] executeScript:taskSet.configJSON forReminders:tasksDownloaded];
                            
                        }else {
                            [MBProgressHUD hideAllHUDsForView:view animated:YES];
                            [UserData instance].purchaseInProgress = NO;
                            [Utils showSimpleAlertViewWithTitle:@"Reminder Group Added" content:[NSString stringWithFormat:@"The %@ is being downloaded. Please allow up to 5 minutes for integration into your account.",[UserData instance].storeGroup.name ]andDelegate:self];
                        }
                    }
                 }];
            } else {
                [Utils showSimpleAlertViewWithTitle:@"Network Error" content:@"Please try again" andDelegate:nil];
                [MBProgressHUD hideAllHUDsForView:view animated:YES];
                [UserData instance].purchaseInProgress = NO;
            }
        }];
    }
}

+ (BOOL)didGroupExist:(NSString *)storeId {
    //Commented below code to allow download same group multiple times
/*    for (ReminderGroup *group in [UserData instance].taskSets) {
        if ([storeId isEqualToString:group.storeItem.objectId]) {
            return YES;
        }
    }*/
    return NO;
}

#pragma mark- Other methods
+ (BOOL)isModal:(UIViewController *)ctrl {
    return ctrl.presentingViewController.presentedViewController == ctrl
    || ctrl.navigationController.presentingViewController.presentedViewController == ctrl.navigationController
    || [ctrl.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

#pragma mark- Dependency methods

// Schedules the child reminders of input task
+ (void)scheduleDependentReminders:(Reminder *)task {
    for (Reminder *reminder in [UserData instance].tasks) {
        if (reminder.isDependent && [task.childReminders containsObject:reminder.dependencyId]) {
            NSLog(@"DEPEND : %@, Parent: %@",reminder.name, task.name);
            BOOL doProceed = YES;
            if (reminder.parentReminders.count>1) {
                NSMutableArray *parentIds = [NSMutableArray arrayWithArray:reminder.parentReminders];
                [parentIds removeObject:task.dependencyId];
                doProceed = [Utils checkForOtherParentStatus:parentIds];
            }
            if (doProceed) {
                NSLog(@"-----Proceding for further action on Dependent Task");
                ((DateTimeTrigger *)[reminder.dateTimeTriggers objectAtIndex:0]).date = [reminder dateToSetNotificationFromParentCompletion];
                NSLog(@"%@",((DateTimeTrigger *)[reminder.dateTimeTriggers objectAtIndex:0]).date);
                [PFObject saveAllInBackground:[NSArray arrayWithObjects:[reminder.dateTimeTriggers objectAtIndex:0], reminder, nil] block:^(BOOL succeeded, NSError *error) {
                    NSLog(@"Depend Rem Saved");
                }];
            }
        }
    }
}

// Returns YES if all the parents are completed, NO otherwise
+ (BOOL)checkForOtherParentStatus:(NSArray *)parents {
    for (Reminder *reminder in [UserData instance].tasks) {
        if (reminder.isDependent && [parents containsObject:reminder.dependencyId]) {
            if(!reminder.lastCompletionDate) {
                return NO;
            }
        }
    }
    return YES;
}

// Returns Parent reminder names seperated by &
+ (NSString *)getParentReminderNames:(Reminder *)task {
    @try{
        NSMutableString *titles = [[NSMutableString alloc] initWithString:@""];
        for (Reminder *reminder in [UserData instance].tasks) {
            if ([task.parentReminders containsObject:reminder.dependencyId]) {
                [titles appendFormat:@"%@ & ",reminder.name];
            }
        }
        return [titles stringByReplacingCharactersInRange:NSMakeRange(titles.length-3, 3) withString:@""];
    }@catch(NSException *e){
        return @"";
    }
}

#pragma mark- Destructive methods
+(void)performDeleteReminderGroupandReminders:(ReminderGroup *)taskSet completionHandler:(DeleteGroupHandler)handler
{
    
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] initWithObjects:taskSet, nil];
    [itemsToDelete addObjectsFromArray:taskSet.reminders];
/*    for (Reminder *task in [UserData instance].tasks) {
        ReminderGroup *grp = task.reminderGroup;//[Utils getTaskGroupNameForId:task.reminderGroupId];
        if ([grp.objectId isEqualToString:taskSet.objectId]) {
            [itemsToDelete addObject:task];
        }
    }*/
    [PFObject deleteAllInBackground:itemsToDelete block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSMutableArray *mutableTaskSets = [[UserData instance].taskSets mutableCopy];
            [mutableTaskSets removeObject:taskSet];
            [UserData instance].taskSets = [mutableTaskSets copy];
            
            NSMutableArray *mutableFilterGroups = [[UserData instance].filterGroups mutableCopy];
            if ([[UserData instance].filterGroups containsObject:taskSet.objectId]) {
                [mutableFilterGroups removeObject:taskSet.objectId];
                [UserData instance].filterGroups = [mutableFilterGroups copy];
                [UserData instance].isFilteringGroups = (mutableFilterGroups.count > 0);
            }
        }
        handler(succeeded,error);
    }];
}


//+ (void)configureReminderDuedate:(int)index {
// NSDateFormatter *dateFormatter;
//    NSString *DATETIME_FORMATS = @"MMM dd, yyyy";
//  dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setDateFormat:DATETIME_FORMATS];
//    index -= 100;
//    NSString *date = [self.configAlert textFieldAtIndex:0].text;
//    NSArray *ques = self.configDict[@"questions"];
//    for (int i=0; i<[UserData instance].tasks.count; i++) {
//        Reminder *task = [[UserData instance].tasks objectAtIndex:i];
//        if ([task.key isEqualToString:[ques objectAtIndex:index][@"reminder"]]) {
//            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//            NSLog(@"Set Trigger : %@",[dateFormatter dateFromString:date]);
//            if (task.dateTimeTriggers && task.dateTimeTriggers.count) {
//                ((DateTimeTrigger *)[task.dateTimeTriggers objectAtIndex:0]).date = [dateFormatter dateFromString:date];
//            }
//            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//            
//        }
//    }
//    [self.configAlert textFieldAtIndex:0].text = @"";
//}
//
//+ (void)showConfigurationWindow:(int)tag {
//    Reminder *task = [UserData instance].task;
//    ReminderGroup *group = [Utils getTaskGroupNameForId:task.reminderGroupId];
//    if (!self.configDict) {
//        NSString *configData = group.configJSON;
//        NSData *jsonData = [configData dataUsingEncoding:NSUTF8StringEncoding];
//        if (jsonData) {
//            self.configDict = [NSJSONSerialization
//                               JSONObjectWithData:jsonData
//                               options:kNilOptions
//                               error:nil];
//        }
//        NSLog(@"Configuration : %@",self.configDict);
//    }
//    int index = tag-100;
//    NSArray *ques = self.configDict[@"questions"];
//    if (index < [ques count]){
//        if (!self.configAlert) {
//            self.configAlert = [[UIAlertView alloc] initWithTitle:@"Provide your Due Date" message:[NSString stringWithFormat:@"The %@ will use this to determine the specific dates for your checklist items",group.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
//            [self.configAlert setTitle:[ques objectAtIndex:index][@"text"]];
//        } else {
//            [self.configAlert setTitle:[ques objectAtIndex:index][@"text"]];
//        }
//        self.configAlert.tag = tag;
//        NSLog(@"Config Alert : %ld",(long)self.configAlert.tag);
//        self.configAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
//        
//        self.configPicker = [[UIDatePicker alloc] init];
//        [self.configPicker setDatePickerMode:UIDatePickerModeDateAndTime];
//        [self.configPicker addTarget:self action:@selector(updateConfigField:) forControlEvents:UIControlEventValueChanged];
//        [[self.configAlert textFieldAtIndex:0] setInputView:self.configPicker];
//        
//        [self.configAlert show];
//    }else {
//        group.configJSON = nil;
//        NSMutableArray *configuredTasks = [[NSMutableArray alloc] initWithObjects:group, nil];
//        for (int i=0; i<[UserData instance].tasks.count; i++) {
//            Reminder *task = [[UserData instance].tasks objectAtIndex:i];
//            if ([task.reminderGroupId isEqualToString:group.objectId]) {
//                [configuredTasks addObject:task];
//            }
//        }
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [PFObject saveAllInBackground:configuredTasks block:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            }else {
//                [Utils showSimpleAlertViewWithTitle:@"Error" content:@"An error occured while saving the data" andDelegate:nil];
//            }
//        }];
//    }
//}
//
//+ (void)updateConfigField:(UIDatePicker *)picker {
//    if (self.configAlert) {
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//        [self.configAlert textFieldAtIndex:0].text = [dateFormatter stringFromDate:picker.date];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//    }
//}

@end
