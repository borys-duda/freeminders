//
//  TaskSetCell.h
//  Freeminders
//
//  Created by Spencer Morris on 5/7/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskSetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end
