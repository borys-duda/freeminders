//
//  LocationTrigger.h
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserLocation.h"

@interface LocationTrigger : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *taskId;
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSNumber *radius;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) BOOL isRepeat;
@property (strong, nonatomic) UserLocation *userLocation;

+ (NSString *)parseClassName;

- (LocationTrigger *)copy;

@end
