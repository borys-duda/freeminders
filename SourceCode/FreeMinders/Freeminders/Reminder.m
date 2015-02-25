//
//  Task.m
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "Reminder.h"
#import "Utils.h"
#import "UserData.h"
#import "ReminderStep.h"
#import <Parse/PFObject+Subclass.h>

@implementation Reminder

@dynamic name, user, reminderGroup, isImportant, triggerType, weatherTriggers, dateTimeTriggers, locationTriggers, lastNotificationDate, lastCompletionDate, isActive, isStoreTask, isSubscribed, snoozedUntilDate, nextNotificationDate, note, parentReminders, reminderSteps,userContacts,isNotificationEnable,isDependent, childReminders, dependencyId, timeAfterParent, timeAfterUnit, key, notificationSent;
@synthesize isMarkedDone;

+ (NSString *)parseClassName
{
    return @"Reminder";
}

- (Reminder *)copy
{
    Reminder *task = [[Reminder alloc] init];
    
    task.name = self.name;
    task.user = self.user;
    task.reminderGroup = self.reminderGroup;
    task.isImportant = self.isImportant;
    task.triggerType = self.triggerType;
    task.reminderSteps = [self copyReminderSteps];
    task.weatherTriggers = [self copyWeatherTriggers];
    task.dateTimeTriggers = [self copyDateTimeTriggers];
    task.locationTriggers = [self copyLocationTriggers];
    task.lastNotificationDate = self.lastNotificationDate;
    task.lastCompletionDate = self.lastCompletionDate;
    task.isActive = self.isActive;
    task.isStoreTask = self.isStoreTask;
    task.note = self.note;
    task.parentReminders = self.parentReminders;
    task.isNotificationEnable=self.isNotificationEnable;
    /*
     if (self.triggerType == datetimeTrigger) {
     task.dateTimeTriggers = [self.dateTimeTriggers copy];
     } else if (self.triggerType == weatherTrigger) {
     task.weatherTriggers = [self.weatherTriggers copy];
     } else if (self.triggerType == locationTrigger) {
     task.locationTriggers = [self.locationTriggers copy];
     }*/
    task.userContacts = self.userContacts;
    
    task.isDependent = self.isDependent;
    task.childReminders = self.childReminders;
    task.dependencyId = self.dependencyId;
    task.timeAfterParent = self.timeAfterParent;
    task.timeAfterUnit = self.timeAfterUnit;
    
    task.key = self.key;
    return task;
}

#pragma mark- Copy
- (NSMutableArray *)copyReminderSteps {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    for (int i=0; i < self.reminderSteps.count; i++) {
        ReminderStep *step = [self.reminderSteps objectAtIndex:i];
        if (![step isEqual:[NSNull null]])
            [steps addObject:[step copy]];
    }
    return steps;
}
- (NSMutableArray *)copyDateTimeTriggers {
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for (int i=0; i < self.dateTimeTriggers.count; i++) {
        DateTimeTrigger *trigger = [self.dateTimeTriggers objectAtIndex:i];
        if (![trigger isEqual:[NSNull null]])
            [triggers addObject:[trigger copy]];
    }
    return triggers;
}
- (NSMutableArray *)copyLocationTriggers {
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for (int i=0; i < self.locationTriggers.count; i++) {
        LocationTrigger *trigger = [self.locationTriggers objectAtIndex:i];
        if (![trigger isEqual:[NSNull null]])
            [triggers addObject:[trigger copy]];
    }
    return triggers;
}
- (NSMutableArray *)copyWeatherTriggers {
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for (int i=0; i < self.weatherTriggers.count; i++) {
        WeatherTrigger *trigger = [self.weatherTriggers objectAtIndex:i];
        if (![trigger isEqual:[NSNull null]])
            [triggers addObject:[trigger copy]];
    }
    return triggers;
}

