//
//  LoginVC.h
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "CustomVC.h"

@interface LoginVC : CustomVC <UIAlertViewDelegate>


@property (nonatomic) BOOL isFirstTimeInstallationApp;

- (void)defaultRemindersCallBack:(NSError *)error;

@end
