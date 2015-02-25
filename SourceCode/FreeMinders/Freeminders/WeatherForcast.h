//
//  WeatherForcast.h
//  Freeminders
//
//  Created by Spencer Morris on 5/15/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherForcast : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *day;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber *high;
@property (strong, nonatomic) NSNumber *low;

@end
