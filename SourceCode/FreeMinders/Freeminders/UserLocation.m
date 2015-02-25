//
//  titleclassforLocation.m
//  Freeminders
//
//  Created by Vegunta's on 20/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "UserLocation.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserLocation

@dynamic name,isDefault,user,address,location,radius,zipCode;


+ (NSString *)parseClassName
{
    return @"UserLocation";
}


@end
