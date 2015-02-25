//
//  AddEditTaskTVC.h
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "CustomTVC.h"

@interface AddEditTaskTVC : CustomTVC <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    UITextView *currentTextView;
}
@property (nonatomic) BOOL isFromSteps;

@end
