//
//  ReminderStep.m
//  Freeminders
//
//  Created by Saisyam Dampuri on 9/11/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "ReminderStep.h"
#import <Parse/PFObject+Subclass.h>

@implementation ReminderStep

@dynamic name, order, isComplete;

+ (NSString *)parseClassName
{
    return @"ReminderStep";
}
- (ReminderStep *)copy {
    ReminderStep *step = [[ReminderStep alloc] init];
    step.name = self.name;
    step.order = self.order;
    step.isComplete = self.isComplete;
    return step;
}
@end