#pragma mark- Status
- (BOOL)isStatusActive{
    return ((self.isActive || (self.isDependentOnParent && [Utils checkForOtherParentStatus:self.parentReminders]))
            && (self.lastNotificationDate || self.triggerType == noTrigger)
            && (! self.snoozedUntilDate || ! [Utils isDateInFuture:self.snoozedUntilDate]));
}

- (void)setEnable:(BOOL)enable
{
    self.isActive = enable;//! self.isActive;
    self.lastNotificationDate = (self.isActive && self.triggerType == noTrigger)?[NSDate date]:nil;
}

#pragma mark- Utils
//Returns same date as same input day but time set to 00:00:00
-(NSDate *)getNormalizedDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    date = [gregorian dateFromComponents:dateComponents];
    return date;
}

- (UIColor *)color
{
    float daysAgo = - [self.lastNotificationDate timeIntervalSinceNow] / (float) SECONDS_PER_DAY;
    NSString *timeSince = [self daysSinceLastNotification];
    BOOL isToday = ([timeSince isEqualToString:@"Now"] || [timeSince rangeOfString:@"Minutes ago"].location != NSNotFound || [timeSince rangeOfString:@"Hours ago"].location != NSNotFound || [timeSince rangeOfString:@"Hour ago"].location != NSNotFound);
    if ((! self.isActive && (! self.lastNotificationDate || [Utils isDateInFuture:self.snoozedUntilDate])) || timeSince.length == 0) {
        return [UIColor lightGrayColor];
    }else if (isToday || (isToday && self.isActive && self.triggerType == noTrigger)) {
        return COLOR_FREEMINDER_BLUE;
    } else {
        NSDate *notifiedDate = [self getNormalizedDate:self.lastNotificationDate];
        NSDateComponents *components= [[NSDateComponents alloc] init];
        [components setDay:1];
        notifiedDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:notifiedDate options:0];
        daysAgo = - [notifiedDate timeIntervalSinceNow] / (float) SECONDS_PER_DAY;
        daysAgo += 1;
        if (daysAgo < 4.0) {
            return COLOR_FREEMINDER_YELLOW;
        } else if( daysAgo < 7.0) {
            return COLOR_FREEMINDER_ORANGE;
        } else {
            return COLOR_FREEMINDER_RED;
        }
    }
    return COLOR_FREEMINDER_RED;
}

- (NSString *)daysSinceLastNotification
{
    if (self.lastNotificationDate) {
        NSDate *notifiedDate = [self getNormalizedDate:self.lastNotificationDate];
        NSDateComponents *components= [[NSDateComponents alloc] init];
        [components setDay:1];
        notifiedDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:notifiedDate options:0];
        
        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.lastNotificationDate];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        if([today day] == [otherDay day] &&
           [today month] == [otherDay month] &&
           [today year] == [otherDay year] &&
           [today era] == [otherDay era]) {
            float timeAgo = - [self.lastNotificationDate timeIntervalSinceNow] / (float) SECONDS_PER_MINUTE;
            if (timeAgo < 5) {
                return @"Now";
            }else if (timeAgo < 60) {
                return [NSString stringWithFormat:@"%i %@ ago",(int) floorf(timeAgo), (int) floorf(timeAgo)==1?@"Minute":@"Minutes"];
            }else{
                return [NSString stringWithFormat:@"%i %@ ago", (int) (floorf(timeAgo/(float) SECONDS_PER_MINUTE)),(int) (floorf(timeAgo/(float) SECONDS_PER_MINUTE))==1?@"Hour":@"Hours"];
            }
            return @"Today";
        } else {
            //            float daysAgo = - [self.lastNotificationDate timeIntervalSinceNow] / (float) SECONDS_PER_DAY;
            float daysAgo = - [notifiedDate timeIntervalSinceNow] / (float) SECONDS_PER_DAY;
            if ( daysAgo < 1.0 && daysAgo > 0){ //&& [today day] == [otherDay day] + 1) {
                return @"Yesterday";
            } else {
                daysAgo += 1;
                return [NSString stringWithFormat:@"%i %@ ago", (int) floorf(daysAgo), (int) floorf(daysAgo)==1?@"day":@"days"];
            }
        }
    }
    
    return @"";
}

