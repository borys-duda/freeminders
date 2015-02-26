//
//  LocalNotificationManager.m
//  Freeminders
//
//  Created by Spencer Morris on 5/8/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "LocalNotificationManager.h"
#import <Restkit/RestKit.h>
#import "UserData.h"
#import "Utils.h"
#import "Const.h"
#import "WeatherData.h"
#import "YahooQuery.h"
#import "WeatherForcast.h"
#import "BackgroundFetchManager.h"
#import "DataManager.h"

@implementation LocalNotificationManager

static int weatherTriggersLoaded = 0, weatherTriggersRequested = 0;
NSString *DATE_FORMAT_YAHOO = @"dd MMMM yyyy";
NSDateFormatter *dateFormatterYahoo;
NSString *DATETIME_TRIGGER = @"datetime", *WEATHER_TRIGGER = @"weather", *LOCATION_TRIGGER = @"location";

+ (UILocalNotification *)getNewNotificationObject:(Reminder *)task
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertAction = @"Show me";
    notification.alertBody = task.name;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.hasAction = YES;
    notification.applicationIconBadgeNumber = 1 ;
    notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:task.objectId, @"taskId", DATETIME_TRIGGER, @"type", nil];
    return notification;
}

+ (void)setNotificationsForAllTasks
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:USER_DEFAULTS_DATE_OF_TRIGGERS_LAST_SET];
    
    dateFormatterYahoo = [[NSDateFormatter alloc] init];
    [dateFormatterYahoo setDateFormat:DATE_FORMAT_YAHOO];
    
    // clear all future notifications
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notif in notifications) {
        if ([Utils isDateInFuture:notif.fireDate]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notif];
        }
    }
    
    [self setNotificationsForLocationTasks];
    
    // cancel pending network requests so duplicate weather notifs aren't created
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/v1/public/yql"];
    
    weatherTriggersLoaded = 0, weatherTriggersRequested = 0;
    
    for (Reminder *task in [UserData instance].tasks) {
        if (! task.lastNotificationDate && task.triggerType != noTrigger && task.isActive) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            if (task.isNotificationEnable) {
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.alertAction = @"Show me";
                notification.alertBody = task.name;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.hasAction = YES;
                notification.applicationIconBadgeNumber = 1 ;
            }
            if (task.triggerType == datetimeTrigger && task.dateTimeTriggers.count && [task.dateTimeTriggers objectAtIndex:0] && ![[task.dateTimeTriggers objectAtIndex:0] isEqual:[NSNull null]] && [[task.dateTimeTriggers objectAtIndex:0] isDataAvailable]) {
                // DATETIME TRIGGER
                DateTimeTrigger *trigger = [task.dateTimeTriggers objectAtIndex:0];
                notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:task.objectId, @"taskId", DATETIME_TRIGGER, @"type", nil];
                BOOL doSave = NO;

                if (trigger.date
                   /* && trigger.notifyMeNumber
                    && trigger.notifyMeUnit.length > 0*/) {
                    NSDate *dateToNotify = [task dateForBeforeNotication];
                    if ([Utils isDateInFuture:dateToNotify]) {
                        [notification setFireDate:dateToNotify];
                        [self setNotification:notification];
                        
                        if (! task.nextNotificationDate || ![task.nextNotificationDate isEqualToDate:dateToNotify]) {
                            //|| [Utils isDate:dateToNotify beforeDate:task.nextNotificationDate]) {
                            task.nextNotificationDate = dateToNotify;
                            doSave = YES;
                        }
                    }else if ((!task.isDependentOnParent || [Utils checkForOtherParentStatus:task.parentReminders]) && !task.lastCompletionDate){
                      task.lastNotificationDate = dateToNotify;
                      doSave = YES;
                    }
                }
                
                if (trigger.isRepeating) {
                    if (trigger.isRepeatManyTimes && task.lastCompletionDate) {
                        NSArray *datesToNotify = [task datesToSetNotificationRepeats];
                        for (NSDate *date in datesToNotify) {
                            //                            notification = [self getNewNotificationObject:task];
                            NSLog(@"REpeat Many Times: %@",task.name);
                            [notification setFireDate:date];
                            [self setNotification:notification];
                            
                            if (! task.nextNotificationDate
                                || [Utils isDate:date beforeDate:task.nextNotificationDate]) {
                                task.notificationSent = NO;
//                                if (task.lastCompletionDate) {
                                    task.nextNotificationDate = date;
                                    ((DateTimeTrigger *)[task.dateTimeTriggers objectAtIndex:0]).date = [date dateByAddingTimeInterval:[task intervalToNotifyBefore]];
//                                }
                                doSave = YES;
                            }
                        }
                    } else if (trigger.isRepeatFromLastDate && task.lastCompletionDate) {
                        NSDate *dateToFire = [task dateToSetNotificationFromLastCompletion];
                        [notification setFireDate:dateToFire];
                        [self setNotification:notification];
                        
                        if (! task.nextNotificationDate
                            || [Utils isDate:dateToFire beforeDate:task.nextNotificationDate]) {
                            task.nextNotificationDate = dateToFire;
                            task.notificationSent = NO;
                            ((DateTimeTrigger *)[task.dateTimeTriggers objectAtIndex:0]).date = [dateToFire dateByAddingTimeInterval:[task intervalToNotifyBefore]];
                            doSave = YES;
                        }
                    }
                }
                if (doSave) [[DataManager sharedInstance] saveObject:task];
            } else if (task.triggerType == weatherTrigger && task.weatherTriggers.count
                       && [task.weatherTriggers objectAtIndex:0] && ![[task.weatherTriggers objectAtIndex:0] isEqual:[NSNull null]]
                       && [[task.weatherTriggers objectAtIndex:0] isDataAvailable]) {
                // WEATHER TRIGGER
                notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:task.objectId, @"taskId", WEATHER_TRIGGER, @"type", nil];
                [self performGetForcastForTask:task andNotification:notification];
                
            } else {
                notification = nil;
            }
            
        } else if (task.snoozedUntilDate && [Utils isDateInFuture:task.snoozedUntilDate]) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            if (task.isNotificationEnable) {
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.alertAction = @"Show me";
                notification.alertBody = task.name;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.hasAction = YES;
            }
            task.nextNotificationDate = task.snoozedUntilDate;
            task.notificationSent = NO;
            notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:task.objectId, @"taskId", DATETIME_TRIGGER, @"type", nil];
            
            [notification setFireDate:task.snoozedUntilDate];
            [self setNotification:notification];
        }
    }
    
    NSLog(@"DONE INITIATING TASK NOTIFICATIONS");
}

