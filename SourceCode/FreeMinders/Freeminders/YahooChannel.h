//
//  YahooChannel.h
//  Freeminders
//
//  Created by Spencer Morris on 5/15/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherData.h"

@interface YahooChannel : NSObject

@property (strong, nonatomic) WeatherData *weatherData;

@end
