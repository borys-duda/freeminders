//
//  titleclassforLocation.h
//  Freeminders
//
//  Created by Vegunta's on 20/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserLocation : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic) BOOL isDefault;
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSNumber *radius;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *zipCode;


+ (NSString *)parseClassName;



@end
