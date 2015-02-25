//
//  WeatherData.h
//  Freeminders
//
//  Created by Spencer Morris on 5/15/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherCondition.h"

@interface WeatherData : NSObject

@property (strong, nonatomic) NSString *title;
//@property (strong, nonatomic) NSString *latitude;
//@property (strong, nonatomic) NSString *longitude;
//@property (strong, nonatomic) NSString *link;
//@property (strong, nonatomic) NSString *pubDate;
//@property (strong, nonatomic) NSString *description;

@property (strong, nonatomic) NSArray *forecast;
@property (strong, nonatomic) WeatherCondition *condition;

@end
