//
//  Settings.m
//  Freeminders
//
//  Created by Vegunta's on 02/09/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "UserSetting.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserSetting

@dynamic taskId,alertTime,toNight,inTheMorning,notifyMeNumber,notifyMeUnit,temperatureType,locationSleepNumber,locationSleepUnit, user, userName;


+ (NSString *)parseClassName
{
    return @"UserSetting";
}



@end
