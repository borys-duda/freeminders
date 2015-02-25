//
//  StoreGroup.h
//  Freeminders
//
//  Created by Spencer Morris on 5/20/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>

@interface StoreItem : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *minderIds;
@property (strong, nonatomic) NSNumber *price; // in dollars (as float)
@property (strong, nonatomic) NSNumber *salePrice; // in dollars (as float)
@property (strong, nonatomic) NSNumber *countEmail;
@property (strong, nonatomic) NSNumber *countSMS;
@property (strong, nonatomic) NSNumber *validity; // number of days, StoreItem will be active for
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSDate *referenceDate;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL unlimitedEmail;

@property (strong, nonatomic) NSArray *reminderGroups;
@property (strong, nonatomic) NSArray *storeCategories;

+ (NSString *)parseClassName;

- (NSArray *)minders;
- (int)numberOfSteps;
- (int)numberOfTriggers;
- (BOOL)isPurchased;

@end
