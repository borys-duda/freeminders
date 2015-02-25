//
//  InterpreterAdapter.h
//  Freeminders
//
//  Created by Developer on 1/22/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "InterpreterAdapterArgs.h"

@interface InterpreterAdapter : NSObject

@property (nonatomic, copy)void (^selectionChanged)(NSObject *selection);
@property (nonatomic, copy)void (^inputCancelled)(void);

- (void)queryDate:(QueryDateCallbackArgs *)args;
- (void)queryTime:(QueryTimeCallbackArgs *)args;
- (void)queryString:(QueryStringCallbackArgs *)args;
- (void)queryInteger:(QueryIntegerCallbackArgs *)args;

- (void)cleanup;

@end

