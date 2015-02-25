//
//  Interpreter.m
//  Freeminders
//
//  Created by Saisyam Dampuri on 1/8/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "Interpreter.h"
#import <objc/runtime.h>


// The good stuff
@implementation Interpreter

@synthesize variables = _variables;

NSMutableDictionary *_variables;

NSArray *_reminders;
NSArray *_lines;
NSInteger _lineNumber;

static Interpreter *IInstance = NULL;

+ (Interpreter *)instance {
    
    @synchronized(self) {
        if (IInstance == NULL) {
            IInstance = [[self alloc] init];
        }        
    }
    
    return IInstance;
}

// TODO: Finish support for \x \u \U
+ (NSArray *)argumentParser:(NSString *)argStr {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSMutableString *sb = [[NSMutableString alloc] init];
    
    BOOL openQuote = NO;
    int pos = 0;
    
    NSString *input = [argStr trim];
    NSUInteger len = [input length];
    
    NSArray *escapes = [[NSArray alloc] initWithObjects:@"'",@"\"",@"\\",@"0",@"a",@"b",@"f",@"n",@"r",@"t",@"v",@"x",@"u",@"U",nil];
    
    while (pos < len) {
        
        NSString *c = [input substringWithRange:NSMakeRange(pos,1)];
        
        if (openQuote) {
            
            if ([c isEqualToString:@"\\"]) {
                pos++;
                if (pos >= len) {
                    
                }
                c = [input substringWithRange:NSMakeRange(pos,1)];
                NSUInteger index = [escapes indexOfObject:c];
                switch (index) {
                    case 0:
                        c = @"'";
                        break;
                    case 1:
                        c = @"\"";
                        break;
                    case 2:
                        c = @"\\";
                        break;
                    case 3:
                        c = @"\0";
                        break;
                    case 4:
                        c = @"\a";
                        break;
                    case 5:
                        c = @"\b";
                        break;
                    case 6:
                        c = @"\f";
                        break;
                    case 7:
                        c = @"\n";
                        break;
                    case 8:
                        c = @"\r";
                        break;
                    case 9:
                        c = @"\t";
                        break;
                    case 10:
                        c = @"\v";
                        break;
                    case 11:
                        c = @"x";
                        break;
                    case 12:
                        c = @"u";
                        break;
                    case 13:
                        c = @"U";
                        break;
                    default:
                        break;
                }
            } else {
                
                if ([c isEqualToString:@"'"]) {
                    
                    openQuote = NO;
                    [list addObject:sb];
                    sb = [[NSMutableString alloc] init];
                    // Skip this quote
                    pos++;
                    
                    // Skip past whitespace
                    while (pos < input.length && [[input substringWithRange:NSMakeRange(pos,1)] isEqualToString:@" "])
                        pos++;
                    
                    // Skip past a comma, if there is one
                    if (pos < input.length && [[input substringWithRange:NSMakeRange(pos,1)] isEqualToString:@","])
                        pos++;
                    
                    continue;
                }
            }
        } else {
            
            // Spaces are not significant outside of quoted strings
            if ([c isEqualToString:@" "])
            {
                pos++;
                continue;
            }
            
            // Looks like the begining of a quoted string
            if ([c isEqualToString:@"'"])
            {
                openQuote = YES;
                
                pos++;
                continue;
            }
            
            // If we have a comma, then we need to close out the previous non-quoted argument
            if ([c isEqualToString:@","])
            {
                [list addObject:sb];
                sb = [[NSMutableString alloc] init];
                
                pos++;
                continue;
            }
        }
        [sb appendString:c];
        pos++;
    }
    
    if (openQuote)
        NSLog(@"Unmatched single quote found at end of argument list.");
    
    //throw new Exception("Unmatched single quote found at end of argument list.");
    
    if (sb.length > 0)
        [list addObject:sb];
    
    return list;
}

+(WeekDay)getDayOfWeek:(NSString *)val {
    NSString *arr = @"UMTWRFS";
    NSRange rng = [arr rangeOfString:val options:NSCaseInsensitiveSearch];
    
    if (rng.length > 0) {
        // That enum is 1 based with Sunday = 1
        return rng.location + 1;
    }
    
    return WeekDayUnknown;
}

