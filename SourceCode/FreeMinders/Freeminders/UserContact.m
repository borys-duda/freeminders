//
//  UserContact.m
//  Freeminders
//
//  Created by Vegunta's on 19/09/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "UserContact.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserContact

@dynamic name,email,defaultBool,user;


+ (NSString *)parseClassName
{
    return @"UserContact";
}
@end
