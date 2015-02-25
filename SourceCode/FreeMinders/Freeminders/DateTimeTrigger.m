//
//  DatetimeTrigger.m
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "DateTimeTrigger.h"
#import <Parse/PFObject+Subclass.h>

@implementation DateTimeTrigger

@dynamic date, isSundayRepeat, isMondayRepeat, isTuesdayRepeat, isWednesdayRepeat, isThursdayRepeat, isFridayRepeat, isSaturdayRepeat, isRepeating, isRepeatFromLastDate, isRepeatManyTimes, weeklyRepeatType, notifyMeNumber, notifyMeUnit, timeAfterNumber, timeAfterUnit, repeatEveryNumber, repeatEveryUnit;

+ (NSString *)parseClassName
{
    return @"DateTimeTrigger";
}

- (DateTimeTrigger *)copy
{
    DateTimeTrigger *trigger = [[DateTimeTrigger alloc] init];
    
//    trigger.taskId = self.taskId;
    trigger.date = self.date;
    trigger.isSundayRepeat = self.isSundayRepeat;
    trigger.isMondayRepeat = self.isMondayRepeat;
    trigger.isTuesdayRepeat = self.isTuesdayRepeat;
    trigger.isWednesdayRepeat = self.isWednesdayRepeat;
    trigger.isThursdayRepeat = self.isThursdayRepeat;
    trigger.isFridayRepeat = self.isFridayRepeat;
    trigger.isSaturdayRepeat = self.isSaturdayRepeat;
    trigger.isRepeating = self.isRepeating;
    trigger.isRepeatFromLastDate = self.isRepeatFromLastDate;
    trigger.isRepeatManyTimes = self.isRepeatManyTimes;
    trigger.weeklyRepeatType = self.weeklyRepeatType;
    trigger.notifyMeNumber = self.notifyMeNumber;
    trigger.notifyMeUnit = self.notifyMeUnit;
    trigger.timeAfterNumber = self.timeAfterNumber;
    trigger.timeAfterUnit = self.timeAfterUnit;
    trigger.repeatEveryNumber = self.repeatEveryNumber;
    trigger.repeatEveryUnit = self.repeatEveryUnit;
    
    return trigger;
}

@end
