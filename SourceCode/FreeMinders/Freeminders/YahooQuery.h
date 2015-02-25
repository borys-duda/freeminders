//
//  YahooQuery.h
//  Freeminders
//
//  Created by Spencer Morris on 5/15/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YahooResults.h"

@interface YahooQuery : NSObject

@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) YahooResults *results;

@end
