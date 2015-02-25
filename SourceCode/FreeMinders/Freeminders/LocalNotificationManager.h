//
//  LocalNotificationManager.h
//  Freeminders
//
//  Created by Spencer Morris on 5/8/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject

+ (void)setNotificationsForAllTasks;

+ (void)setNotificationsForLocationTasks;


@end
