//
//  TaskSet.m
//  Freeminders
//
//  Created by Spencer Morris on 4/7/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "ReminderGroup.h"
#import <Parse/PFObject+Subclass.h>
#import "Reminder.h"
#import "UserData.h"
#import "StoreHelper.h"
#import "Utils.h"
#import "Const.h"


@interface ReminderGroup ()

@property (strong, nonatomic) NSMutableArray *tasks;



@end

@implementation ReminderGroup

@dynamic name, reminders, user, desc, storeItem, isSubscribed, configJSON;
@synthesize tasks;

+ (NSString *)parseClassName
{
    return @"ReminderGroup";
}

- (ReminderGroup *)copy {
    ReminderGroup *group = [[ReminderGroup alloc] init];
    group.name = self.name;
    group.reminders = self.reminders;
    group.user = self.user;
//    group.reminderGroups = self.reminderGroups;
    group.desc = self.desc;
    group.storeItem = self.storeItem;
    group.isSubscribed = self.isSubscribed;
    group.configJSON = self.configJSON;
    return group;
}

- (ReminderGroup *)copyCancel:(ReminderGroup *)group {
    self.name = group.name;
    self.desc = group.desc;
    return group;
}

- (NSComparisonResult)compare:(ReminderGroup *)otherObject
{
    return [self.name.lowercaseString compare:otherObject.name.lowercaseString];
}


- (NSArray *)tasksIngroup
{
    if (! tasks) {
        
        tasks = [[NSMutableArray alloc] init];
        
        for(int i=0; i<[UserData instance].tasks.count; i++)
        {
            if([[UserData instance].reminderGroup.objectId isEqualToString:((Reminder *)[[UserData instance].tasks objectAtIndex:i]).reminderGroup.objectId])
            {
                [tasks addObject:[[UserData instance].tasks objectAtIndex:i]];
            }
        }
    }
//    NSLog(@"%@",tasks);
    return tasks;
}

- (int)numberOfSteps
{
    int steps = 0;
    
    for (Reminder *task in tasks) {
        steps += (![task isEqual:[NSNull null]])?task.reminderSteps.count:0;
        
    }
    NSLog(@"steps %d",steps);
    return steps;
}

- (int)numberOfTriggers
{
    int triggers = 0;
    
    for (Reminder *task in tasks) {
        if ((![task isEqual:[NSNull null]]) && (task.weatherTriggers || task.dateTimeTriggers || task.locationTriggers))
            triggers += task.weatherTriggers.count + task.dateTimeTriggers.count + task.locationTriggers.count;
    }
    NSLog(@"triggers %d",triggers);
    return triggers;
}
-(NSString *)typeOfTheGroup
{
    NSString *type;
    
    if(!self.storeItem)
    {
        type=@"User-Created";
    }else if (self.isSubscribed){
        type = @"Subscription Accessed";
    }else {
        type = @"Lifetime Purchased";
    }
    return type;
}

- (void)resetLocations:(UserLocation *)resetLocation isRepeat:(BOOL)rep{
    NSMutableArray *tasksToReset = [[NSMutableArray alloc] init];
    for(int i=0; i<[UserData instance].tasks.count; i++)
    {
        Reminder *task = (Reminder *)[[UserData instance].tasks objectAtIndex:i];
        if([[UserData instance].reminderGroup.objectId isEqualToString:task.reminderGroup.objectId])
        {
            if ((![task isEqual:[NSNull null]]) && (task.triggerType == locationTrigger)){
                
                ((LocationTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).locationTriggers objectAtIndex:0]).location = resetLocation.location;
                ((LocationTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).locationTriggers objectAtIndex:0]).address = resetLocation.address;
                ((LocationTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).locationTriggers objectAtIndex:0]).radius = resetLocation.radius;
                ((LocationTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).locationTriggers objectAtIndex:0]).isRepeat = rep;
                if (resetLocation.objectId) {
                    ((LocationTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).locationTriggers objectAtIndex:0]).userLocation = resetLocation;
                }
                [tasksToReset addObject:((Reminder *)[[UserData instance].tasks objectAtIndex:i])];
            }
            if ((![task isEqual:[NSNull null]]) && (task.triggerType == weatherTrigger)){
                ((WeatherTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).weatherTriggers objectAtIndex:0]).location = resetLocation.location;
                ((WeatherTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).weatherTriggers objectAtIndex:0]).address = resetLocation.address;
                ((WeatherTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).weatherTriggers objectAtIndex:0]).isRepeat = rep;
                if (resetLocation.objectId) {
                    ((WeatherTrigger *)[((Reminder *)[[UserData instance].tasks objectAtIndex:i]).weatherTriggers objectAtIndex:0]).userLocation = resetLocation;
                }
                [tasksToReset addObject:((Reminder *)[[UserData instance].tasks objectAtIndex:i])];
            }
        }
    }
    if (tasksToReset.count) {
        [PFObject saveAllInBackground:tasksToReset];
    }
}

@end
