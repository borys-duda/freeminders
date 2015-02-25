//
//  InterpreterAdapter.m
//  Freeminders
//
//  Created by Developer on 1/22/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "InterpreterAdapter.h"
#import "InterpreterAdapterArgs.h"

// TODO: Move these into Const.h maybe? Maybe reuse some of those, like for OK/Cancel?
#define CONFIRM_TITLE @"Confirm Cancel"
#define CONFIRM_MESSAGE @"Cancelling this mandatory input will remove the group from your freeminders app. If you do cancel, you may download it again with no additional charge.  Would you like to proceed and cancel this download?"
#define CONFIRM_BUTTON_YES @"Yes"
#define CONFIRM_BUTTON_NO @"Go Back"

#define BUTTON_OK_TEXT @"OK"
#define BUTTON_CANCEL_TEXT @"Cancel"

typedef NS_ENUM(NSInteger, FMPromptType) {
    FMPromptTypeDate = 0,
    FMPromptTypeTime,
    FMPromptTypeTimeSpan,
    FMPromptTypeString,
    FMPromptTypeInteger
};

typedef NS_ENUM(NSInteger, FMAlertType) {
    FMAlertTypePrompt = 0,
    FMAlertTypeConfirmCancel,
    FMAlertTypeFailedValidation
};

@interface InterpreterAdapter () {

    
}
@end

@implementation InterpreterAdapter

UIAlertView *alertView;

UIControl *inputControl;
UITextField *textField;
BOOL(^validate)(void);

NSUInteger maxLength;

FMPromptType promptType;

