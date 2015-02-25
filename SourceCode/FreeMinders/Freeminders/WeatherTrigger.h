//
//  WeatherTrigger.h
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserLocation.h"

@interface WeatherTrigger : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *taskId;

// weather

@property (nonatomic) BOOL isPrecipitation;
@property (nonatomic) BOOL isDrizzleOption;
@property (nonatomic) BOOL isRainOption;
@property (nonatomic) BOOL isLightTStormsOption;
@property (nonatomic) BOOL isTStormsOption;
@property (nonatomic) BOOL isSevereTStormsOption;

@property (nonatomic) BOOL isFreezing;
@property (nonatomic) BOOL isFreezingDrizzleOption;
@property (nonatomic) BOOL isFreezingRainOption;
@property (nonatomic) BOOL isSleetOption;
@property (nonatomic) BOOL isSnowFlurriesOption;
@property (nonatomic) BOOL isLightSnowOption;
@property (nonatomic) BOOL isSnowOption;
@property (nonatomic) BOOL isHeavySnowOption;

@property (nonatomic) BOOL isSevere;
@property (nonatomic) BOOL isSevereStormOption;
@property (nonatomic) BOOL isTropicalStormOption;
@property (nonatomic) BOOL isHurricaneOption;
@property (nonatomic) BOOL isTornadoOption;
@property (nonatomic) BOOL isHailOption;

@property (nonatomic) BOOL isSkyline;
@property (nonatomic) BOOL isSunnyOption;
@property (nonatomic) BOOL isPartiallyCloudyOption;
@property (nonatomic) BOOL isCloudyOption;

@property (nonatomic) BOOL isWind;
@property (nonatomic) BOOL isWindyOption;
@property (nonatomic) BOOL isBlusteryOption;

@property (nonatomic) BOOL isTemperature;
@property (nonatomic) BOOL isAlertAboveTemp;
@property (nonatomic) BOOL isAlertBelowTemp;
@property (strong, nonatomic) NSNumber *temperature;

// time
@property (strong, nonatomic) NSNumber *notifyHour;
@property (strong, nonatomic) NSNumber *notifyMin;
@property (strong, nonatomic) NSString *notifyAmPm;
@property (strong, nonatomic) NSNumber *notifyDays;

@property (nonatomic) BOOL isRepeat;

// location
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *zipCode;

@property (strong, nonatomic) UserLocation *userLocation;

+ (NSString *)parseClassName;

- (WeatherTrigger *)copy;

@end
