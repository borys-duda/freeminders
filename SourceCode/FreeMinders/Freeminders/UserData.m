//
//  UserData.m
//  GigScout
//
//  Created by Spencer Morris on 1/26/14.
//  Copyright (c) 2014 Scalpr. All rights reserved.
//

#import "UserData.h"

@implementation UserData

@synthesize didChangeTrigger,purchaseInProgress;

static CLLocation *location;
static NSArray *tasks;
static Reminder *task;
static ReminderStep *step;
static ReminderGroup *reminderGroup;
static NSArray *taskSets;
static NSMutableDictionary *storeGroupsByLetter;
static NSArray *storeTasks;
static NSMutableArray *userLocations;
static NSMutableArray *userContacts;
static UserSetting *userSettings;
static StoreItem *storeGroup;
static UserPurchase *userSubscription;
static NSArray *itunesProducts;
static NSArray *userPurchases;
static UserInfo *userInfo;
static UserData *gInstance = NULL;

+ (UserData *)instance
{
    @synchronized(self)
    {
        if (gInstance == NULL) {
            gInstance           = [[self alloc] init];
            location = [[CLLocation alloc] init];
            tasks = [[NSArray alloc] init];
            task = [[Reminder alloc] init];
            step=[[ReminderStep alloc]init];
            reminderGroup=[[ReminderGroup alloc]init];
            taskSets = [[NSArray alloc] init];
            userLocations=[[NSMutableArray alloc] init];
            storeGroupsByLetter = [[NSMutableDictionary alloc] init];
            storeTasks = [[NSArray alloc] init];
            storeGroup = [[StoreItem alloc] init];
            userSubscription = [[UserPurchase alloc] init];
            itunesProducts = [[NSArray alloc] init];
            userPurchases = [[NSArray alloc] init];
            userInfo = [[UserInfo alloc] init];
            userSettings =[[UserSetting alloc] init];
            userContacts =[[NSMutableArray alloc] init];
        }
    }
    
    return(gInstance);
}

+ (void)clearInstance
{
    gInstance = NULL;
}

// LOCATION
- (CLLocation *)location
{
    return location;
}

- (void)setLocation:(CLLocation *)newLocation
{
    location = newLocation;
}

// TASKS
- (NSArray *)tasks
{
    return tasks;
}

- (void)setTasks:(NSArray *)newTasks
{
    tasks = newTasks;
}

// TASK
- (Reminder *)task
{
    return task;
}

- (void)setTask:(Reminder *)newTask
{
    task = newTask;
}

//ReminderStep
- (ReminderStep *)step
{
    return step;
}

- (void)setStep:(ReminderStep *)newStep
{
    step = newStep;
}

//Group Names
- (ReminderGroup *)reminderGroup
{
    return reminderGroup ;
}
- (void)setReminderGroup:(ReminderGroup *)newGroup
{
    reminderGroup = newGroup;
}

// TASK SETS
- (NSArray *)taskSets
{
    return taskSets;
}

- (void)setTaskSets:(NSArray *)newTaskSets
{
    NSMutableArray *mutableTaskSets = [newTaskSets mutableCopy];
    [mutableTaskSets sortUsingSelector:@selector(compare:)];
    taskSets = [mutableTaskSets copy];
}
//User Locations

- (NSMutableArray *)userLocations
{
    return userLocations;
}

- (void)setUserLocations:(NSArray *)newUserLocations
{
    userLocations = [newUserLocations mutableCopy];
}

//settings
- (UserSetting *)userSettings
{
    return userSettings;
}
-(void)setUserSettings:(UserSetting *)newSettings;
{
    userSettings= newSettings;
}
//UserContacts

- (NSMutableArray *)userContacts
{
    return userContacts;
}
-(void)setUserContacts:(NSArray *)newUserContacts;
{
    userContacts= [newUserContacts mutableCopy];
}

// STORE GROUPS BY LETTER
- (NSDictionary *)storeGroupsByLetter
{
    return [storeGroupsByLetter copy];
}

- (void)setStoreGroupsByLetter:(NSArray *)newStoreGroupsByLetter
{
    storeGroupsByLetter = [[NSMutableDictionary alloc] init];
    
    for (StoreItem *group in newStoreGroupsByLetter) {
        if (group.name.length > 0) {
            NSString *key = [group.name substringToIndex:1];
            
            NSMutableArray *groups = [storeGroupsByLetter valueForKey:key];
            if (groups) {
                [groups addObject:group];
            } else {
                [storeGroupsByLetter setValue:[[NSMutableArray alloc] initWithObjects:group, nil] forKey:key];
            }
        }
    }
}

- (NSArray *)storeGroupsArray
{
    NSMutableArray *mutableGroups = [[NSMutableArray alloc] init];
    
    for (NSArray *array in [storeGroupsByLetter allValues]) {
        for (StoreItem *storeGroup in array) {
            [mutableGroups addObject:storeGroup];
        }
    }
    
    return [mutableGroups copy];
}

// STORE GROUP
- (StoreItem *)storeGroup
{
    return storeGroup;
}

- (void)setStoreGroup:(StoreItem *)newStoreGroup
{
    storeGroup = newStoreGroup;
}

// STORE GROUP PURCHASES
- (NSArray *)userPurchases
{
    return userPurchases;
}

- (void)setUserPurchases:(NSArray *)newStoreGroupPurchases
{
    userPurchases = newStoreGroupPurchases;
}

// USER SUBSCRIPTION
- (UserPurchase *)userSubscription
{
    return userSubscription;
}
- (void)setUserSubscription:(UserPurchase *)subscription
{
    userSubscription = subscription;
}