- (NSTimeInterval)intervalToNotifyBefore
{
    NSTimeInterval intervalBeforeNotif = 0.0;
    DateTimeTrigger *trigger = (DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0];
    if (trigger.notifyMeUnit && [trigger.notifyMeUnit.lowercaseString isEqualToString:@"minutes"]) {
        intervalBeforeNotif = trigger.notifyMeNumber.intValue * SECONDS_PER_MINUTE;
    } else if (trigger.notifyMeUnit && [trigger.notifyMeUnit.lowercaseString isEqualToString:@"hours"]) {
        intervalBeforeNotif = trigger.notifyMeNumber.intValue * SECONDS_PER_HOUR;
    } else if (trigger.notifyMeUnit && [trigger.notifyMeUnit.lowercaseString isEqualToString:@"days"]) {
        intervalBeforeNotif = trigger.notifyMeNumber.intValue * SECONDS_PER_DAY;
    } else if (trigger.notifyMeUnit && [trigger.notifyMeUnit.lowercaseString isEqualToString:@"weeks"]) {
        intervalBeforeNotif = trigger.notifyMeNumber.intValue * SECONDS_PER_WEEK;
    } else if (trigger.notifyMeUnit && [trigger.notifyMeUnit.lowercaseString isEqualToString:@"months"]) {
        intervalBeforeNotif = trigger.notifyMeNumber.intValue * SECONDS_PER_MONTH;
    }
    return intervalBeforeNotif;
}

- (NSDate *)dateForBeforeNotication
{
    NSTimeInterval intervalBeforeNotif = [self intervalToNotifyBefore];
    DateTimeTrigger *trigger = (DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0];
    return [trigger.date dateByAddingTimeInterval:(-intervalBeforeNotif)];
}

- (NSDate *)dateToSetNotificationFromLastCompletion
{
    NSTimeInterval intervalAfterDate = 0.0;
    DateTimeTrigger *trigger = (DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0];
    if (trigger.timeAfterUnit && [trigger.timeAfterUnit.lowercaseString isEqualToString:@"minutes"]) {
        intervalAfterDate = trigger.timeAfterNumber.intValue * SECONDS_PER_MINUTE;
    } else if (trigger.timeAfterUnit && [trigger.timeAfterUnit.lowercaseString isEqualToString:@"hours"]) {
        intervalAfterDate = trigger.timeAfterNumber.intValue * SECONDS_PER_HOUR;
    } else if (trigger.timeAfterUnit && [trigger.timeAfterUnit.lowercaseString isEqualToString:@"days"]) {
        intervalAfterDate = trigger.timeAfterNumber.intValue * SECONDS_PER_DAY;
    } else if (trigger.timeAfterUnit && [trigger.timeAfterUnit.lowercaseString isEqualToString:@"weeks"]) {
        intervalAfterDate = trigger.timeAfterNumber.intValue * SECONDS_PER_WEEK;
    } else if (trigger.timeAfterUnit && [trigger.timeAfterUnit.lowercaseString isEqualToString:@"months"]) {
        intervalAfterDate = trigger.timeAfterNumber.intValue * SECONDS_PER_MONTH;
    }
    // Calculating date after completion
    NSDate *dateFromCompletion = [self.lastCompletionDate dateByAddingTimeInterval:intervalAfterDate];
    // Subtract the notify me before value from the calculated
    NSTimeInterval intervalBeforeNotif = [self intervalToNotifyBefore];
    dateFromCompletion = [dateFromCompletion dateByAddingTimeInterval:(-intervalBeforeNotif)];
    // Trigger won't update if this is removed. dateFromCompletion holds the date from last completion, if the trigger is updated to a future date it will not consider the trigger as the date calculated from last completion. 
    return [dateFromCompletion laterDate:[trigger.date dateByAddingTimeInterval:(-intervalBeforeNotif)]];
}

