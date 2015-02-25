//
//  WeatherTrigger.m
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "WeatherTrigger.h"
#import <Parse/PFObject+Subclass.h>

@implementation WeatherTrigger

@dynamic taskId, location, address, isDrizzleOption, isLightTStormsOption, isRainOption, isTStormsOption, isPrecipitation, isFreezing, isSevere, isSkyline, isTemperature, isWind, isBlusteryOption, isCloudyOption, isFreezingDrizzleOption, isFreezingRainOption, isHailOption, isHeavySnowOption, isHurricaneOption, isLightSnowOption, isPartiallyCloudyOption, isSevereStormOption, isSevereTStormsOption, isSleetOption, isSnowFlurriesOption, isSnowOption, isSunnyOption, isTornadoOption, isTropicalStormOption, isWindyOption, temperature, isAlertAboveTemp, isAlertBelowTemp, notifyAmPm, notifyDays, notifyHour, notifyMin, isRepeat, zipCode, userLocation;

+ (NSString *)parseClassName
{
    return @"WeatherTrigger";
}

- (WeatherTrigger *)copy
{
    WeatherTrigger *trigger = [[WeatherTrigger alloc] init];
    
    trigger.taskId = self.taskId;
    trigger.location = self.location;
    trigger.address = self.address;
    trigger.isDrizzleOption = self.isDrizzleOption;
    trigger.isLightTStormsOption = self.isLightTStormsOption;
    trigger.isRainOption = self.isRainOption;
    trigger.isTStormsOption = self.isTStormsOption;
    trigger.isPrecipitation = self.isPrecipitation;
    trigger.isFreezing = self.isFreezing;
    trigger.isSevere = self.isSevere;
    trigger.isSkyline = self.isSkyline;
    trigger.isTemperature = self.isTemperature;
    trigger.isWind = self.isWind;
    trigger.isBlusteryOption = self.isBlusteryOption;
    trigger.isCloudyOption = self.isCloudyOption;
    trigger.isFreezingDrizzleOption = self.isFreezingDrizzleOption;
    trigger.isFreezingRainOption =self.isFreezingRainOption;
    trigger.isHailOption = self.isHailOption;
    trigger.isHeavySnowOption = self.isHeavySnowOption;
    trigger.isHurricaneOption = self.isHurricaneOption;
    trigger.isLightSnowOption = self.isLightSnowOption;
    trigger.isPartiallyCloudyOption = self.isPartiallyCloudyOption;
    trigger.isSevereStormOption = self.isSevereStormOption;
    trigger.isSevereTStormsOption = self.isSevereTStormsOption;
    trigger.isSleetOption = self.isSleetOption;
    trigger.isSnowFlurriesOption = self.isSnowFlurriesOption;
    trigger.isSnowOption = self.isSnowOption;
    trigger.isSunnyOption = self.isSunnyOption;
    trigger.isTornadoOption = self.isTornadoOption;
    trigger.isTropicalStormOption = self.isTropicalStormOption;
    trigger.isWindyOption = self.isWindyOption;
    trigger.temperature = self.temperature;
    trigger.isAlertAboveTemp = self.isAlertAboveTemp;
    trigger.isAlertBelowTemp = self.isAlertBelowTemp;
    trigger.notifyAmPm = self.notifyAmPm;
    trigger.notifyDays = self.notifyDays;
    trigger.notifyHour = self.notifyHour;
    trigger.notifyMin = self.notifyMin;
    trigger.isRepeat = self.isRepeat;
    trigger.zipCode = self.zipCode;
    trigger.userLocation = self.userLocation;
    return trigger;
}

@end
