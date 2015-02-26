//
//  StoreGroupTVC.m
//  Freeminders
//
//  Created by Spencer Morris on 5/23/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "StoreGroupTVC.h"
#import "Utils.h"
#import "StoreHelper.h"
#import "DataManager.h"

@interface StoreGroupTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *numMindersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numTriggersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numStepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *sampleTask1Label;
@property (weak, nonatomic) IBOutlet UILabel *sampleTask2Label;
@property (weak, nonatomic) IBOutlet UILabel *sampleTask3Label;
@property (weak, nonatomic) IBOutlet UILabel *sampleTask4Label;
@property (weak, nonatomic) IBOutlet UILabel *sampleTask5Label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForgroupTitletextviewConstriant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForTextViewConstriant;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UILabel *moreLabelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *moreLabelForDisc;


@property (nonatomic) BOOL tableViewSelected;
@end

@implementation StoreGroupTVC

NSInteger SECTION_SAMPLE_MINDERS = 2;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.priceButton.layer.cornerRadius = 10.0f;
    self.priceButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.priceButton.layer.borderWidth = 1.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedNotification object:nil];
    
    [self setupUI];
    [self.tableView reloadData];
}

- (void)setupUI
{
    StoreItem *storeGroup = [UserData instance].storeGroup;
    self.titleLabel.text = ((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).name;
    self.descriptionLabel.text = storeGroup.desc;
    self.numMindersLabel.text = [NSString stringWithFormat:@"%i Reminders", (int)((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count];
    self.numTriggersLabel.text = [NSString stringWithFormat:@"%i Triggers", [storeGroup numberOfTriggers]];
    self.numStepsLabel.text = [NSString stringWithFormat:@"%i Steps", [storeGroup numberOfSteps]];
//    self.numEmailsLabel.text = [NSString stringWithFormat:@"%i Emails", [storeGroup countEmail].intValue];
//    self.numSMSLabel.text = [NSString stringWithFormat:@"%i SMS", [storeGroup countSMS].intValue];
    
    if ([storeGroup isPurchased] || [UserData instance].isHavingActiveSubscription) {
        [self.priceButton setTitle:@"Add" forState:UIControlStateNormal];
    } else {
        [self.priceButton setTitle:[NSString stringWithFormat:@"$%.02f", storeGroup.price.floatValue] forState:UIControlStateNormal];
    }
    
    Reminder *task;
    if (((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count > 0) {
        task = [((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders objectAtIndex:0];
        self.sampleTask1Label.text = (![task isEqual:[NSNull null]])?task.name:@"";
    }
    if (((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count > 1) {
        task = [((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders objectAtIndex:1];
        self.sampleTask2Label.text = (![task isEqual:[NSNull null]])?task.name:@"";
    }
    if (((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count > 2) {
        task = [((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders objectAtIndex:2];
        self.sampleTask3Label.text = (![task isEqual:[NSNull null]])?task.name:@"";
    }
    if (((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count > 3) {
        task = [((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders objectAtIndex:3];
        self.sampleTask4Label.text = (![task isEqual:[NSNull null]])?task.name:@"";
    }
    if (((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count > 4) {
        task = [((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders objectAtIndex:4];
        self.sampleTask5Label.text = (![task isEqual:[NSNull null]])?task.name:@"";
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if(([self heightForTheGroupTitleName] > 30))
    {
        [self.moreLabelForTitle setHidden:NO];
    }else{
        [self.moreLabelForTitle setHidden:YES];
    }
    if([self heightForTheGroupTitleDiscription] > 60)
    {
        [self.moreLabelForDisc setHidden:NO];
    }else{
        [self.moreLabelForDisc setHidden:YES];
        
    }
}
- (void)productPurchased:(NSNotification *)notification
{
    NSLog(@"PURCHASED PRODUCT LOADED");
    NSDictionary *purchase = notification.userInfo;
    
    UserPurchase *newPurchase = [[UserPurchase alloc] init];
    newPurchase.user = [PFUser currentUser];
    newPurchase.storeItemId = [purchase objectForKey:@"storeItemId"];
    newPurchase.receiptId = [purchase objectForKey:@"receiptId"];
    newPurchase.storeItem = [UserData instance].storeGroup;
    newPurchase.amountPaid = [UserData instance].storeGroup.salePrice;
    newPurchase.itemType = [NSNumber numberWithInt:typeIndividual];
    newPurchase.lastTransactionDate = [purchase objectForKey:@"lastTransactionDate"];
    if ([UserData instance].isHavingActiveSubscription) {
        newPurchase.expireDate = [UserData instance].userSubscription.expireDate;
        newPurchase.amountPaid = [NSNumber numberWithInt:0];
    }
    
    [[DataManager sharedInstance] saveToLocalWithObject:newPurchase withBlock:^(BOOL succeeded, NSError *error) {
        NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
        [prevPurchases addObject:newPurchase];
        [UserData instance].userPurchases = [prevPurchases mutableCopy];
    }];
    
    
    [Utils addTasksFromStoreGroup:self.view];
}

- (void)productFailed:(NSNotification *)notification
{
    [Utils showSimpleAlertViewWithTitle:notification.userInfo[@"title"] content:notification.userInfo[@"message"] andDelegate:nil];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark- Actions

- (IBAction)priceButtonPressed
{
    for (SKProduct *product in [UserData instance].itunesProducts) {
        if ([product.productIdentifier isEqualToString:[UserData instance].storeGroup.objectId]) {
            
            if ([[StoreHelper sharedInstance] isProductPurchased:[UserData instance].storeGroup.objectId]) {
                //                [Utils addTasksFromStoreGroup];
                if ([Utils didGroupExist:[UserData instance].storeGroup.objectId]) {
                    [Utils showSimpleAlertViewWithTitle:@"Duplicate Group" content:[NSString stringWithFormat:@"The group %@ is already downloaded.", [UserData instance].storeGroup.name] andDelegate:nil];
                }else{
                    [Utils addTasksFromStoreGroup:self.view];
//                    [Utils showSimpleAlertViewWithTitle:@"Reminder Group Added" content:[NSString stringWithFormat:@"The %@ is being downloaded. Please allow up to 5 minutes for integration into your account.",[UserData instance].storeGroup.name ]andDelegate:self];
                }
            }else if([UserData instance].isHavingActiveSubscription){
                NSMutableDictionary *purchaseInfo = [[NSMutableDictionary alloc] init];
                [purchaseInfo setValue:[UserData instance].storeGroup.objectId forKey:@"storeItemId"];
                [purchaseInfo setValue:[NSDate date] forKey:@"lastTransactionDate"];
                [[StoreHelper sharedInstance] provideContentForProductIdentifier:purchaseInfo];
//                [Utils showSimpleAlertViewWithTitle:@"Reminder Group Added" content:[NSString stringWithFormat:@"The %@ is being downloaded. Please allow up to 5 minutes for integration into your account.",[UserData instance].storeGroup.name ]andDelegate:self];//@"You have an active subscription. Task are being added to your account without any charges."
            } else {
                [[StoreHelper sharedInstance] buyProduct:product];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }
            
            return; // in case 2 products with same id, don't try to buy both
            // (but that should never happen)
        }
    }
}

#pragma mark- UITableView methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_SAMPLE_MINDERS
        && indexPath.row >= ((ReminderGroup *)[[UserData instance].storeGroup.reminderGroups objectAtIndex:0]).reminders.count) {
        return 0.0;
    }
//    }else  if(indexPath.section ==0){
//        
//        return [self heightForTheGroupTitleName];
//        
//    }else if (indexPath.section==1)
//    {
//        return [self  heightForTheGroupTitleDiscription];
//    }
    else{
        return [super  tableView:tableView heightForRowAtIndexPath:indexPath];
 
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreItem *storeGroup = [UserData instance].storeGroup;
    self.tableViewSelected = 1;
    if(indexPath.section ==0 && ([self heightForTheGroupTitleName] > 30)){
        
        [Utils showSimpleAlertViewWithTitle:@"Reminder Group Name" content:[NSString stringWithFormat:@"%@",((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).name] andDelegate:self];
        
    }else if (indexPath.section==1 && ([self heightForTheGroupTitleDiscription] > 60))
    {
       [Utils showSimpleAlertViewWithTitle:@"Reminder Group description" content:[NSString stringWithFormat:@"%@",storeGroup.desc] andDelegate:self];
    }
}


- (void)deregisterForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    [center removeObserver:self name:IAPHelperProductFailedNotification object:nil];
}
-(CGFloat)heightForTheGroupTitleName
{
    StoreItem *storeGroup = [UserData instance].storeGroup;
    NSString *string=   ((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).name;
    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName: @"Helvetica" size: 17]];
    txtSz.width +=20;
    CGRect lblFrame = CGRectMake(18,0, txtSz.width, txtSz.height + 10);
    int lineCount = txtSz.width/230;
    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
    strCount /= [@"\n" length];
    if(txtSz.width > 230)
    {
        lineCount += 1;
        lblFrame = CGRectMake(18,0, 240, txtSz.height*(lineCount+strCount+1));
    }
    return lblFrame.size.height;
}
-(CGFloat)heightForTheGroupTitleDiscription
{
    StoreItem *storeGroup = [UserData instance].storeGroup;
    NSString *string= storeGroup.desc;
    CGSize txtSz = [string sizeWithFont:[UIFont fontWithName: @"Helvetica" size: 15]];
    txtSz.width +=20;
    CGRect lblFrame = CGRectMake(18,0, txtSz.width, txtSz.height + 10);
    int lineCount = txtSz.width/230;
    long strCount = [string length] - [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
    strCount /= [@"\n" length];
    if(txtSz.width > 230)
    {
        lineCount += 1;
        lblFrame = CGRectMake(18,0, 240, txtSz.height*(lineCount+strCount+1));
    }
    
    
    return lblFrame.size.height;
}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *MyIdentifier = @"MyIdentifier";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
//        
//    }
//       if(indexPath.section == 0)
//        {
//            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//            CGFloat lblFrame=[self heightForTheGroupTitleName];
//            [self.titleLabel setFrame:CGRectMake(18, 0, 280, lblFrame)];
//            StoreItem *storeGroup = [UserData instance].storeGroup;
//            self.titleLabel.text=   ((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).name;
//            self.heightForgroupTitletextviewConstriant.constant=lblFrame;
//        }else if (indexPath.section == 1)
//        {
//            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//            CGFloat lblFrame=[self heightForTheGroupTitleDiscription];
//            [self.descriptionLabel setFrame:CGRectMake(18, 0, 280, lblFrame-110)];
//            StoreItem *storeGroup = [UserData instance].storeGroup;
//            self.descriptionLabel.text=storeGroup.desc;;
//            self.heightForTextViewConstriant.constant=lblFrame-110;
//        }else{
//                cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//        }
//        return cell;
//}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(self.tableViewSelected)
        self.tableViewSelected=0;
    else
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