- (NSArray *)datesToSetNotificationRepeats
{
    NSTimeInterval interval = [self timeIntervalForManyTimesRepeat];
    if (interval <= 0.0) return nil; // check that repeat every number exists
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSDate *startDate = [self dateForBeforeNotication];
    
    while (startDate && ! [Utils isDateInFuture:startDate]) {
        startDate = [self nextNotificationStartingAtDate:startDate];
    }
    
    for (int i = 0; i < 3; i++) {
        
        if (startDate) {
            NSDate *notificationDate = [startDate copy];
            [dates addObject:notificationDate];
            NSLog(@"Set Date : %@",notificationDate);
        }
        
        startDate = [self nextNotificationStartingAtDate:startDate];
    }
    
    return [dates copy];
}

- (NSTimeInterval)timeIntervalForManyTimesRepeat
{
    DateTimeTrigger *trigger = (DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0];
    if (trigger.repeatEveryUnit && [trigger.repeatEveryUnit.lowercaseString isEqualToString:@"minutes"]) {
        return trigger.repeatEveryNumber.intValue * SECONDS_PER_MINUTE;
    } else if (trigger.repeatEveryUnit && [trigger.repeatEveryUnit.lowercaseString isEqualToString:@"hours"]) {
        return trigger.repeatEveryNumber.intValue * SECONDS_PER_HOUR;
    } else if (trigger.repeatEveryUnit && [trigger.repeatEveryUnit.lowercaseString isEqualToString:@"days"]) {
        return trigger.repeatEveryNumber.intValue * SECONDS_PER_DAY;
    } else if (trigger.repeatEveryUnit && [trigger.repeatEveryUnit.lowercaseString isEqualToString:@"weeks"]) {
        return trigger.repeatEveryNumber.intValue * SECONDS_PER_WEEK;
    } else if (trigger.repeatEveryUnit && [trigger.repeatEveryUnit.lowercaseString isEqualToString:@"months"]) {
        return trigger.repeatEveryNumber.intValue * SECONDS_PER_MONTH;
    } else if (trigger.repeatEveryUnit && [trigger.repeatEveryUnit.lowercaseString isEqualToString:@"years"]) {
        return trigger.repeatEveryNumber.intValue * SECONDS_PER_YEAR;
    }
    
    return 0;
}

