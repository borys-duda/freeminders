//
//  TaskListVC.h
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "CustomVC.h"
#import "SWTableViewCell.h"
#import "EGORefreshTableHeaderView.h"

@interface TaskListVC : CustomVC <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, EGORefreshTableHeaderDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
UIDatePicker *snoozeDatePicker;
}
@end