+ (void)setNotificationsForLocationTasks
{
    for (Reminder *task in [UserData instance].tasks) {
        if (! task.lastNotificationDate
            && task.isActive
            && task.triggerType == locationTrigger
            && task.locationTriggers && task.locationTriggers.count && ![[task.locationTriggers objectAtIndex:0] isEqual:[NSNull null]]
            && [((LocationTrigger *)[task.locationTriggers objectAtIndex:0]) isDataAvailable]) {
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.alertAction = @"Show me";
            notification.alertBody = task.name;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.hasAction = YES;
            notification.applicationIconBadgeNumber =  1;
            
            int duration = SECONDS_PER_DAY;
            UserSetting *settings = [UserData instance].userSettings;
            if (task.lastCompletionDate && settings.locationSleepNumber) {
                if ([settings.locationSleepUnit isEqualToString:MINUTES]) {
                    duration = [settings.locationSleepNumber intValue]*SECONDS_PER_MINUTE;
                } else if ([settings.locationSleepUnit isEqualToString:HOURS]) {
                    duration = [settings.locationSleepNumber intValue]*SECONDS_PER_HOUR;
                }
            }
            // LOCATION TRIGGER
            if (! task.lastNotificationDate && (! task.lastCompletionDate || (- [task.lastCompletionDate timeIntervalSinceNow]) > duration)) {
                notification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:task.objectId, @"taskId", LOCATION_TRIGGER, @"type", nil];
                
                if (task.isNotificationEnable && [Utils isInLocationTriggerBounds:[task.locationTriggers objectAtIndex:0]]) {
                    [notification setFireDate:[NSDate date]];
                    [self setNotification:notification];
                    task.lastNotificationDate = [NSDate date];
                    [[DataManager sharedInstance] saveObject:task];
                }
            }
            
        }
    }
}

