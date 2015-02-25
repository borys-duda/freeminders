//
//  TaskTableViewCell.h
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface TaskCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UIImageView *triggerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *stepsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *importantImageView;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *dependImageView;
@property  (weak, nonatomic) IBOutlet UIImageView *localNotifcationImageView;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthCon;
@end
