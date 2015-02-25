//
//  DatetimeTrigger.h
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>
#import "Const.h"

@interface DateTimeTrigger : PFObject <PFSubclassing>

//@property (strong, nonatomic) NSString *taskId;

@property (strong, nonatomic) NSDate *date;

@property (nonatomic) BOOL isRepeating;
@property (nonatomic) BOOL isRepeatFromLastDate;
@property (nonatomic) BOOL isRepeatManyTimes;

@property (strong, nonatomic) NSNumber *notifyMeNumber;
@property (strong, nonatomic) NSString *notifyMeUnit;

@property (strong, nonatomic) NSNumber *timeAfterNumber;
@property (strong, nonatomic) NSString *timeAfterUnit;

@property (strong, nonatomic) NSNumber *repeatEveryNumber;
@property (strong, nonatomic) NSString *repeatEveryUnit;

@property (nonatomic) WeeklyRepeatType weeklyRepeatType;

@property (nonatomic) BOOL isSundayRepeat;
@property (nonatomic) BOOL isMondayRepeat;
@property (nonatomic) BOOL isTuesdayRepeat;
@property (nonatomic) BOOL isWednesdayRepeat;
@property (nonatomic) BOOL isThursdayRepeat;
@property (nonatomic) BOOL isFridayRepeat;
@property (nonatomic) BOOL isSaturdayRepeat;

+ (NSString *)parseClassName;

- (DateTimeTrigger *)copy;

@end