+ (void)setNotification:(UILocalNotification *)notification
{
    if (notification != nil)
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)performGetForcastForTask:(Reminder *)task andNotification:(UILocalNotification *)notification
{
    weatherTriggersRequested++;
    NSLog(@"WEATHER TRIGGERS LOADED: %i of %i", weatherTriggersRequested, weatherTriggersLoaded);
    
    NSString *path = [NSString stringWithFormat:@"/v1/public/yql?q=select+*+from+weather.forecast+where+location=\"%@\"&format=json", ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).zipCode];
    path = [Utils getHtmlStringFromString:path];
    
    [[RKObjectManager sharedManager] getObject:nil path:path parameters:nil success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"WEATHER RECEIVED");
        
        if ([[mappingResult firstObject] isKindOfClass:[YahooQuery class]]) {
            YahooQuery *query = [mappingResult firstObject];
            WeatherData *weatherData = query.results.channel.weatherData;
            NSArray *optionsArray;
            
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isDrizzleOption) {
                optionsArray = DrizzleOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isRainOption) {
                optionsArray = RainOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isLightTStormsOption) {
                optionsArray = LightTStormsOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isTStormsOption) {
                optionsArray = TStormsOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSevereTStormsOption) {
                optionsArray = SevereTStormsOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isFreezingDrizzleOption) {
                optionsArray = FreezingDrizzleOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isFreezingRainOption) {
                optionsArray = FreezingRainOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSleetOption) {
                optionsArray = SleetOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSnowFlurriesOption) {
                optionsArray = SnowFlurriesOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isLightSnowOption) {
                optionsArray = LightSnowOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSnowOption) {
                optionsArray = SnowOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isHeavySnowOption) {
                optionsArray = HeavySnowOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSevereStormOption) {
                optionsArray = SevereStormOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isTropicalStormOption) {
                optionsArray = TropicalStormOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isHurricaneOption) {
                optionsArray = HurricaneOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isTornadoOption) {
                optionsArray = TornadoOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isHailOption) {
                optionsArray = HailOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isSunnyOption) {
                optionsArray = SunnyOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isPartiallyCloudyOption) {
                optionsArray = PartiallyCloudyOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isCloudyOption) {
                optionsArray = CloudyOption;
                [self setNotification:notification forTask:task andWeatherData:weatherData forOptionArray:optionsArray];
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isAlertAboveTemp) {
                for (WeatherForcast *forcast in weatherData.forecast) {
                    if (forcast.high.intValue > ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).temperature.intValue) {
                        
                        UILocalNotification *masterNotification = [notification copy];
                        [masterNotification setAlertBody:[NSString stringWithFormat:@"%@ - Temp Above %i", notification.alertBody, ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).temperature.intValue]];
                        
                        NSDate *date = [self dateToSetWeatherTrigger:((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]) withForcastDateString:forcast.date];
                        
                        if ([Utils isDateInFuture:date]) {
                            [masterNotification setFireDate:date];
                            NSLog(@"SETTING NOTIF WITH TITLE: %@", masterNotification.alertBody);
                            [self setNotification:masterNotification];
                            
                            if (! task.nextNotificationDate
                                || [Utils isDate:date beforeDate:task.nextNotificationDate]) {
                                task.nextNotificationDate = date;
                                [[DataManager sharedInstance] saveObject:task];
                            }
                        }
                    }
                }
            }
            if (((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).isAlertBelowTemp) {
                for (WeatherForcast *forcast in weatherData.forecast) {
                    if (forcast.low.intValue < ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).temperature.intValue) {
                        
                        UILocalNotification *masterNotification = [notification copy];
                        [masterNotification setAlertBody:[NSString stringWithFormat:@"%@ - Temp Below %i", notification.alertBody, ((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]).temperature.intValue]];
                        
                        NSDate *date = [self dateToSetWeatherTrigger:((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]) withForcastDateString:forcast.date];
                        
                        if ([Utils isDateInFuture:date]) {
                            [masterNotification setFireDate:date];
                            NSLog(@"SETTING NOTIF WITH TITLE: %@", masterNotification.alertBody);
                            [self setNotification:masterNotification];
                            
                            if (! task.nextNotificationDate
                                || [Utils isDate:date beforeDate:task.nextNotificationDate]) {
                                task.nextNotificationDate = date;
                                [[DataManager sharedInstance] saveObject:task];
                            }
                        }
                    }
                }
            }
        }
        
        weatherTriggersLoaded++;
        NSLog(@"WEATHER TRIGGERS LOADED: %i of %i", weatherTriggersRequested, weatherTriggersLoaded);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog (@"failure: operation: %@ \n\nerror: %@", operation, error);
        weatherTriggersLoaded++;
        NSLog(@"WEATHER TRIGGERS LOADED: %i of %i", weatherTriggersRequested, weatherTriggersLoaded);
    }];
}

+ (void)setNotification:(UILocalNotification *)notification forTask:(Reminder *)task andWeatherData:(WeatherData *)weatherData forOptionArray:(NSArray *)optionsArray {
    for (WeatherForcast *forcast in weatherData.forecast) {
        if ([optionsArray containsObject:forcast.code]) {
            
            UILocalNotification *masterNotification = [notification copy];
            [masterNotification setAlertBody:[NSString stringWithFormat:@"%@ - %@", notification.alertBody, forcast.text]];
            
            NSDate *date = [self dateToSetWeatherTrigger:((WeatherTrigger *)[task.weatherTriggers objectAtIndex:0]) withForcastDateString:forcast.date];

            if ([Utils isDateInFuture:date]) {
                [masterNotification setFireDate:date];
                NSLog(@"SETTING NOTIF WITH TITLE: %@", masterNotification.alertBody);
                [self setNotification:masterNotification];
                
                if (! task.nextNotificationDate
                    || [Utils isDate:date beforeDate:task.nextNotificationDate]) {
                    task.nextNotificationDate = date;
                    [[DataManager sharedInstance] saveObject:task];
                }
            }
        }
    }
}

+ (NSDate *)dateToSetWeatherTrigger:(WeatherTrigger *)weatherTrigger withForcastDateString:(NSString *)forcastDateString
{
    NSDate *date = [dateFormatterYahoo dateFromString:forcastDateString];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    int hour = weatherTrigger.notifyHour.intValue;
    if ([weatherTrigger.notifyAmPm.lowercaseString isEqualToString:@"pm"]
        && weatherTrigger.notifyHour.intValue < 12)
        hour += 12;
    comps.hour  = hour;
    comps.minute=weatherTrigger.notifyMin.intValue;
    date = [calendar dateFromComponents:comps];
    
    NSTimeInterval timeInterval = - (SECONDS_PER_DAY * weatherTrigger.notifyDays.intValue);
    date = [date dateByAddingTimeInterval:timeInterval];
    
    return date;
}

@end
