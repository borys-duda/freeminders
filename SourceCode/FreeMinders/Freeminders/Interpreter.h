//
//  Interpreter.h
//  Freeminders
//
//  Created by Saisyam Dampuri on 1/8/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "Utils.h"
#import "TimeSpan.h"

#import "InterpreterAdapter.h"
#import "InterpreterAdapterArgs.h"

typedef void(^InterpreterComplete)(BOOL cancelled);

// The good stuff
@interface Interpreter : NSObject

@property (readonly)NSMutableDictionary *variables;
@property (nonatomic, retain)InterpreterAdapter *adapter;
@property (nonatomic, copy)InterpreterComplete complete;

@property (nonatomic, retain)TimeSpan *my_timeAlert;
@property (nonatomic, retain)TimeSpan *my_timeMorning;
@property (nonatomic, retain)TimeSpan *my_timeNight;

+ (Interpreter *)instance;
- (void)resetUserSettings;
- (void)executeScript:(NSString *)script forReminders:(NSArray *)reminders;

@end

@interface NSString (Trim)

-(NSString *) trim;
-(BOOL) hasPrefix:(NSString *)prefix ignoreCase:(BOOL)ignoreCase;

@end

@implementation NSString (Trim)

-(NSString *) trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(BOOL) hasPrefix:(NSString *)prefix ignoreCase:(BOOL)ignoreCase {
    if (!ignoreCase)
        return [self hasPrefix: prefix];
    NSRange prefixRange = [self rangeOfString: prefix options: NSAnchoredSearch | NSCaseInsensitiveSearch];
    return prefixRange.location == 0 && prefixRange.length > 0;
}

@end

// ***************************************************
// * Reminder Extension
// ***************************************************
@interface Reminder (Script)
- (NSString *)propertyNameFromScript:(NSString *)propertyName;
@end

@implementation Reminder (Script)
- (NSString *)propertyNameFromScript:(NSString *)propertyName {
    NSString *p = [propertyName lowercaseString];
    if ([p isEqualToString:@"notes"]) { return @"note"; }
    return propertyName;
}
@end

// ***************************************************
// * DateTimeTrigger Extension
// ***************************************************
// None yet

// ***************************************************
// * LocationTrigger Extension
// ***************************************************
// None yet

// ***************************************************
// * WeatherTrigger Extension
// ***************************************************
// None yet