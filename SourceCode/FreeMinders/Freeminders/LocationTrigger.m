//
//  LocationTrigger.m
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "LocationTrigger.h"
#import <Parse/PFObject+Subclass.h>

@implementation LocationTrigger

@dynamic taskId, location, radius, address, isRepeat, userLocation;

+ (NSString *)parseClassName
{
    return @"LocationTrigger";
}

- (LocationTrigger *)copy
{
    LocationTrigger *trigger = [[LocationTrigger alloc] init];
    
    trigger.taskId = self.taskId;
    trigger.location = self.location;
    trigger.radius = self.radius;
    trigger.address = self.address;
    trigger.isRepeat = self.isRepeat;
    trigger.userLocation = self.userLocation;
    
    return trigger;
}

@end
