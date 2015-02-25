//
//  UserInfo.m
//  Freeminders
//
//  Created by Spencer Morris on 5/20/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "UserInfo.h"
#import <Parse/PFObject+Subclass.h>
#import "Reminder.h"
#import "UserData.h"
#import "StoreHelper.h"

@interface UserInfo ()

@end

@implementation UserInfo

@synthesize userId, name, defaultLocationPoint, defaultLocationZIP, defaultLocationAddress;

+ (NSString *)parseClassName
{
    return @"UserInfo";
}

@end
