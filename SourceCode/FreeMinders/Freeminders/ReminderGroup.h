//
//  TaskSet.h
//  Freeminders
//
//  Created by Spencer Morris on 4/7/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>
#import "Reminder.h"
#import "StoreItem.h"
#import "UserLocation.h"

@interface ReminderGroup : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *reminders;
@property (strong, nonatomic) PFUser *user;
@property (strong,nonatomic) NSString  *desc;
@property (strong, nonatomic) StoreItem *storeItem;
@property (nonatomic) BOOL isSubscribed; //If a store item is downloaded through active subscription, set to YES
@property (strong, nonatomic) NSString *configJSON;

//@property (strong, nonatomic) NSArray *reminderGroups;


+ (NSString *)parseClassName;
- (ReminderGroup *)copy;
- (ReminderGroup *)copyCancel:(ReminderGroup *)group; //used to cancel the changes made to the object
- (NSArray *)tasksIngroup;
- (int)numberOfSteps;
- (int)numberOfTriggers;
-(NSString *)typeOfTheGroup;
- (void)resetLocations:(UserLocation *)resetLocation isRepeat:(BOOL)rep;
@end
