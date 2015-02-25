//
//  LocationCell.h
//  Freeminders
//
//  Created by Saisyam Dampuri on 10/8/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *defaultButton;
@property (weak, nonatomic) IBOutlet UIButton *makedefaultButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
