//
//  Task.h
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>
#import "WeatherTrigger.h"
#import "DateTimeTrigger.h"
#import "LocationTrigger.h"
#import "Const.h"
@class ReminderGroup;
@interface Reminder : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) PFUser *user;
//@property (nonatomic, strong) NSString *reminderGroupId;
@property (nonatomic, strong) ReminderGroup *reminderGroup;
@property (nonatomic, strong) NSDate *lastNotificationDate;
@property (nonatomic, strong) NSDate *nextNotificationDate;
@property (nonatomic, strong) NSDate *lastCompletionDate;
@property (nonatomic, strong) NSDate *snoozedUntilDate;
@property (nonatomic) BOOL isImportant;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isSubscribed; //If a store item is downloaded through an active subscription, set to YES
@property (nonatomic) TriggerType triggerType;
@property (nonatomic, strong) NSMutableArray *weatherTriggers;
@property (nonatomic, strong) NSMutableArray *dateTimeTriggers;
@property (nonatomic, strong) NSMutableArray *locationTriggers;
@property (nonatomic, strong) NSMutableArray *parentReminders;
@property (nonatomic, strong) NSMutableArray *reminderSteps;
@property (nonatomic) BOOL isStoreTask;
@property (nonatomic, strong) NSString *note;
//@property (nonatomic) NSInteger stepTimer;
@property (nonatomic, strong) NSMutableArray *userContacts;
@property (nonatomic) BOOL isNotificationEnable;
//@property (nonatomic ,strong) NSDate* timerStartDate;
@property (nonatomic) BOOL isDependent;
@property (nonatomic, strong) NSArray *childReminders;
@property (nonatomic, strong) NSString *dependencyId;
@property (nonatomic, strong) NSNumber *timeAfterParent;
@property (nonatomic, strong) NSString *timeAfterUnit;
@property (nonatomic) BOOL notificationSent;

@property (nonatomic, strong) NSString *key; //Used for configuration wizard, when a reminder group is downloaded, its due date is must be provided by user
@property (nonatomic) BOOL isMarkedDone; // Make it YES when reminder is marked done. Used to identify the reminders to process for dependency,  which are marked done 
+ (NSString *)parseClassName;

- (Reminder *)copy;

- (BOOL)isStatusActive;
- (void)setEnable:(BOOL)enable;

- (UIColor *)color;

- (NSString *)daysSinceLastNotification;
- (NSTimeInterval)intervalToNotifyBefore;
- (NSDate *)dateForBeforeNotication;
- (NSDate *)dateToSetNotificationFromLastCompletion;
- (NSArray *)datesToSetNotificationRepeats;

- (BOOL)doesMeetDatetimeFilter:(DatetimeFilterType)datetimeFilterType;

- (void) setAllStepsChecked:(BOOL)checked;
- (void)filterNullObjects;
- (BOOL)isDependentOnParent;
- (NSDate *)dateToSetNotificationFromParentCompletion;
@end
