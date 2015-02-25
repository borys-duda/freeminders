//
//  UserData.h
//  GigScout
//
//  Created by Spencer Morris on 1/26/14.
//  Copyright (c) 2014 Scalpr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Const.h"
#import "Reminder.h"
#import "StoreItem.h"
#import "UserPurchase.h"
#import "UserInfo.h"
#import "UserSetting.h"
#import "UserContact.h"
#import "ReminderGroup.h"
#import "ReminderStep.h"

@interface UserData : NSObject

+ (UserData *)instance;

+ (void)clearInstance;

// LOCATION
- (CLLocation *)location;
- (void)setLocation:(CLLocation *)newLocation;

// TASKS
- (NSArray *)tasks;
- (void)setTasks:(NSArray *)newTasks;

// TASK
- (Reminder *)task;
- (void)setTask:(Reminder *)newTask;

//step
- (ReminderStep *)step;
- (void)setStep:(ReminderStep *)newStep;

// Group Names
- (ReminderGroup *)reminderGroup;
- (void)setReminderGroup:(ReminderGroup *)newGroup;
// settings
-(UserSetting*)userSettings;
-(void)setUserSettings:(UserSetting *)newUserSettings;

// TASK SETS
- (NSArray *)taskSets;
- (void)setTaskSets:(NSArray *)newTaskSets;

//userContacts
- (NSMutableArray *)userContacts;
- (void)setUserContacts:(NSArray *)newUserContacts;

//User Locations

-(NSMutableArray *)userLocations;
-(void)setUserLocations:(NSArray *)newUserLocations;

// STORE GROUPS BY LETTER
- (NSDictionary *)storeGroupsByLetter;
- (void)setStoreGroupsByLetter:(NSArray *)newStoreGroupsByLetter;
- (NSArray *)storeGroupsArray;

// STORE GROUP
- (StoreItem *)storeGroup;
- (void)setStoreGroup:(StoreItem *)newStoreGroup;

// STORE GROUP PURCHASES
- (NSArray *)userPurchases;
- (void)setUserPurchases:(NSArray *)newStoreGroupPurchases;

// USER SUBSCRIPTION
- (UserPurchase *)userSubscription;
- (void)setUserSubscription:(UserPurchase *)subscription;

// STORE TASKS
- (NSArray *)storeTasks;
- (void)setStoreTasks:(NSArray *)newStoreTasks;

// ITUNES PRODUCTS
- (NSArray *)itunesProducts;
- (void)setItunesProducts:(NSArray *)products;

// USER INFO
- (UserInfo *)userInfo;
- (void)setUserInfo:(UserInfo *)newUserInfo;

// FILTERS
- (NSArray *)filterGroups;
- (void)setFilterGroups:(NSArray *)newFilterGroups;
- (StatusFilterType)statusFilterType;
- (void)setStatusFilterType:(StatusFilterType)newStatusFilterType;
- (DatetimeFilterType)datetimeFilterType;
- (void)setDatetimeFilterType:(DatetimeFilterType)newDatetimeFilterType;
- (NSDate *)datetimeFilterRangeStartDate;
- (void)setDatetimeFilterRangeStartDate:(NSDate *)newDate;
- (NSDate *)datetimeFilterRangeEndDate;
- (void)setDatetimeFilterRangeEndDate:(NSDate *)newDate;
- (BOOL)isFilteringDatetime;
- (BOOL)isFilteringGroups;
- (BOOL)isFilteringStatus;
- (void)setIsFilteringDatetime:(BOOL)newIsFiltering;
- (void)setIsFilteringGroups:(BOOL)newIsFiltering;
- (void)setIsFilteringStatus:(BOOL)newIsFiltering;
- (BOOL)isHavingActiveSubscription;

@property(nonatomic, assign)BOOL didChangeTrigger;
@property(nonatomic, assign)BOOL purchaseInProgress;

@end