- (NSDate *)nextNotificationStartingAtDate:(NSDate *)date
{
    if (! date) return nil; // just in case date comes in nil
    DateTimeTrigger *trigger = (DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0];
    
    if ([trigger.repeatEveryUnit.lowercaseString isEqualToString:@"minutes"]) {
        return [date dateByAddingTimeInterval:[self timeIntervalForManyTimesRepeat]];
    }else if ([trigger.repeatEveryUnit.lowercaseString isEqualToString:@"hours"]) {
        return [date dateByAddingTimeInterval:[self timeIntervalForManyTimesRepeat]];
    }else if ([trigger.repeatEveryUnit.lowercaseString isEqualToString:@"days"]) {
        return [date dateByAddingTimeInterval:[self timeIntervalForManyTimesRepeat]];
    } else if ([trigger.repeatEveryUnit.lowercaseString isEqualToString:@"weeks"]) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [calendar components:NSYearForWeekOfYearCalendarUnit|NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        // weekday = 1 is sunday, weekday = 7 is saturday
        // if date has day in same week later, return that day
        if (trigger.isMondayRepeat && comps.weekday < 2) {
            [comps setWeekday:2];
        } else if (trigger.isTuesdayRepeat && comps.weekday < 3) {
            [comps setWeekday:3];
        } else if (trigger.isWednesdayRepeat && comps.weekday < 4) {
            [comps setWeekday:4];
        } else if (trigger.isThursdayRepeat && comps.weekday < 5) {
            [comps setWeekday:5];
        } else if (trigger.isFridayRepeat && comps.weekday < 6) {
            [comps setWeekday:6];
        } else if (trigger.isSaturdayRepeat && comps.weekday < 7) {
            [comps setWeekday:7];
        } else {
            // else add number of weeks to date, return first day of that week
            [comps setWeek:(comps.week + trigger.repeatEveryNumber.intValue)];
            if (trigger.isSundayRepeat) {
                [comps setWeekday:1];
            } else if (trigger.isMondayRepeat) {
                [comps setWeekday:2];
            } else if (trigger.isTuesdayRepeat) {
                [comps setWeekday:3];
            } else if (trigger.isWednesdayRepeat) {
                [comps setWeekday:4];
            } else if (trigger.isThursdayRepeat) {
                [comps setWeekday:5];
            } else if (trigger.isFridayRepeat) {
                [comps setWeekday:6];
            } else if (trigger.isSaturdayRepeat) {
                [comps setWeekday:7];
            }
        }
        
        return [calendar dateFromComponents:comps];
    } else if ([trigger.repeatEveryUnit.lowercaseString isEqualToString:@"months"]) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [calendar components:NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSWeekOfMonthCalendarUnit|NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:date];
        //        int numWeeks = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setMonth:trigger.repeatEveryNumber.intValue];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *newDate = [date dateByAddingTimeInterval:SECONDS_PER_MONTH];
        NSLog(@"DAY of Month : %d",comps.day);
        switch (trigger.weeklyRepeatType) {
            case repeatEveryWeek:
                newDate = [cal dateByAddingComponents:dateComponents toDate:date options:0];
                return newDate;
                break;
                
            case repeatFirstWeek:
            case repeatSecondWeek:
            case repeatThirdWeek:
            case repeatFourthWeek:
            case repeatLastWeek:
                return [self getDayOfnthWeek:[calendar dateFromComponents:comps] repeatableType:trigger.weeklyRepeatType type:YES];
                break;
                /*            case repeatFirstWeek:
                 return [self getDayOfnthWeek:[calendar dateFromComponents:comps] repeatableType:repeatFirstWeek];
                 //                [self getDayOfnthWeek:comps inWeek:repeatFirstWeek];
                 //                [comps setWeekOfMonth:1];
                 //                [comps setMonth:(comps.month + 1)];
                 //                [comps setDay:[Utils dayOfTheWeek:self.datetimeTrigger.date]];
                 break;
                 
                 *            case repeatSecondWeek:
                 if (comps.weekOfMonth > 1) {
                 [comps setMonth:(comps.month + 1)];
                 }
                 [comps setWeekOfMonth:2];
                 break;
                 
                 case repeatThirdWeek:
                 if (comps.weekOfMonth > 2) {
                 [comps setMonth:(comps.month + 1)];
                 }
                 [comps setWeekOfMonth:3];
                 [comps setDay:[Utils dayOfTheWeek:date]];
                 break;
                 
                 case repeatFourthWeek:
                 if (comps.weekOfMonth > 3) {
                 [comps setMonth:(comps.month + 1)];
                 }
                 [comps setWeekOfMonth:4];
                 [comps setDay:[Utils dayOfTheWeek:date]];
                 break;
                 
                 case repeatLastWeek:
                 if (comps.weekOfMonth > 3) {
                 [comps setMonth:(comps.month + 1)];
                 }
                 [comps setWeekOfMonth:4];
                 [comps setDay:[Utils dayOfTheWeek:date]];
                 break;
                 */
            default:
                [dateComponents setMonth:trigger.repeatEveryNumber.intValue];
                newDate = [cal dateByAddingComponents:dateComponents toDate:date options:0];
                return newDate;
                break;
        }
        
        if (comps.month > 12) {
            [comps setMonth:1];
            [comps setYear:(comps.year + 1)];
        }
        
        return [calendar dateFromComponents:comps];
    } else if ([trigger.repeatEveryUnit.lowercaseString isEqualToString:@"years"]) {
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        int repInterval = trigger.repeatEveryNumber.intValue;
        if (repInterval <= 10){
            [dateComponents setYear:repInterval];
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDate *newDate = [cal dateByAddingComponents:dateComponents toDate:date options:0];
            return newDate;
        }else{
            repInterval -= 10;
            [dateComponents setYear:repInterval];
            int dt = [Utils valueFromDate:trigger.date returnType:NSCalendarUnitDay];
            return [self getDayOfnthWeek:date repeatableType:((dt+6)/7) type:NO];
        }
    }
    
    return nil;
}

