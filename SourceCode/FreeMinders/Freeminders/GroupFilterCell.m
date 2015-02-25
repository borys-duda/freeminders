//
//  GroupFilterCell.m
//  Freeminders
//
//  Created by Spencer Morris on 5/6/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "GroupFilterCell.h"

@implementation GroupFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