-(NSObject *)getVariable:(NSString *)variableName {
    NSString *key = [[variableName trim] uppercaseString];
    return _variables[key];
}

-(void)setVariable:(NSString *)variableName value:(NSObject *)value {
    NSString *key = [[variableName trim] uppercaseString];
    [_variables setValue:value forKey:key];
}

- (BOOL)tryGetArguments: (NSString *)input findS:(NSString *)findS findE:(NSString *)findE args:(NSArray **)args {
    
    *args = nil;
    
    if ([input hasPrefix:findS ignoreCase:true]) {
        
        NSString *text = [input substringWithRange:NSMakeRange(findS.length, [input rangeOfString:findE options:NSBackwardsSearch].location-findS.length)];
        
        *args = [Interpreter argumentParser:text];
        return true;
    }
    
    return false;
    
}

- (BOOL)tryGetToken: (NSString *)key value:(NSObject **)value {
    
    *value = nil;
    
    if ([key compare:@"[date]" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        *value = [[NSDate date] dateOnly];
        return true;
    }
    
    if ([key compare:@"[time]" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        *value = [[NSDate date] timeOnly];
        return true;
    }
    
    if ([key compare:@"[now]" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        *value = [NSDate date];
        return true;
    }
    
    if ([key compare:@"[my:timeAlert]" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        *value = [self my_timeAlert];
        return true;
    }
    
    if ([key compare:@"[my:timeMorning]" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        *value = [self my_timeMorning];
        return true;
    }
    
    if ([key compare:@"[my:timeNight]" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        *value = [self my_timeNight];
        return true;
    }
    
    return false;
}

-(BOOL)parseValue:(NSString *)key value:(NSObject **)value {
    
    *value = nil;
    
    if ([self tryGetToken:key value:value]) {
        return true;
    }
    
    NSObject *obj = [self getVariable:key];
    if (obj) {
        *value = obj;
        return true;
    }
    
    return false;
}

-(NSDate *)parseDate:(NSString *)input {
    
    if (input && input.length > 0) {
        
        NSDate *val;
        
        if ([self parseValue:input value:&val])
            return val;
        
        NSArray *formats = [NSArray arrayWithObjects:
                            @"yyyy/MM/dd hh:mm:ss",
                            @"yyyy/MM/dd hh:mm",
                            @"yyyy/MM/dd",
                            nil];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        for (NSString *format in formats) {
            
            [formatter setDateFormat:format];
            val = [formatter dateFromString:input];
            
            if (val)
                break;
        }
        
        return val;
    }
    
    return nil;
}

-(TimeSpan *)parseTime:(NSString *)input {
    
    // "hh:mm:ss" or "hh:mm"
    // I guess I could do this with a date formatter and an array of format strings
    // but this may be "lighter"? Dunno, seems to work
    
    if (input && input.length > 0) {
        
        NSObject *val = [self getVariable:input];
        
        if (val && [val isKindOfClass:[TimeSpan class]])
            return (TimeSpan *)val;
        
        NSArray *formats = [NSArray arrayWithObjects:
                            @"HH:mm:ss",
                            @"HH:mm",
                            @"hh:mm:ss a",
                            @"hh:mm a",
                            nil];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        for (NSString *format in formats) {
            
            [formatter setDateFormat:format];
            
            NSDate *date = [formatter dateFromString:input];
            
            if (date)
                return [date timeOnly];
        }
    }
    
    return nil;
}

-(TimeSpan *)parseTimeSpan:(NSArray *)args {
    
    if (args && args.count > 0) {
        
        NSInteger a[6] = { 0, 0, 0, 0, 0, 0};
        
        for (NSInteger i = 0; i < args.count; i++) {
            
            NSNumber *v = [self parseInteger:args[i]];
            
            if (v != nil) {
                a[i] = [v integerValue];
            }
        }
        
        return [TimeSpan years:a[0] months:a[1] days:a[2] hours:a[3] hinutes:a[4] seconds:a[5]];
    }
    
    return nil;
}

-(NSNumber *)parseInteger:(NSString *)input {
    
    if (input && input.length > 0) {
        
        NSObject *val = [self getVariable:input];
        
        if (val && [val isKindOfClass:[NSNumber class]])
            return (NSNumber *)val;
        
        NSNumberFormatter *intFormatter = [[NSNumberFormatter alloc] init];
        intFormatter.numberStyle = NSNumberFormatterNoStyle;
        
        NSNumber *num = [intFormatter numberFromString:input];
        return num;
    }
    
    return nil;
}

-(NSString *)parseString:(NSString *)input {
    
    if (input && input.length > 0) {
        
        NSObject *val = [self getVariable:input];
        
        if (val && [val isKindOfClass:[NSString class]])
            return (NSString *)val;
        
        return input;
    }
    
    return nil;
}

// This one is different from the other "handle" methods.  See comments in
// continueScript for more information
- (BOOL)isPrompt: (NSString *)input returnArgs:(NSArray **)returnArgs {
    
    NSArray *args;
    
    if ([self tryGetArguments:input findS:@"Prompt(" findE:@")" args:&args]) {
        
        if (args.count < 3)
            [NSException raise:@"Invalid Argument" format:@"Prompt requires at least 3 arguments"];
        
        *returnArgs = args;
        return true;
    }
    
    return false;
}

- (void)handlePrompt: (NSArray *)args {
    
    NSString *action = args[0];
    NSString *title = args[1];
    NSString *message = args[2];
    
    // TIME
    BOOL isTime = [action compare:@"time" options: NSCaseInsensitiveSearch] == NSOrderedSame;
    BOOL isTimeSpan = !isTime && [action compare:@"timeSpan" options: NSCaseInsensitiveSearch] == NSOrderedSame;
    
    if (isTime || isTimeSpan) {
        
        QueryTimeCallbackArgs *queryArgs = [QueryTimeCallbackArgs title:title message:message];
        queryArgs.isTimeSpan = isTimeSpan;
        
        if (args.count > 3) queryArgs.val = [self parseTime:args[3]];
        if (args.count > 4) queryArgs.min = [self parseTime:args[4]];
        if (args.count > 5) queryArgs.max = [self parseTime:args[5]];
        
        if (self.adapter)
            [self.adapter queryTime:queryArgs];
        
        return;
    }
    
    // DATE
    BOOL isDate = [action compare:@"date" options: NSCaseInsensitiveSearch] == NSOrderedSame;
    BOOL isDateTime = !isDate && [action compare:@"dateTime" options: NSCaseInsensitiveSearch] == NSOrderedSame;
    
    if (isDate || isDateTime) {
        
        QueryDateCallbackArgs *queryArgs = [QueryDateCallbackArgs title:title message:message];
        queryArgs.includeTime = isDateTime;
        
        if (args.count > 3) queryArgs.val = [self parseDate:args[3]];
        if (args.count > 4) queryArgs.min = [self parseDate:args[4]];
        if (args.count > 5) queryArgs.max = [self parseDate:args[5]];
        
        if (self.adapter)
            [self.adapter queryDate:queryArgs];
        
        return;
    }
    
    // INTEGER
    if ([action compare:@"int" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
        
        QueryIntegerCallbackArgs *queryArgs = [QueryIntegerCallbackArgs title:title message:message];
        
        if (args.count > 3) queryArgs.val = [self parseInteger:args[3]];
        if (args.count > 4) queryArgs.min = [self parseInteger:args[4]];
        if (args.count > 5) queryArgs.max = [self parseInteger:args[5]];
        
        if (self.adapter)
            [self.adapter queryInteger:queryArgs];
        
        return;
    }
    
    // STRING
    if ([action compare:@"string" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
        
        QueryStringCallbackArgs *queryArgs = [QueryStringCallbackArgs title:title message:message];
        
        if (args.count > 3) queryArgs.val = [self parseString:args[3]];
        if (args.count > 4) queryArgs.min = [self parseInteger:args[4]];
        if (args.count > 5) queryArgs.max = [self parseInteger:args[5]];
        
        if (self.adapter)
            [self.adapter queryString:queryArgs];
        
        return;
    }
}

- (BOOL)tryHandleVal: (NSString *)input value:(NSObject **)value {
    
    *value = nil;
    NSArray *args;
    
    if ([self tryGetArguments:input findS:@"Val(" findE:@")" args:&args]) {
        return [self parseValue:args[0] value: value];
    }
    
    return false;
}

- (BOOL)tryHandleNew: (NSString *)input value:(NSObject **)value {
    
    *value = nil;
    NSArray *args;
    
    if ([self tryGetArguments:input findS:@"New(" findE:@")" args:&args]) {
        
        if ([self tryGetToken:args[0] value:value])
            return true;
        
        if ([args[0] compare:@"date" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            NSInteger year = 0;
            NSInteger month = 0;
            NSInteger day = 0;
            NSInteger hours = 0;
            NSInteger minutes = 0;
            NSInteger seconds = 0;
            
            for (NSInteger i = 1; i < args.count; i++) {
                
                NSNumber *val = [self parseInteger:args[i]];
                
                if (val) {
                    
                    switch (i) {
                        case 1:
                            year = [val integerValue];
                            break;
                        case 2:
                            month = [val integerValue];
                            break;
                        case 3:
                            day = [val integerValue];
                            break;
                        case 4:
                            hours = [val integerValue];
                            break;
                        case 5:
                            minutes = [val integerValue];
                            break;
                        case 6:
                            seconds = [val integerValue];
                            break;
                    }
                }
            }
            
            *value = [NSDate year:year month:month day:day hour:hours minutes:minutes seconds:seconds];
            return true;
        }
        
        if ([args[0] compare:@"time" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            TimeSpan *ts = [[TimeSpan alloc] init];
            
            for (NSInteger i = 1; i < args.count; i++) {
                
                NSNumber *val = [self parseInteger:args[i]];
                
                if (val) {
                    
                    switch (i) {
                        case 1:
                            ts.hours = [val integerValue];
                            break;
                        case 2:
                            ts.minutes = [val integerValue];
                            break;
                        case 3:
                            ts.seconds = [val integerValue];
                            break;
                    }
                }
            }
            
            *value = ts;
            return true;
        }
        
        if ([args[0] compare:@"timespan" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            TimeSpan *ts = [[TimeSpan alloc] init];
            
            for (NSInteger i = 1; i < args.count; i++) {
                
                NSNumber *val = [self parseInteger:args[i]];
                
                if (val) {
                    
                    switch (i) {
                        case 1:
                            ts.years = [val integerValue];
                            break;
                        case 2:
                            ts.months = [val integerValue];
                            break;
                        case 3:
                            ts.days = [val integerValue];
                            break;
                        case 4:
                            ts.hours = [val integerValue];
                            break;
                        case 5:
                            ts.minutes = [val integerValue];
                            break;
                        case 6:
                            ts.seconds = [val integerValue];
                            break;
                    }
                }
            }
            
            *value = ts;
            return true;
        }
        
        if ([args[0] compare:@"int" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInt:[args[1] intValue]];
            return true;
        }
        
        if ([args[0] compare:@"string" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = args[1];
            return true;
        }
        
        [NSException raise:@"Invalid Argument" format:@"The value %@ is not a valid argument for New", args[0]];
    }
    
    return false;
}

- (BOOL)tryHandleDateAdd: (NSString *)input value:(NSObject **)value {
    *value = nil;
    
    NSArray *args;
    
    if ([self tryGetArguments:input findS:@"DateAdd(" findE:@")" args:&args]) {
        
        if (args.count < 2)
            [NSException raise:@"Invalid Argument" format:@"DateAdd requires at least 2 arguments"];
        
        NSDate *dt = [self parseDate:args[0]];
        
        if (dt == nil)
            [NSException raise:@"Invalid Argument" format:@"Unable to evaulate %@ as a Date/Time", args[0]];
        
        // If there are only 2 arguments, the first being the reference date, then the second is
        // most likely a variable.
        if (args.count == 2) {
            
            NSObject *v;
            
            // Check if we can resolve this to either a token or a variable.  If it is a variable, it is
            // probably a timespan.  We'll check that.  If it is not, then we'll treat it like an integer (or integer variable)
            
            if ([self parseValue:args[1] value:&v]) {
                
                if ([v isKindOfClass:[TimeSpan class]]) {
                    
                    TimeSpan *ts = (TimeSpan *)v;
                    
                    *value = [ts addToDate: dt];
                    return true;
                }
                
            }
            
        }
        
        // Either the second argument wasn't a timespan variable, or we had more than 2 arguments
        TimeSpan *ts = [self parseTimeSpan: [args subarrayWithRange:NSMakeRange(1, args.count - 1)]];
        
        if (ts != nil) {
            *value = [ts addToDate: dt];
            return true;
        }
        
        [NSException raise:@"Invalid Argument" format:@"Unable to parse arguments as a TimeSpan"];
    }
    
    return false;
}

- (BOOL)tryHandleNextDate: (NSString *)input value:(NSObject **)value {
    *value = nil;
    
    NSArray *args;
    
    if ([self tryGetArguments:input findS:@"NextDate(" findE:@")" args:&args]) {
        
        if (args.count < 2)
            [NSException raise:@"Invalid Argument" format:@"NextDate requires at least 2 arguments"];
        
        NSDate *dt = [self parseDate:args[0]];
        
        if (dt == nil)
            [NSException raise:@"Invalid Argument" format:@"Unable to evaulate %@ as a Date/Time", args[0]];
        
        BOOL allowSameDate = false;
        
        if (args.count > 2)
            allowSameDate = [args[2] boolValue];
        
        NSString *action = args[1];
        
        // The second argument is either in the format
        //  1:M where 1 is a number (or L) and M is MTWRFSU
        //  07/15 (month/day)
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9L]+)\\:([MTWRFSU])" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:action options:0 range:NSMakeRange(0, action.length)];
        
        if (match && match.numberOfRanges == 3) {
            
            NSString *s_interval = [action substringWithRange:[match rangeAtIndex:1]];
            NSString *s_dayOfWeek = [action substringWithRange:[match rangeAtIndex:2]];
            
            WeekDay dofW = [Interpreter getDayOfWeek:s_dayOfWeek];
            
            if (dofW == WeekDayUnknown)
                [NSException raise:@"Invalid Argument" format:@"Unable to determine the day of week from %@", s_dayOfWeek];
            
            if ([s_interval compare:@"L" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                // Special case to find the last instance of dayOfWeek
                
                NSDate *dt2 = [dt dateByAddingTimeInterval:0];
                
                while(true) {
                    
                    // Advance it to the last day of the month.  This should handle wrapping over into another year
                    // if it needs to go that far.
                    
                    // Back up to the first of this month, add a month, then subtract a day
                    NSDate *nextMonth = [NSDate year:[dt2 getYear] month:[dt2 getMonth] day:1 hour:0 minutes:0 seconds:0];
                    nextMonth = [nextMonth addMonths:1];
                    
                    dt2 = [nextMonth addDays:-1];
                    
                    // Walk the month backwards till we hit our target day of week
                    while ([dt2 getDayOfWeek] != dofW)
                        dt2 = [dt2 addDays:-1];
                    
                    NSComparisonResult comp = [dt2 compare: dt];
                    
                    if ((comp == NSOrderedDescending) || (allowSameDate && (comp == NSOrderedSame))) {
                        *value = dt2;
                        break;
                    }
                    
                    // Ok, well, that didn't work, let it go thru the loop again,
                    // this time with the next month
                    dt2 = nextMonth;
                }
            }
            else {
                
                NSInteger interval = [s_interval integerValue];
                NSDate *dt2 = [dt dateByAddingTimeInterval:0];
                
                // Get the first day of week after our input date
                // We can probably do this with fancy math and stuff, but then we may have issues with what
                // is the first day of the week? Sunday? Monday? Ugh
                if ([dt2 getDayOfWeek] == dofW && allowSameDate == false)
                    dt2 = [dt2 addDays:1];
                
                while ([dt2 getDayOfWeek] != dofW)
                    dt2 = [dt2 addDays:1];
                
                // Now, fast foward as needed
                if (interval > 1)
                    dt2 = [dt2 addDays:(7 * (interval -1))];
                
                *value = dt2;
            }
        }
        else {
            // The second argument could be MM/dd format
            
            regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)/([0-9]+)" options:NSRegularExpressionCaseInsensitive error:nil];
            match = [regex firstMatchInString:action options:0 range:NSMakeRange(0, action.length)];
            
            if (match && [match numberOfRanges] == 3) {
                
                NSString *s_month = [action substringWithRange:[match rangeAtIndex:1]];
                NSString *s_day = [action substringWithRange:[match rangeAtIndex:2]];
                
                NSInteger month = [s_month integerValue];
                NSInteger day = [s_day integerValue];
                
                NSDate *dt2 = [NSDate year:[dt getYear] month:month day:day hour:0 minutes:0 seconds:0];
                
                // If it is in past, add a year and be done with it
                if ([dt2 compare: dt] == NSOrderedAscending)
                    dt2 = [dt2 addYears:1];
                
                *value = dt2;
            }
            else {
                [NSException raise:@"Invalid Argument" format:@"Unable to parse the second argument %@", action];
            }
        }
        
        return true;
    }
    
    return false;
}

- (BOOL)tryHandleDatePart: (NSString *)input value:(NSObject **)value {
    *value = nil;
    
    NSArray *args;
    
    if ([self tryGetArguments:input findS:@"DatePart(" findE:@")" args:&args]) {
        
        if (args.count < 2)
            [NSException raise:@"Invalid Argument" format:@"DatePart requires at least 2 arguments"];
        
        NSDate *dt = [self parseDate:args[0]];
        
        if (dt == nil)
            [NSException raise:@"Invalid Argument" format:@"Unable to evaulate %@ as a Date/Time", args[0]];
        
        NSString *action = args[1];
        
        // I could probably make this prettier, but meh, it works
        
        if ([action compare:@"year" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInteger:[dt getYear]];
            return true;
        }
        
        if ([action compare:@"month" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInteger:[dt getMonth]];
            return true;
        }
        
        if ([action compare:@"day" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInteger:[dt getDay]];
            return true;
        }
        
        if ([action compare:@"hour" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInteger:[dt getHour]];
            return true;
        }
        
        if ([action compare:@"minute" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInteger:[dt getMinute]];
            return true;
        }
        
        if ([action compare:@"second" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            *value = [NSNumber numberWithInteger:[dt getSecond]];
            return true;
        }
        
        [NSException raise:@"Invalid Argument" format:@"The value %@ is not a valid argument for DatePart", action];
    }
    
    return false;
}

#pragma mark -Compare methods

-(BOOL)isCommandSet:(NSString *)input variable:(NSString **)variableName {
    *variableName = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(SET)+\\s+(\\w)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:input options:0 range:NSMakeRange(0,input.length)];
    
    if (matches.count) {
        *variableName = [(NSArray *)[input componentsSeparatedByString:@" "] lastObject];
    }
    
    return matches.count;
}

- (BOOL)isCommandReminder:(NSString *)input key:(NSString **)key field:(NSString **)field {
    
    *key = nil;
    *field = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"Reminders\\[([a-zA-Z0-9\\.-_]+)\\]\\[([a-zA-Z0-9\\.-_]+)\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:input options:0 range:NSMakeRange(0, input.length)];
    
    if (match && [match numberOfRanges] == 3) {
        
        *key = [input substringWithRange:[match rangeAtIndex:1]];
        *field = [input substringWithRange:[match rangeAtIndex:2]];
        
        return true;
    }
    
    return false;
}

-(NSString *)getPropertyName:(NSObject *)obj find:(NSString *)find {

    // Allow us to decouple the property names used by the script and what we use
    // in code.  If the object implements the propertyNameFromScript method, it allows
    // use to map one thing to another.
    // Example: The script may say "Notes" but our object calls the property "note".
    // We already ignore case, so don't use this for changing case.
    if ([obj respondsToSelector:@selector(propertyNameFromScript:)]) {
        find = [obj performSelector:@selector(propertyNameFromScript:) withObject:find];
    }
    
    NSString *name = nil;
    
    uint count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (unsigned i = 0; i < count; i++) {
        
        objc_property_t property = properties[i];
        
        NSString *t = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([t compare:find options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            name = t;
            break;
        }
        
    }
    
    free(properties);
    return name;
}

-(Reminder *)getReminderForKey:(NSString *)key {
    
    if (_reminders && _reminders.count > 0) {
        for (Reminder *reminder in _reminders) {
            if ([reminder.key compare:key options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return reminder;
            }
        }
    }
    
    return nil;
}

-(PFObject *)getReminderObject:(Reminder *)reminder field:(NSString *)field property:(NSString **)property {
    
    // The only time we have a . in the field should be the special case of
    // accessing the current trigger's properties.  We could probably do this different
    // but, meh, it works
    PFObject *obj;
    NSArray *parts = [field componentsSeparatedByString:@"."];
    
    if ([parts[0] compare:@"trigger" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        
        // Ok, look at the reminder to determine what type it is and look at the correct property
        switch (reminder.triggerType) {
            case datetimeTrigger:
                obj = reminder.dateTimeTriggers.firstObject;
                break;
            case locationTrigger:
                obj = reminder.locationTriggers.firstObject;
                break;
            case weatherTrigger:
                obj = reminder.weatherTriggers.firstObject;
                break;
            case noTrigger:
                // nothing to do here, just here so we avoid the compiler warning
                break;
        }
    }
    else {
        // nothing special, just return the reminder itself
        obj = reminder;
    }
    
    *property = parts.lastObject;
    return obj;
}

-(NSObject *)getReminderValue:(NSString *)key field:(NSString *)field {
    
    // Find the reminder by the key
    Reminder *reminder = [self getReminderForKey:key];
    
    if (reminder) {
        
        NSString *propertyName;
        PFObject *obj = [self getReminderObject:reminder field:field property:&propertyName];
        
        // I couldn't find a way to make this ignore case, so we'll do it the hard way
        propertyName = [self getPropertyName:obj find:propertyName];
        
        return [obj valueForKey:propertyName];
    }
    
    return nil;
}

-(void)setReminderValue:(NSString *)key field:(NSString *)field value:(NSObject *)value {
    
    // Find the reminder by the key
    Reminder *reminder = [self getReminderForKey:key];
    
    if (reminder) {
        
        NSString *propertyName;
        PFObject *obj = [self getReminderObject:reminder field:field property:&propertyName];
        
        [obj setValue:value forKey:propertyName];
    }
}

- (void)reset {
    
    if (_variables)
        [_variables removeAllObjects];
    else
        _variables = [[NSMutableDictionary alloc] init];
    
    _lines = nil;
    _lineNumber = -1;
    
    _reminders = nil;
}

- (void)exitWithValue:(BOOL) cancelled {
    if (self.complete) {
        self.complete(cancelled);
    }
}

#pragma mark -Execution methods

- (void)continueScript {
    
    while (true) {
        
        _lineNumber++;
        
        if (_lineNumber == _lines.count) {
            [self exitWithValue:FALSE];
            break;
        }
        
        // Trim is very important.  We could have nasty spaces or something evil
        NSString *line = [_lines[_lineNumber] trim];
        
        // Ignore blank lines and lines that begin with a #
        // Depending on line endings (windows vs unix) we could have a lot of blank
        // lines in _lines due to how we split it. Windows will have \r\n and
        // the split will treat that as 2, whereas unix typically only uses \n
        if (line.length == 0 || [line hasPrefix:@"#"])
            continue;
        
        // The script is a bunch of left = right commands
        // In .NET I would split with a max of 2.  I didn't see how to do that, so
        // I changed it to work this way.  If we don't, then we could have problems if we had a string
        // value with = signs in it.
        NSRange range = [line rangeOfString:@"="];
        
        NSString *left = [[line substringToIndex:range.location] trim];
        NSString *right = [[line substringFromIndex:(range.location + range.length)] trim];
        
        NSString *variableName;
        
        NSString *key;
        NSString *field;
        NSObject *value;
        
        if ([self isCommandSet:left variable:&variableName]) {
            
            // Prompting is special.  If it is a prompt, we exit the loop.  This is to support
            // non-modal windows.  The continuation of handlePrompt will call [self continueScript]
            // if the input is not cancelled
            NSArray *args;
            
            if ([self isPrompt:right returnArgs:&args]) {
                
                if (self.adapter) {
                    
                    // weak, strong pattern to prevent a cycle. not sure if really matters,
                    // but at least it fixes the compiler warning.
                    __weak Interpreter *weakSelf = self;
                    self.adapter.selectionChanged = ^(NSObject *selection) {
                        __strong Interpreter *strongSelf = weakSelf;
                        [strongSelf.adapter cleanup];
                        if (strongSelf) {
                            [strongSelf setVariable:variableName value:selection];
                            [strongSelf continueScript];
                        }
                    };
                }
                
                [self handlePrompt:args];
                break;
            }
            
            if ([self tryHandleNew:right value:&value]) {
                [self setVariable:variableName value:value];
                continue;
            }
            
            if ([self tryHandleVal:right value:&value]) {
                [self setVariable:variableName value:value];
                continue;
            }
            
            if ([self tryHandleDateAdd:right value:&value]) {
                [self setVariable:variableName value:value];
                continue;
            }
            
            if ([self tryHandleNextDate:right value:&value]) {
                [self setVariable:variableName value:value];
                continue;
            }
            
            if ([self tryHandleDatePart:right value:&value]) {
                [self setVariable:variableName value:value];
                continue;
            }
            
            if ([self isCommandReminder:right key:&key field:&field]) {
                
                NSObject *val = [self getReminderValue:key field:field];
                
                [self setVariable:variableName value:val];
                continue;
            }
            
        }
        
        if ([self isCommandReminder:left key:&key field:&field]) {
            
            // Prompting is special.  If it is a prompt, we exit the loop.  This is to support
            // non-modal windows.  The continuation of handlePrompt will call [self continueScript]
            // if the input is not cancelled
            NSArray *args;
            
            if ([self isPrompt:right returnArgs:&args]) {
                
                if (self.adapter) {
                    
                    // weak, strong pattern to prevent a cycle. not sure if really matters,
                    // but at least it fixes the compiler warning.
                    __weak Interpreter *weakSelf = self;
                    self.adapter.selectionChanged = ^(NSObject *selection) {
                        __strong Interpreter *strongSelf = weakSelf;
                        [strongSelf.adapter cleanup];
                        if (strongSelf) {
                            [strongSelf setReminderValue:key field:field value:value];
                            [strongSelf continueScript];
                        }
                    };
                }
                
                [self handlePrompt:args];
                break;
            }
            
            if ([self tryHandleNew:right value:&value]) {
                [self setReminderValue:key field:field value:value];
                continue;
            }
            
            if ([self tryHandleVal:right value:&value]) {
                [self setReminderValue:key field:field value:value];
                continue;
            }
            
            if ([self tryHandleDateAdd:right value:&value]) {
                [self setReminderValue:key field:field value:value];
                continue;
            }
            
            if ([self tryHandleNextDate:right value:&value]) {
                [self setReminderValue:key field:field value:value];
                continue;
            }
            
            if ([self tryHandleDatePart:right value:&value]) {
                [self setReminderValue:key field:field value:value];
                continue;
            }
            
        }
        
    }
}

- (void)resetUserSettings {
    self.my_timeAlert = nil;
    self.my_timeMorning = nil;
    self.my_timeNight = nil;
}

- (void)executeScript:(NSString *)script forReminders:(NSArray *)reminders {
 
    [self reset];
    
    // Hook this
    if (self.adapter) {
        
        // weak, strong pattern to prevent a cycle. not sure if really matters,
        // but at least it fixes the compiler warning.
        __weak Interpreter *weakSelf = self;
        self.adapter.inputCancelled = ^(void) {
            __strong Interpreter *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf.adapter cleanup];
                [strongSelf exitWithValue:TRUE];
            }
        };
    }
    
    // Grab a reference to the reminders
    _reminders = reminders;
    
    // Parse out our script into lines and reset the line number
    _lines = [script componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    _lineNumber = -1;
    
    // And begin processing
    [self continueScript];
}


@end