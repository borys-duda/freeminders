//
//  BackgroundFetchManager.m
//  Freeminders
//
//  Created by Spencer Morris on 5/19/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "BackgroundFetchManager.h"
#import <Parse/Parse.h>
#import "Reminder.h"
#import "UserData.h"
#import "Utils.h"
#import "LocalNotificationManager.h"
#import "DataManager.h"

@implementation BackgroundFetchManager

static BackgroundFetchManager *gInstance = NULL;

+ (BackgroundFetchManager *)sharedInstance
{
    @synchronized(self)
    {
        if (gInstance == NULL) {
            gInstance = [[self alloc] init];
        }
    }
    
    return(gInstance);
}

- (void)performLoadTasks
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_DATE_OF_TRIGGERS_LAST_SET];
    if ( date && abs([date timeIntervalSinceNow]) < (SECONDS_PER_HOUR)) {
        [LocalNotificationManager setNotificationsForLocationTasks];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:USER_DEFAULTS_DATE_OF_TRIGGERS_LAST_SET];
        [[DataManager sharedInstance] loadDetailedTasksWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"TASKS LOADED");
            
            if ([objects.firstObject isKindOfClass:[Reminder class]] || objects.count == 0)
                [UserData instance].tasks = objects;
            
            for (Reminder *task in [UserData instance].tasks) {
                if (task.nextNotificationDate && ! [Utils isDateInFuture:task.nextNotificationDate]) {
                    task.lastNotificationDate = task.nextNotificationDate;
                    task.nextNotificationDate = nil;
                    [task saveInBackground];
                }
            }
            
            [LocalNotificationManager setNotificationsForAllTasks];
        }];
    }
}

@end
