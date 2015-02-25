//
//  Utils.h
//  Stadium Guide
//
//  Created by Spencer Morris on 11/6/13.
//  Copyright (c) 2013 Scalpr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Const.h"
#import "Location.h"
#import "ReminderGroup.h"
#import "LocationTrigger.h"
#import "LoginVC.h"

typedef void (^DeleteGroupHandler)(BOOL success, NSError *error);

@interface Utils : NSObject

+ (void)registerAllParseClasses;

+ (NSString *)milesStringBetweenLocation:(CLLocation *)loc1 andLocation:(Location *)loc2;

+ (NSNumber *)milesBetweenLocation:(CLLocation *)loc1 andLocation:(Location *)loc2;

+ (ReminderGroup *)getTaskGroupNameForId:(NSString *)groupId;

+ (NSString *)imageFilenameForTrigger:(TriggerType)triggerType;

+ (NSString *)adjectiveFromPluralNoun:(NSString *)noun;

+ (NSString *)suffixOfDateNumber:(int)date;

+ (NSString *)dateToText:(NSDate *)date format:(NSString *)format;

#pragma mark- data methods

+ (BOOL)stringIsInteger:(NSString *)string;

+ (NSNumber *)stringToNumber:(NSString *)string;

+ (NSString *)getHtmlStringFromString:(NSString *)string;

#pragma mark- NSDate methods

+ (BOOL)isDate:(NSDate *)date1 beforeDate:(NSDate *)date2;

+ (BOOL)isDateInFuture:(NSDate *)date;

+ (NSDate *)earlierOfDate:(NSDate *)date1 andDate:(NSDate *)date2;

+ (NSDate *)laterOfDate:(NSDate *)date1 andDate:(NSDate *)date2;

+ (int)dayOfTheWeek:(NSDate *)date;

+ (int)valueFromDate:(NSDate *)date returnType:(int)type;

+ (NSDate *)setHoursForDate:(NSDate *)date hours:(int)hour minutes:(int)minute;

#pragma mark- Trigger methods

+ (BOOL)isInLocationTriggerBounds:(LocationTrigger *)locationTrigger;

#pragma mark- Login/Signup

+ (void)setParseEmailForFacebookLogin;

#pragma mark- Networking

+ (BOOL)isInternetAvailable;

+ (void)loadUserInfoForLogin;

+ (void)loadDefaultTasks:(LoginVC *)target selector:(SEL)sel;

+ (int)performLoadTasks;

#pragma mark- Alert View

+ (void)showSimpleAlertViewWithTitle:(NSString*)title content:(NSString*)content andDelegate:(id)delegate;

#pragma mark- Location methods

+ (void)updateUserLocation;

#pragma mark- Store methods

+ (void)addTasksFromStoreGroup:(UIView *)view;

+ (BOOL)didGroupExist:(NSString *)storeId;

#pragma mark- Other methods

+ (BOOL)isModal:(UIViewController *)ctrl;

#pragma mark- Dependency methods

+ (void)scheduleDependentReminders:(Reminder *)task;

+ (BOOL)checkForOtherParentStatus:(NSArray *)parents;

+ (NSString *)getParentReminderNames:(Reminder *)task;

#pragma mark- Destructive methods
+(void)performDeleteReminderGroupandReminders:(ReminderGroup *)taskSet completionHandler:(DeleteGroupHandler)handler;


//+ (void)showConfigurationWindow:(int)tag;
//
//+ (void)configureReminderDuedate:(int)index;
//
//+ (void)updateConfigField:(UIDatePicker *)picker;

@end

