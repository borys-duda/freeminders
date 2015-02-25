//
//  Settings.h
//  Freeminders
//
//  Created by Vegunta's on 02/09/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserSetting : PFObject <PFSubclassing>


@property (strong, nonatomic) NSString *taskId;

@property (strong, nonatomic) NSDate *alertTime;
@property (strong, nonatomic) NSDate *inTheMorning;
@property (strong, nonatomic) NSDate *toNight;


@property (strong, nonatomic) NSNumber *notifyMeNumber;
@property (strong, nonatomic) NSString *notifyMeUnit;

@property (strong, nonatomic) NSNumber *locationSleepNumber;
@property (strong, nonatomic) NSString *locationSleepUnit;

@property (strong, nonatomic) NSString *temperatureType;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSString *userName;



+ (NSString *)parseClassName;



@end