- (NSDate*) getDayOfnthWeek:(NSDate *) sdate repeatableType:(int)rept type:(BOOL)isForMonth{
    rept --;
    DateTimeTrigger *trigger = (DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSWeekOfMonthCalendarUnit|NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:sdate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"EEE"];
    NSString *dateManup = [dateFormatter stringFromDate:sdate];
    
    NSString * dayStr = [NSString stringWithFormat:@"%@",dateManup];
    
    int day = 1;
    int month = 0;
    int year = 0;
    
    [dateFormatter setDateFormat:@"MM"];
    dateManup = [dateFormatter stringFromDate:sdate];
    month =  [dateManup integerValue];
    
    [dateFormatter setDateFormat:@"yyyy"];
    dateManup = [dateFormatter stringFromDate:sdate];
    year =  [dateManup integerValue];
    if (isForMonth){
        month += trigger.repeatEveryNumber.intValue;
        // change year
        if (month > 12) {
            year ++;
            month -= 12;
        }
    }else {
        year ++;
    }
    NSDate * nDate;
    for (int i = 1; i <= 7; i++) {
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        nDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d",i,month,year]];
        [dateFormatter setDateFormat:@"EEE"];
        if([[dateFormatter stringFromDate:nDate] isEqualToString:dayStr]){
            day = i;
            break;
        }
    }
    day = day+(rept*7);
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    //reCal:;
    //    NSRange noofDays = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
    //                           inUnit:NSMonthCalendarUnit
    //                          forDate:nDate];
    //
    //    if (day > noofDays.length) {
    //        day = day - noofDays.length;
    //        month ++;
    //        nDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d",day,month,year]];
    //        goto reCal;
    //
    //    }
    
    nDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d",day,month,year]];
    if (!nDate) {
        day -= 7;
        nDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d",day,month,year]];
    }
    
    NSDateComponents *dateComponents = [calendar components:NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSWeekOfMonthCalendarUnit|NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit fromDate:nDate];
    [comps setDay:dateComponents.day];
    [comps setMonth:dateComponents.month];
    [comps setYear:dateComponents.year];
    nDate = [calendar dateFromComponents:comps];
    NSLog(@"%@",nDate);
    return nDate;
}


