//
//  TimeSpan.m
//  Freeminders
//
//  Created by Developer on 1/20/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "TimeSpan.h"

@implementation TimeSpan

@synthesize years;
@synthesize months;
@synthesize days;

@synthesize hours;
@synthesize minutes;
@synthesize seconds;

NSInteger const SECONDS_IN_MINUTE = 60;
NSInteger const SECONDS_IN_HOUR = 3600;
NSInteger const SECONDS_IN_Day = 86400;
NSInteger const SECONDS_IN_MONTH = 2592000;
NSInteger const SECONDS_IN_YEAR = 31104000;

+ (instancetype)years:(NSInteger)theYears months:(NSInteger)theMonths days:(NSInteger)theDays hours:(NSInteger)theHours hinutes:(NSInteger)theMinutes seconds:(NSInteger)theSeconds {
    
    TimeSpan *ts = [[TimeSpan alloc] init];
    
    ts.years = theYears;
    ts.months = theMonths;
    ts.days = theDays;
    ts.hours = theHours;
    ts.minutes = theMinutes;
    ts.seconds = theSeconds;
    
    return ts;
    
}

+ (instancetype)hours:(NSInteger)theHours minutes:(NSInteger)theMinutes seconds:(NSInteger)theSeconds {
    return [TimeSpan years:0 months:0 days:0 hours:theHours hinutes:theMinutes seconds:theSeconds];
}

+ (instancetype)timeOnlyFromDate:(NSDate *)theDate {
    if (theDate) {
        return [theDate timeOnly];
    }
    
    return nil;
}

-(NSInteger)towardsZero:(NSInteger)total amount:(NSInteger)amount {
    if (amount < 0)
        total += amount;
    else
        total -= amount;
    return total;
}

-(NSInteger)toSeconds {
    
    NSInteger s = self.seconds;
    
    s += (self.minutes * SECONDS_IN_MINUTE);
    s += (self.hours * SECONDS_IN_HOUR);
    s += (self.days * SECONDS_IN_Day);
    s += (self.months * SECONDS_IN_MONTH);
    s += (self.years * SECONDS_IN_YEAR);
    
    return s;
}

// This is just an private helper method.  It is not 100% accurate, but, as long as it is used
// just to compare against anoher TimeSpan converted to seconds, it should suffice
+(TimeSpan *)fromSeconds:(NSInteger)theSeconds {
    
    TimeSpan *ts = [[TimeSpan alloc] init];
    
    ts.years = (theSeconds % SECONDS_IN_YEAR);
    theSeconds = [ts towardsZero:theSeconds amount:(ts.years * SECONDS_IN_YEAR)];
    
    ts.months = (theSeconds % SECONDS_IN_MONTH);
    theSeconds = [ts towardsZero:theSeconds amount:(ts.months * SECONDS_IN_MONTH)];
    
    ts.days = (theSeconds % SECONDS_IN_Day);
    theSeconds = [ts towardsZero:theSeconds amount:(ts.days * SECONDS_IN_Day)];
    
    ts.hours = (theSeconds % SECONDS_IN_HOUR);
    theSeconds = [ts towardsZero:theSeconds amount:(ts.hours * SECONDS_IN_HOUR)];
    
    ts.minutes = (theSeconds % SECONDS_IN_MINUTE);
    theSeconds = [ts towardsZero:theSeconds amount:(ts.minutes * SECONDS_IN_MINUTE)];
    
    ts.seconds = theSeconds;
    
    return ts;
    
}

-(TimeSpan *)subtractTimeSpan:(TimeSpan *)timeSpan {
    
    NSInteger thisSeconds = [self toSeconds];
    NSInteger thatSeconds = [timeSpan toSeconds];
    
    NSInteger diff = thisSeconds - thatSeconds;
    return [TimeSpan fromSeconds:diff];
}

-(TimeSpan *)subtractDate:(NSDate *)theDate {
    // TODO
    return nil;
}

-(NSInteger)timeIntervalSinceReference {
    return [self toSeconds];
}

-(NSDate *)addToDate:(NSDate *)date {
    
    NSDateComponents *comps = [NSDateComponents alloc];
    
    comps.year = self.years;
    comps.month = self.months;
    comps.day = self.days;
    
    comps.hour = self.hours;
    comps.minute = self.minutes;
    comps.second = self.seconds;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents: comps toDate:date options:0];
}

-(BOOL)isEqual:(id)other {
    if (other == self)
        return true;
    if (!other || ![other isKindOfClass:[self class]])
        return false;
    return [self isEqualTimeSpan:other];
}

-(BOOL)isEqualTimeSpan:(TimeSpan *)timeSpan {
    if (self == timeSpan)
        return true;
    return [self hash] == [timeSpan hash];
}

-(NSUInteger)hash {
    
    // Probably a better way to do this.  The total seconds could be negative, so this
    // *should* handle negative numbers as well.
    NSNumber *num = [[NSNumber alloc] initWithInteger:[self toSeconds]];
    NSUInteger hash = [num hash];
    
    return hash;
}

-(NSString *)description {
    return [NSString stringWithFormat: @"Years: %ld, Months: %ld, Days: %ld, Hours: %ld, Minutes: %ld, Seconds: %ld",
            (long)self.years, (long)self.months, (long)self.days,
            (long)self.hours, (long)self.minutes, (long)self.seconds
    ];
}

@end
