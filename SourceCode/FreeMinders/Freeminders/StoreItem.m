//
//  StoreGroup.m
//  Freeminders
//
//  Created by Spencer Morris on 5/20/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "StoreItem.h"
#import <Parse/PFObject+Subclass.h>
#import "Reminder.h"
#import "ReminderGroup.h"
#import "UserData.h"
#import "StoreHelper.h"

@interface StoreItem ()

@property (strong, nonatomic) NSMutableArray *tasks;

@end

@implementation StoreItem

@dynamic name, price, minderIds, desc, isEnabled, referenceDate, salePrice, countEmail, countSMS, unlimitedEmail, reminderGroups, storeCategories, validity;
@synthesize tasks;

+ (NSString *)parseClassName
{
    return @"StoreItem";
}

- (NSArray *)minders
{
    if (! tasks) {
        tasks = [[NSMutableArray alloc] init];
        for (Reminder *task in [UserData instance].storeTasks) {
            if ([self.minderIds containsObject:task.objectId]) {
                [tasks addObject:task];
            }
        }
    }
    
    return [tasks copy];
}

- (int)numberOfSteps
{
    int steps = 0;
    
    for (Reminder *task in ((ReminderGroup *)[self.reminderGroups objectAtIndex:0]).reminders) {
        steps += (![task isEqual:[NSNull null]])?task.reminderSteps.count:0;
    }
    
    return steps;
}

- (int)numberOfTriggers
{
    int triggers = 0;
    
    for (Reminder *task in ((ReminderGroup *)[self.reminderGroups objectAtIndex:0]).reminders) {
        if ((![task isEqual:[NSNull null]]) && (task.weatherTriggers || task.dateTimeTriggers || task.locationTriggers))
            triggers += task.weatherTriggers.count + task.dateTimeTriggers.count + task.locationTriggers.count;
    }
    
    return triggers;
}

- (BOOL)isPurchased
{
    return [[StoreHelper sharedInstance] isProductPurchased:self.objectId];;
}

@end
