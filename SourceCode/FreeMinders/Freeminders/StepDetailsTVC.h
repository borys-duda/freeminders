//
//  StepDetailsTVC.h
//  Freeminders
//
//  Created by Vegunta's on 11/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTVC.h"

@interface StepDetailsTVC : CustomTVC <UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSTimer *stopTimer;
    NSDate *startDate;
    NSDate *endDate;
    BOOL running,isStopwatch;
    NSTimeInterval interval;
    UITextField *dummyField;
    Reminder *remCopy;
    NSMutableDictionary *reminderObject;
    NSNumber *timerType;
    NSNumber *timerIntervel;
    NSNumber *timerIntervelForCountdown;

}


@end
