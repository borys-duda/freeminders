//
//  UserInfo.h
//  Freeminders
//
//  Created by Spencer Morris on 5/20/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserInfo : NSObject//PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) PFGeoPoint *defaultLocationPoint;
@property (strong, nonatomic) NSString *defaultLocationZIP;
@property (strong, nonatomic) NSString *defaultLocationAddress;

+ (NSString *)parseClassName;

@end
