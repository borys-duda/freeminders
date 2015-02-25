//
//  InterfaceAdapterArgs.m
//  Freeminders
//
//  Created by Developer on 1/23/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "InterpreterAdapterArgs.h"

// These query callbcak arg classes don't really need any implementation.  They are
// just a holder for properties defined in the header
@implementation BaseQueryCallbackArgs

-(id)initWithTitleMessage:(NSString *)theTitle message:(NSString *)theMessage {
    self = [super init];
    if (self) {
        self.title = theTitle;
        self.message = theMessage;
    }
    return self;
}

+(instancetype)title:(NSString *)theTitle message:(NSString *)theMessage {
    return [[self alloc] initWithTitleMessage:theTitle message:theMessage];
}

@end

@implementation QueryDateCallbackArgs
@end

@implementation QueryTimeCallbackArgs
@end

@implementation QueryIntegerCallbackArgs
@end

@implementation QueryStringCallbackArgs
@end