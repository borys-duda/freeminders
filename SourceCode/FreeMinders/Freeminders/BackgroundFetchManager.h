//
//  BackgroundFetchManager.h
//  Freeminders
//
//  Created by Spencer Morris on 5/19/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundFetchManager : NSObject

+ (BackgroundFetchManager *)sharedInstance;

- (void)performLoadTasks;

@end
