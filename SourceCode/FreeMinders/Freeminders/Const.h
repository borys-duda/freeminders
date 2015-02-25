//
//  Const.h
//  Stadium Guide
//
//  Created by Spencer Morris on 11/6/13.
//  Copyright (c) 2013 Scalpr. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IOS_VERSION_NEWER_OR_EQUAL_TO(iOSV) ([[[UIDevice currentDevice] systemVersion] compare:(iOSV) options:NSNumericSearch] != NSOrderedAscending)

#define LocalNotificationRecieved @"LocalNotificationRecieved"

#define COLOR_FREEMINDER_BLUE [UIColor colorWithRed:52.0/255.0 green:170.0/255.0 blue:220.0/255.0 alpha:1.0]
#define COLOR_FREEMINDER_ORANGE [UIColor colorWithRed:255.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0]
#define COLOR_FREEMINDER_YELLOW [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:0.0/255.0 alpha:1.0]
#define COLOR_FREEMINDER_RED [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0]
#define COLOR_TAB_BAR_INACTIVE_GREY [UIColor colorWithWhite:235.0/255.0 alpha:0.86]
#define COLOR_LIGHT_GREY [UIColor colorWithWhite:235.0/255.0 alpha:1.0]

#define FONT_HELVETICA_NEUE_MEDIUM @"HelveticaNeue-Medium"
#define FONT_HELVETICA_NEUE_LIGHT @"HelveticaNeue-Light"

#define PI 3.14159
#define SECONDS_PER_MINUTE 60
#define SECONDS_PER_HOUR 3600
#define SECONDS_PER_DAY 86400
#define SECONDS_PER_WEEK 604800
#define SECONDS_PER_MONTH 18144000
#define SECONDS_PER_YEAR 6622560000

#define CONTACT_EMAIL @"feedback@freeminders.com"

#define MINUTES @"Minutes"
#define HOURS @"Hours"
#define DAYS @"Days"
#define WEEKS @"Weeks"
#define MONTHS @"Months"
#define YEARS @"Years"
#define UNITS_OF_TIME [[NSArray alloc] initWithObjects:MINUTES, HOURS, DAYS, WEEKS, MONTHS, nil]

#define USER_DEFAULTS_DATE_OF_TRIGGERS_LAST_SET @"lastDateSetTriggers"
#define USER_DEFAULTS_TAPPED_TASK_ID_ARRAY @"tappedTaskIds"
#define USER_DEFAULTS_SHOULD_RUN_LOCATION_UPDATES @"areLocationUpdatesNeeded"

#define DrizzleOption [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 9], nil]
#define RainOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 11], [NSString stringWithFormat:@"%i", 12], [NSString stringWithFormat:@"%i", 40], nil]
#define LightTStormsOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 37], [NSString stringWithFormat:@"%i", 45], [NSString stringWithFormat:@"%i", 47], nil]
#define TStormsOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 4], [NSString stringWithFormat:@"%i", 38], [NSString stringWithFormat:@"%i", 39], nil]
#define SevereTStormsOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 3], nil]
#define FreezingDrizzleOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 8], nil]
#define FreezingRainOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 10], nil]
#define SleetOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 6], [NSString stringWithFormat:@"%i", 18], nil]
#define SnowFlurriesOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 13], nil]
#define LightSnowOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 5], [NSString stringWithFormat:@"%i", 7], [NSString stringWithFormat:@"%i", 14], [NSString stringWithFormat:@"%i", 42], [NSString stringWithFormat:@"%i", 46], nil]
#define SnowOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 16], nil]
#define HeavySnowOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 41], [NSString stringWithFormat:@"%i", 43], nil]
#define SevereStormOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 3], [NSString stringWithFormat:@"%i", 17], [NSString stringWithFormat:@"%i", 35], nil]
#define TropicalStormOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 1], nil]
#define HurricaneOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 2], nil]
#define TornadoOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 0], nil]
#define HailOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 17], nil]
#define SunnyOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 32], nil]
#define PartiallyCloudyOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 44], [NSString stringWithFormat:@"%i", 29], [NSString stringWithFormat:@"%i", 30], nil]
#define CloudyOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 26], [NSString stringWithFormat:@"%i", 27], [NSString stringWithFormat:@"%i", 28], nil]
#define WindyOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 24], nil]
#define BlusteryOption  [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%i", 23], nil]

#define SEGUE_SUCCESSFUL_LOGIN @"loginSuccessful"

#define NSLog(...)

typedef enum {
    forgotPassword,
    locationServices,
    deleteTaskSet,
    changeEmail,
    changePassword,
    changeEmailAndPassword,
    none,
    resendVerificationMail
} AlertType;

typedef enum { // USED IN BACK-END
    noTrigger = 0,
    weatherTrigger = 1,
    locationTrigger = 2,
    datetimeTrigger = 3
} TriggerType;

typedef enum { // USED IN BACK-END
     noNotification=0,
     localNotification=1,
     email=2,
     emailandlocalnotification=3
} NotificationType;

typedef enum {
    noStatusFilter = 0,
    allStatusFilter = 1,
    activeStatusFilter = 2,
    scheduledStatusFilter = 3,
    inactiveStatusFilter = 4,
    importantStatusFilter = 5,
    completedStatusFilter = 6
} StatusFilterType;

typedef enum {
    noDatetimeFilter = 0,
    allDatetimeFilter = 1,
    todayDatetimeFilter = 2,
    tomorrowDatetimeFilter = 3,
    thisWeekDatetimeFilter = 4,
    nextWeekDatetimeFilter = 5,
    thisMonthDatetimeFilter = 6,
    setDateDatetimeFilter = 7
} DatetimeFilterType;

typedef enum {
    repeatEveryWeek = 0,
    repeatFirstWeek = 1,
    repeatSecondWeek = 2,
    repeatThirdWeek = 3,
    repeatFourthWeek = 4,
    repeatLastWeek = 5,
    repeatOnDate = 6,
} WeeklyRepeatType;

typedef enum {
    disableAlert,
    deleteAlert,
    duplicateAlert
} ConfirmAlert;

typedef enum {
    taskStateActive,
    taskStateScheduled,
    taskStateInactive,
    taskStateOther
} TaskStatus;

typedef enum { // USED IN BACK-END (Store Itemtype )
    typeIndividual = 0,
    typeSubscription = 1,
    typeDonation = 2,
    typeEmailSubscription = 3
} StoreItemType;


@interface Const : NSObject

@end
