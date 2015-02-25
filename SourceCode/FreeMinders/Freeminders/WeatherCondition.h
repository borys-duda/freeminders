//
//  WeatherCondition.h
//  Freeminders
//
//  Created by Spencer Morris on 5/15/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherCondition : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *temp;
@property (strong, nonatomic) NSString *text;

@end
