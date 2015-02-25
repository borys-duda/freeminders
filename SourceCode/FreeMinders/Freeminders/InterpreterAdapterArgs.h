//
//  InterfaceAdapterArgs.h
//  Freeminders
//
//  Created by Developer on 1/23/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "TimeSpan.h"

// Base class for query callback
@interface BaseQueryCallbackArgs : NSObject

@property NSString *title;
@property NSString *message;

- (id)initWithTitleMessage:(NSString *)theTitle message:(NSString *)theMessage;
+ (instancetype)title:(NSString *)theTitle message:(NSString *)theMessage;

@end

// Date callback class
@interface QueryDateCallbackArgs : BaseQueryCallbackArgs

@property BOOL includeTime;
@property NSDate *val;
@property NSDate *min;
@property NSDate *max;

@end

// Time callback class
@interface QueryTimeCallbackArgs : BaseQueryCallbackArgs

@property BOOL isTimeSpan;
@property TimeSpan *val;
@property TimeSpan *min;
@property TimeSpan *max;

@end

// Integer callback class
@interface QueryIntegerCallbackArgs : BaseQueryCallbackArgs

@property NSNumber *val;
@property NSNumber *min;
@property NSNumber *max;

@end

// String callback
@interface QueryStringCallbackArgs : BaseQueryCallbackArgs

@property NSString *val;
@property NSNumber *min;
@property NSNumber *max;

@end