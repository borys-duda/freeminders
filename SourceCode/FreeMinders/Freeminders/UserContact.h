//
//  UserContact.h
//  Freeminders
//
//  Created by Vegunta's on 19/09/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//
#import <Parse/Parse.h>

@interface UserContact : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (assign) BOOL defaultBool;
@property (strong, nonatomic) PFUser *user;

+ (NSString *)parseClassName;
@end
