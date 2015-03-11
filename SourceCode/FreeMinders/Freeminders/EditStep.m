//
//  EditStep.m
//  Freeminders
//
//  Created by Vegunta's on 08/01/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "EditStep.h"
#import "UserData.h"
#import "Utils.h"
#import "DataManager.h"

@interface EditStep ()

@property (weak, nonatomic) IBOutlet UITextView *stepTextView;

@end

@implementation EditStep
 @synthesize indexPathRow;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUI];
}
-(void)setUpUI
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(pickerDone)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:[NSArray arrayWithObjects: spaceItem, doneButton ,spaceItem, nil] animated:NO];
    if (indexPathRow >= 0)
        self.stepTextView.text=[UserData instance].step.name;
    else
        self.title = @"Add Step";
    self.stepTextView.delegate=self;
    self.stepTextView.autocapitalizationType=UITextAutocapitalizationTypeSentences;
    [self.stepTextView  setInputAccessoryView:pickerToolbar];
    [self.stepTextView becomeFirstResponder];
}
-(IBAction)cacelButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(IBAction)deleteButtonAction:(id)sender
{
    [self hideKeyBoard];
    if (indexPathRow >= 0) {
        [UserData instance].step=[[UserData instance].task.reminderSteps objectAtIndex:indexPathRow];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Step?" message:@"Are you sure you want to delete this Step? This cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alertView show];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;  //[text rangeOfString:@"\n"].location == NSNotFound;
}
- (void)textViewDidChange:(UITextView *)textView
{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
   
}
-(void)hideKeyBoard
{
    [self.stepTextView resignFirstResponder];
}
-(void)pickerDone
{
    [self hideKeyBoard];
    NSMutableArray *mutableSteps = [[UserData instance].task.reminderSteps mutableCopy];
    if (! mutableSteps) mutableSteps = [[NSMutableArray alloc] init];
    if (indexPathRow >= 0) {
        ReminderStep *rStep = [mutableSteps objectAtIndex:indexPathRow];
        rStep.name = self.stepTextView.text;
        [mutableSteps setObject:rStep atIndexedSubscript:indexPathRow];
    }else {
        ReminderStep *step = [[ReminderStep alloc] init];
        step.name = self.stepTextView.text;
        step.isComplete = NO;
        step.order = [NSNumber numberWithInt:mutableSteps.count];
        [mutableSteps addObject:step];
    }
    [UserData instance].task.reminderSteps = [mutableSteps mutableCopy];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self performDeleteStep:[UserData instance].step];
    }
}
-(void)performDeleteStep:(ReminderStep *)stepToDelete
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UserData instance].task.reminderSteps removeObject:stepToDelete];
    
    [[DataManager sharedInstance] saveReminder:[UserData instance].task withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
        if(succeeded)
        {
            [[UserData instance].step deleteInBackground];
            [UserData instance].step = nil;
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }];
}
@end