// STORE TASKS
- (NSArray *)storeTasks
{
    return storeTasks;
}

- (void)setStoreTasks:(NSArray *)newStoreTasks
{
    storeTasks = newStoreTasks;
}

// ITUNES PRODUCTS
- (NSArray *)itunesProducts
{
    return itunesProducts;
}

- (void)setItunesProducts:(NSArray *)products
{
    itunesProducts = products;
}

// USER INFO
- (UserInfo *)userInfo
{
    return userInfo;
}

- (void)setUserInfo:(UserInfo *)newUserInfo
{
    userInfo = newUserInfo;
}

// FILTERS
#define GROUPS_FILTER_KEY @"groupsToFilter"
- (NSArray *)filterGroups
{
    NSArray *filterGroups = [[NSUserDefaults standardUserDefaults] arrayForKey:GROUPS_FILTER_KEY];
    
    if (! filterGroups) {
        filterGroups = [[NSArray alloc] init];
    }
    
    return filterGroups;
}

- (void)setFilterGroups:(NSArray *)newFilterGroups
{
    [[NSUserDefaults standardUserDefaults] setObject:newFilterGroups forKey:GROUPS_FILTER_KEY];
}

#define STATUS_TYPE_KEY @"statusType"
- (StatusFilterType)statusFilterType
{
    NSInteger integer = [[NSUserDefaults standardUserDefaults] integerForKey:STATUS_TYPE_KEY];
    switch (integer) {
        case 0:
            return noStatusFilter;
            break;
        case 1:
            return allStatusFilter;
            break;
        case 2:
            return activeStatusFilter;
            break;
        case 3:
            return scheduledStatusFilter;
            break;
        case 4:
            return inactiveStatusFilter;
            break;
        case 5:
            return importantStatusFilter;
            break;
            
        default:
            return noStatusFilter;
            break;
    }
}

- (void)setStatusFilterType:(StatusFilterType)newStatusFilterType
{
    [[NSUserDefaults standardUserDefaults] setInteger:newStatusFilterType forKey:STATUS_TYPE_KEY];
}

#define DATETIME_TYPE_KEY @"datetimeType"
- (DatetimeFilterType)datetimeFilterType
{
    NSInteger integer = [[NSUserDefaults standardUserDefaults] integerForKey:DATETIME_TYPE_KEY];
    switch (integer) {
        case 0:
            return noDatetimeFilter;
            break;
        case 1:
            return allDatetimeFilter;
            break;
        case 2:
            return todayDatetimeFilter;
            break;
        case 3:
            return tomorrowDatetimeFilter;
            break;
        case 4:
            return thisWeekDatetimeFilter;
            break;
        case 5:
            return nextWeekDatetimeFilter;
            break;
        case 6:
            return thisMonthDatetimeFilter;
            break;
        case 7:
            return setDateDatetimeFilter;
            break;
            
        default:
            return noDatetimeFilter;
            break;
    }
}

- (void)setDatetimeFilterType:(DatetimeFilterType)newDatetimeFilterType
{
    [[NSUserDefaults standardUserDefaults] setInteger:newDatetimeFilterType forKey:DATETIME_TYPE_KEY];
}

#define FILTER_DATE_START_DATE @"datetimeFilterRangeStartDate"
- (NSDate *)datetimeFilterRangeStartDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:FILTER_DATE_START_DATE];
}

- (void)setDatetimeFilterRangeStartDate:(NSDate *)newDate
{
    [[NSUserDefaults standardUserDefaults] setObject:newDate forKey:FILTER_DATE_START_DATE];
}

#define FILTER_DATE_END_DATE @"datetimeFilterRangeEndDate"
- (NSDate *)datetimeFilterRangeEndDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:FILTER_DATE_END_DATE];
}

- (void)setDatetimeFilterRangeEndDate:(NSDate *)newDate
{
    [[NSUserDefaults standardUserDefaults] setObject:newDate forKey:FILTER_DATE_END_DATE];
}

#define DATE_BOOL_KEY @"isFilteringDatetime"
#define GROUP_BOOL_KEY @"isFilteringGroups"
#define STATUS_BOOL_KEY @"isFilteringStatus"
- (BOOL)isFilteringDatetime
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DATE_BOOL_KEY];
}

- (BOOL)isFilteringGroups
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_BOOL_KEY];
}

- (BOOL)isFilteringStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:STATUS_BOOL_KEY];
}

- (void)setIsFilteringDatetime:(BOOL)newIsFiltering
{
    [[NSUserDefaults standardUserDefaults] setBool:newIsFiltering forKey:DATE_BOOL_KEY];
}

- (void)setIsFilteringGroups:(BOOL)newIsFiltering
{
    [[NSUserDefaults standardUserDefaults] setBool:newIsFiltering forKey:GROUP_BOOL_KEY];
}

- (void)setIsFilteringStatus:(BOOL)newIsFiltering
{
    [[NSUserDefaults standardUserDefaults] setBool:newIsFiltering forKey:STATUS_BOOL_KEY];
}

- (BOOL)isHavingActiveSubscription {
    if (!userSubscription || !userSubscription.expireDate || ([[NSDate date] compare:userSubscription.expireDate] == NSOrderedDescending)) {
        NSDate *exDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptionExpireDate"];
        if (exDate && ([[NSDate date] compare:exDate] == NSOrderedDescending)) {
            return false;
        }else if (exDate){
            return true;
        }
        return false;
    }else {
        return true;
    }
}

@end
