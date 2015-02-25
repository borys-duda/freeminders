//
//  TimeSpan.h
//  Freeminders
//
//  Created by Developer on 1/20/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WeekDay) {
    WeekDayUnknown = 0,
    WeekDaySunday = 1,
    WeekDayMonday,
    WeekDayTuesday,
    WeekDayWednesday,
    WeekDayThursday,
    WeekDayFriday,
    WeekDaySaturday
};

@interface TimeSpan : NSObject

@property NSInteger years;
@property NSInteger months;
@property NSInteger days;

@property NSInteger hours;
@property NSInteger minutes;
@property NSInteger seconds;

+ (instancetype)years:(NSInteger)theYears months:(NSInteger)theMonths days:(NSInteger)theDays hours:(NSInteger)theHours hinutes:(NSInteger)theMinutes seconds:(NSInteger)theSeconds;
+ (instancetype)hours:(NSInteger)theHours minutes:(NSInteger)theMinutes seconds:(NSInteger)theSeconds;

+ (instancetype)timeOnlyFromDate:(NSDate *)theDate;

- (BOOL)isEqualTimeSpan:(TimeSpan *)timeSpan;

- (NSInteger)timeIntervalSinceReference;

- (TimeSpan *)subtractTimeSpan:(TimeSpan *)timeSpan;
- (TimeSpan *)subtractDate:(NSDate *)date;

-(NSDate *)addToDate:(NSDate *)date;

@end

@interface NSDate (Date)

+ (NSDate*)year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minutes:(NSInteger)minutes seconds:(NSInteger)seconds;

- (NSDate*)dateOnly;

- (NSInteger) getYear;
- (NSInteger) getMonth;
- (NSInteger) getDay;

- (NSInteger) getHour;
- (NSInteger) getMinute;
- (NSInteger) getSecond;

- (WeekDay) getDayOfWeek;

- (NSDate *) addYears:(NSInteger)years;
- (NSDate *) addMonths:(NSInteger)months;
- (NSDate *) addDays:(NSInteger)years;

@end

@implementation NSDate (Date)

+ (NSDate*)year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minutes:(NSInteger)minutes seconds:(NSInteger)seconds {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    [comps setHour:hour];
    [comps setMinute:minutes];
    [comps setSecond:seconds];
    
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSDate *)withoutSeconds {
 
    NSDateComponents* comps = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate: self];
    [comps setSecond:0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSDate*)dateOnly {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate: self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (TimeSpan *)timeOnly {
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self];
    return [TimeSpan hours:comps.hour minutes:comps.minute seconds:comps.second];
}

- (NSInteger) getYear {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self];
    return [components year];
//    return [[NSCalendar currentCalendar] component:NSYearCalendarUnit fromDate:self];
}

- (NSInteger) getMonth {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self];
    return [components month];
//    return [[NSCalendar currentCalendar] component:NSMonthCalendarUnit fromDate:self];
}

- (NSInteger) getDay {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
    return [components day];
//    return [[NSCalendar currentCalendar] component:NSDayCalendarUnit fromDate:self];
}

- (NSInteger) getHour {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:self];
    return [components hour];
//    return [[NSCalendar currentCalendar] component:NSHourCalendarUnit fromDate:self];
}

- (NSInteger) getMinute {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:self];
    return [components minute];
//    return [[NSCalendar currentCalendar] component:NSMinuteCalendarUnit fromDate:self];
}

- (NSInteger) getSecond {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:self];
    return [components second];
//    return [[NSCalendar currentCalendar] component:NSSecondCalendarUnit fromDate:self];
}

- (WeekDay) getDayOfWeek {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self];
    return [components weekday];
//    NSInteger v = [[NSCalendar currentCalendar] component:NSWeekdayCalendarUnit fromDate:self];
//    return v;
}

- (NSDate *) addYears:(NSInteger)years {
    
    NSDateComponents *comps = [NSDateComponents alloc];
    comps.year = years;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents: comps toDate:self options:0];
    
}

- (NSDate *) addMonths:(NSInteger)months {
    
    NSDateComponents *comps = [NSDateComponents alloc];
    comps.month = months;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents: comps toDate:self options:0];
}

- (NSDate *) addDays:(NSInteger)days {
    
    NSDateComponents *comps = [NSDateComponents alloc];
    comps.day = days;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents: comps toDate:self options:0];
}

@end