- (BOOL)doesMeetDatetimeFilter:(DatetimeFilterType)datetimeFilterType
{
    DateTimeTrigger *trigger = (self.triggerType == datetimeTrigger && self.dateTimeTriggers && self.dateTimeTriggers.count)?(DateTimeTrigger *)[self.dateTimeTriggers objectAtIndex:0]:nil;
    
    if (datetimeFilterType == noDatetimeFilter
        || datetimeFilterType == allDatetimeFilter) { // if no datetime filter, allow all
        return YES;
    } else if (self.triggerType != datetimeTrigger
               || (! self.dateTimeTriggers)
               || ! [trigger isDataAvailable]) {
        return NO;
    } else {
        
        NSDateComponents *notificationDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekOfYearCalendarUnit fromDate:trigger.date];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
        NSDateComponents *tomorrow = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekOfYearCalendarUnit fromDate:[[NSDate date] dateByAddingTimeInterval:SECONDS_PER_DAY]];
        NSDate *stDate = [UserData instance].datetimeFilterRangeStartDate;
        NSDate *endDate = [UserData instance].datetimeFilterRangeEndDate;
        switch (datetimeFilterType) {
            case todayDatetimeFilter:
                return notificationDate.year == today.year
                && notificationDate.month == today.month
                && notificationDate.day == today.day;
                break;
            case tomorrowDatetimeFilter:
                return notificationDate.year == tomorrow.year
                && notificationDate.month == tomorrow.month
                && notificationDate.day == tomorrow.day;
                break;
            case thisWeekDatetimeFilter:
                return notificationDate.year == today.year
                && notificationDate.weekOfYear == today.weekOfYear;
                break;
            case nextWeekDatetimeFilter:
                return notificationDate.year == today.year
                && notificationDate.weekOfYear == (today.weekOfYear + 1);
                break;
            case thisMonthDatetimeFilter:
                return notificationDate.year == today.year
                && notificationDate.month == today.month;
                break;
            case setDateDatetimeFilter:
                return (! [UserData instance].datetimeFilterRangeStartDate
                        || [Utils isDate:[UserData instance].datetimeFilterRangeStartDate beforeDate:trigger.date])
                && (! [UserData instance].datetimeFilterRangeEndDate
                    || [Utils isDate:trigger.date beforeDate:[UserData instance].datetimeFilterRangeEndDate]);
                
                break;
                
            default:
                break;
        }
        
    }
    
    return NO;
}

- (void) setAllStepsChecked:(BOOL)checked {
    for (int i=0; i < self.reminderSteps.count; i++) {
        ReminderStep *step = [self.reminderSteps objectAtIndex:i];
        if ([step isEqual:[NSNull null]]){
            [self.reminderSteps removeObjectAtIndex:i];
            continue;
        }
        ((ReminderStep *)[self.reminderSteps objectAtIndex:i]).isComplete = checked;
    }
}

- (void)filterNullObjects { // To remove any null objects (Deleted in steps class, but not removed the pointer from reminder class)
    for (int i=0; i < self.reminderSteps.count; i++) {
        ReminderStep *step = [self.reminderSteps objectAtIndex:i];
        if ([step isEqual:[NSNull null]]){
            [self.reminderSteps removeObjectAtIndex:i];
        }
    }
}

#pragma mark- Dependent Reminder methods
- (BOOL)isDependentOnParent {
    return self.isDependent && self.parentReminders && self.parentReminders.count;
}

- (NSDate *)dateToSetNotificationFromParentCompletion
{
    NSTimeInterval intervalAfterDate = 0.0;
    if (self.timeAfterUnit && [self.timeAfterUnit.lowercaseString isEqualToString:@"minutes"]) {
        intervalAfterDate = self.timeAfterParent.intValue * SECONDS_PER_MINUTE;
    } else if (self.timeAfterUnit && [self.timeAfterUnit.lowercaseString isEqualToString:@"hours"]) {
        intervalAfterDate = self.timeAfterParent.intValue * SECONDS_PER_HOUR;
    } else if (self.timeAfterUnit && [self.timeAfterUnit.lowercaseString isEqualToString:@"days"]) {
        intervalAfterDate = self.timeAfterParent.intValue * SECONDS_PER_DAY;
    } else if (self.timeAfterUnit && [self.timeAfterUnit.lowercaseString isEqualToString:@"weeks"]) {
        intervalAfterDate = self.timeAfterParent.intValue * SECONDS_PER_WEEK;
    } else if (self.timeAfterUnit && [self.timeAfterUnit.lowercaseString isEqualToString:@"months"]) {
        intervalAfterDate = self.timeAfterParent.intValue * SECONDS_PER_MONTH;
    }
    
    return [[NSDate date] dateByAddingTimeInterval:intervalAfterDate];
}

@end
