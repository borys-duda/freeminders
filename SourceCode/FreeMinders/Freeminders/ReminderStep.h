//
//  ReminderStep.h
//  Freeminders
//
//  Created by Saisyam Dampuri on 9/11/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>

@interface ReminderStep : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *order;
@property (assign) BOOL isComplete;

+ (NSString *)parseClassName;
- (ReminderStep *)copy;

@end