- (void)queryDate:(QueryDateCallbackArgs *)args {

    [self createAlertView:args];
    promptType = FMPromptTypeDate;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    UIDatePickerMode mode = args.includeTime ? UIDatePickerModeDateAndTime : UIDatePickerModeDate;
    
    [datePicker addTarget:self action:@selector(updateTextFromDatePicker:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDatePickerMode:mode];
    
    inputControl = datePicker;
    
    textField = [alertView textFieldAtIndex:0];
    textField.inputView = datePicker;
    
    if (args.min) [datePicker setMinimumDate:args.min];
    if (args.max) [datePicker setMaximumDate:args.max];
    if (args.val) [datePicker setDate:args.val];
    
    [self updateTextFromDatePicker: datePicker];
    
    validate = ^BOOL(void) {
        // If you want to validate this, add the logic here.  If it is invalid,
        // display a UIAlertView with a tag of FMAlertTypeFailedValidation
        // and return false;
        return TRUE;
    };
    
    [alertView show];
    [textField becomeFirstResponder];
}

- (void)queryTime:(QueryTimeCallbackArgs *)args {

    // TODO
    //if (args.isTimeSpan) {
    
    [self createAlertView:args];
    promptType = FMPromptTypeTime;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    
    [datePicker addTarget:self action:@selector(updateTextFromDatePicker:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDatePickerMode:UIDatePickerModeTime];
    
    inputControl = datePicker;
    
    textField = [alertView textFieldAtIndex:0];
    textField.inputView = datePicker;
    
    if (args.val || args.min || args.max) {
        
        NSDate *today = [[NSDate date] dateOnly];
        
        if (args.min) [datePicker setMinimumDate:[args.min addToDate:today]];
        if (args.max) [datePicker setMaximumDate:[args.max addToDate:today]];
        if (args.val) [datePicker setDate:[args.val addToDate:today]];
    }
    
    if (!args.val)
        [datePicker setDate:[[NSDate date] withoutSeconds]];
    
    [self updateTextFromDatePicker: datePicker];

    validate = ^BOOL(void) {
        // If you want to validate this, add the logic here.  If it is invalid,
        // display a UIAlertView with a tag of FMAlertTypeFailedValidation
        // and return false;
        return TRUE;
    };
    
    [alertView show];
    [textField becomeFirstResponder];
}

- (void)queryString:(QueryStringCallbackArgs *)args {

    [self createAlertView:args];
    promptType = FMPromptTypeString;
    
    if (args.val)
        textField.text = args.val;
    
    // UIAlertView doesn't allow us to modify the textField, so, if we really want to
    // do this, we'll have to replace UIAlertView with a custom alert view class.
    // *Might* be able to do this with a delegate on textField
    //if (args.min)
    if (args.max) maxLength = [args.max integerValue];
    
    validate = ^BOOL(void) {
        // If you want to validate this, add the logic here.  If it is invalid,
        // display a UIAlertView with a tag of FMAlertTypeFailedValidation
        // and return false;
        
        // TODO: If a min or max is specified, display an alert
        // If min, "Please enter a value at least min character long"
        // If max, "Please enter a value less than max characters.
        //  Note: max should be taken care of by limiting the input
        
        return TRUE;
    };
    
    [alertView show];
    [textField becomeFirstResponder];
}

- (void)queryInteger:(QueryIntegerCallbackArgs *)args {
    
    [self createAlertView:args];
    promptType = FMPromptTypeInteger;
    
    maxLength = 9;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    if (args.val)
        textField.text = [args.val stringValue];
    
    // UIAlertView doesn't allow us to modify the textField, so, if we really want to
    // do this, we'll have to replace UIAlertView with a custom alert view class.
    //if (args.min)
    //if (args.max)
    
    validate = ^BOOL(void) {
        // If you want to validate this, add the logic here.  If it is invalid,
        // display a UIAlertView with a tag of FMAlertTypeFailedValidation
        // and return false;
        
        // TODO: If a min or max is specified, display an alert
        // If min and max "Please enter a value between min and max"
        // If min "Please enter a value greater than or equal to min"
        // If max "Please enter a value less than or equal to max"
        
        return TRUE;
    };
    
    [alertView show];
    [textField becomeFirstResponder];
}

- (void)createAlertView:(BaseQueryCallbackArgs *)args {
    
    maxLength = -1;
    alertView = [[UIAlertView alloc] initWithTitle:args.title message:args.message delegate:self cancelButtonTitle:BUTTON_CANCEL_TEXT otherButtonTitles:BUTTON_OK_TEXT, nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = FMAlertTypePrompt;
    
    textField = [alertView textFieldAtIndex:0];
    
    // cast to prevent a compiler warning
    textField.delegate = (id<UITextFieldDelegate>)self;
}

- (void)updateTextFromDatePicker:(UIDatePicker *)picker {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    switch (picker.datePickerMode) {
        case UIDatePickerModeTime:
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            break;
        case UIDatePickerModeDate:
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            break;
        case UIDatePickerModeDateAndTime:
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            break;
        default:
            // We only handle those 3 for now.  This is here to keep
            // the compiler for complaining
            break;
    }
    
    [alertView textFieldAtIndex:0].text = [formatter stringFromDate:picker.date];
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (alertView.visible) {
        
        // Not sure if this is needed anymore.  It was from an old stackoverflow article
        // about an undo bug.
        if (range.length + range.location > theTextField.text.length)
            return NO;
        
        if (maxLength > 0) {
            NSUInteger proposedLength = theTextField.text.length + string.length - range.length;
            return (proposedLength > maxLength) ? NO : YES;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    // We can have a total of 3 alerts being used by this adapter.
    //  1 = The main alert, asking for input
    //  2 = The alert confirming they want to cancel
    //  3 = The alert saying the input is invalid
    
    switch (theAlertView.tag) {
        case FMAlertTypePrompt:
        {
            // Ok, we asked the user for input
            if (buttonIndex == 1) {
                if (!validate || validate()) {
                    // And they accepted the input, oh yeah!
                    if (self.selectionChanged)
                        self.selectionChanged([self getValue]);
//                    [self cleanup];
                }
            }
            else {
                // They attempted to cancel. Give them a cancel to continue
                UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:CONFIRM_TITLE message:CONFIRM_MESSAGE delegate:self cancelButtonTitle:CONFIRM_BUTTON_NO otherButtonTitles:CONFIRM_BUTTON_YES, nil];
                confirmAlert.tag = FMAlertTypeConfirmCancel;
                [confirmAlert show];
            }
            
            break;
        }
        case FMAlertTypeConfirmCancel:
        {
            // This *should* be the confirm cancel alert
            if (buttonIndex == 0) {
                // They are not going to cancel, so, redisplay the alert view
                [alertView show];
            }
            else {
                // They want to cancel
                if (self.inputCancelled)
                    self.inputCancelled();
//                [self cleanup];
            }
            
            break;
        }
        case FMAlertTypeFailedValidation:
        {
            [alertView show];
            break;
        }
    }
    
}

- (NSObject *)getValue {
    
    switch (promptType) {
        case FMPromptTypeDate:
        {
            UIDatePicker *picker = (UIDatePicker *)inputControl;
            
            switch (picker.datePickerMode) {
                case UIDatePickerModeDate:
                    return [picker.date dateOnly];
                case UIDatePickerModeDateAndTime:
                    return [picker.date copy];
                default:
                    // It shouldn't be anything other.  This is just to prevent a compiler warning
                    break;
            }
            
            break;
        }
        case FMPromptTypeTime:
        {
            UIDatePicker *picker = (UIDatePicker *)inputControl;
            return [picker.date timeOnly];
        }
        case FMPromptTypeTimeSpan:
        {
            // TODO - Return TimeSpan with year, month, day, hour, minutes, seconds
            // This may, or may not be done sometime in the future
            break;
        }
        case FMPromptTypeString:
        {
            return textField.text;
            break;
        }
        case FMPromptTypeInteger:
        {
            // TODO - Return NSInteger inside an NSNumber
            break;
        }
    }
    
    return nil;
}

- (void)cleanup {
    if (validate)
        validate = nil;
    if (inputControl)
        inputControl = nil;
    if (textField)
        textField = nil;
    if (alertView)
        alertView = nil;
}


@end
