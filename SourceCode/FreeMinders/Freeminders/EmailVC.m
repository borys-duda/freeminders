//
//  EmailVC.m
//  Freeminders
//
//  Created by Vegunta's on 05/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "EmailVC.h"
#import "UserContact.h"
#import "UserData.h"
#import "StoreHelper.h"
#import "StoreItem.h"
#import "UserPurchase.h"
#import "Utils.h"

@interface EmailVC ()

@property  (weak,nonatomic) IBOutlet UITableView  *tableview;
@property (weak, nonatomic) IBOutlet UITextField *firstEmailAddressTitleField;
@property (weak, nonatomic) IBOutlet UITextField *secondEmailAddressTitleField;
@property (weak, nonatomic) IBOutlet UITextField *thirdEmailAddressTitleField;
@property (weak, nonatomic) IBOutlet UITextField *firstEmailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondEmailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdEmailAddressTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *firstDefaultYesAreNoSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *secondDefaultYesAreNoSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *thirdDefaultYesAreNoSwitch;
@property (weak,nonatomic) IBOutlet UIButton *notPurchasedButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelbutton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (nonatomic)   BOOL  firstEmailidvalue;
@property (nonatomic)   BOOL  secondEmailidvalue;
@property (nonatomic)   BOOL  thirdEmailidvalue;

@property (strong, nonatomic) NSString *FirstdefaultValue;
@property (strong, nonatomic) NSString *seconddefaultvalue;
@property (strong, nonatomic) NSString *thirddefaultvalue;


@property (strong,nonatomic) UserContact *firstuserContact;
@property (strong,nonatomic) UserContact *seconduserContact;
@property (strong,nonatomic) UserContact *thirduserContact;


@property (nonatomic) int indexForEmailSaving;

@end

@implementation EmailVC
@synthesize isFromNotificationScreen;

NSMutableArray  *emails;

BOOL isPurchased;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstDefaultYesAreNoSwitch.selectedSegmentIndex = self.secondDefaultYesAreNoSwitch.selectedSegmentIndex = self.thirdDefaultYesAreNoSwitch.selectedSegmentIndex = 1;
    
//    [self performLoadUserContacts];
    
    isPurchased = [[[PFUser currentUser] objectForKey:@"hasUnlimitedEmail"] boolValue];
    self.title = isPurchased?@"Email Settings":@"Email Feature";
    [self.cancelbutton setTitle: isPurchased?@"Cancel":@"Back" forState:UIControlStateNormal] ;
    self.saveButton.hidden = !isPurchased;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self defaultValuesForControlSwithes];
    
    [self  setUpUI];
    
    NSMutableAttributedString *titleStringforfreminders = [[NSMutableAttributedString alloc] initWithString:@"Not Purchased"];
    
    // making text property to underline text-
    [titleStringforfreminders addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleStringforfreminders length])];
    
    // making color vhnage for the sting title
    
    [titleStringforfreminders addAttribute:NSForegroundColorAttributeName value:COLOR_FREEMINDER_BLUE range:NSMakeRange(0, [titleStringforfreminders length])];
    
    // using text on button
    [self.notPurchasedButton setAttributedTitle: titleStringforfreminders forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
    if (!isPurchased) {
        [self performLoadSubscriptions];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedNotification object:nil];
    }
}

-(void)performLoadSubscriptions
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:[StoreItem parseClassName]];
    [query whereKey:@"isEnabled" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"itemType" equalTo:[NSNumber numberWithInt:typeEmailSubscription]];
    [query setLimit:1000];
    [query orderBySortDescriptors:[NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES], nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"STORE GROUPS LOADED");
        //        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[UserData instance] setStoreGroupsByLetter:objects];
        [self performLoadItunesProducts];
        [self.tableView reloadData];
    }];
    
}
- (void)performLoadItunesProducts
{
    [[StoreHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [UserData instance].itunesProducts = products;
            NSLog(@"Email Subscriptions: %@",products);
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpUI];

}
-(void)setUpUI
{
    self.amountLabel.layer.borderWidth = 1.0f;
    self.amountLabel.layer.borderColor = [self.amountLabel.tintColor CGColor];
    self.amountLabel.layer.cornerRadius = 10;
    [self.cancelbutton setTitle: isPurchased?@"Cancel":@"Back" forState:UIControlStateNormal] ;

    
    UIToolbar *Toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(toolBarDone)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self action:@selector(toolBarCancelled)];
    [Toolbar setItems:[NSArray arrayWithObjects:cancelButton, spaceItem, doneButton, nil] animated:NO];
    
    self.firstEmailAddressTextField.inputAccessoryView=Toolbar;
    self.secondEmailAddressTextField.inputAccessoryView=Toolbar;
    self.thirdEmailAddressTextField.inputAccessoryView=Toolbar;
    
    self.firstEmailAddressTitleField.inputAccessoryView=Toolbar;
    self.secondEmailAddressTitleField.inputAccessoryView=Toolbar;
    self.thirdEmailAddressTitleField.inputAccessoryView=Toolbar;
    
    for (int i=0; i< [[UserData instance].userContacts count]; i++) {
        
        UserContact *contact = [[UserData instance].userContacts objectAtIndex:i];
        switch (i) {
            case 0:
                self.firstEmailAddressTitleField.text = contact.name;
                self.firstEmailAddressTextField.text=contact.email;
                self.firstDefaultYesAreNoSwitch.selectedSegmentIndex=contact.defaultBool?0:1;
                break;
            case 1:
                self.secondEmailAddressTitleField.text = contact.name;
                self.secondEmailAddressTextField.text= contact.email;
                self.secondDefaultYesAreNoSwitch.selectedSegmentIndex=contact.defaultBool?0:1;
                break;
            case 2:
                self.thirdEmailAddressTitleField.text = contact.name;
                self.thirdEmailAddressTextField.text=contact.email;
                self.thirdDefaultYesAreNoSwitch.selectedSegmentIndex=contact.defaultBool?0:1;
                break;
            default:
                break;
        }
        
    }
    
}
-(void)toolBarDone
{
     [self hideKeyBoard];
}
-(void)toolBarCancelled
{
    if([self.firstEmailAddressTitleField isEditing])
    {
        self.firstEmailAddressTitleField.text=((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).name;
        
    }else if ([self.secondEmailAddressTitleField isEditing]){
        
        self.secondEmailAddressTitleField.text=((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).name;
        
    }else if ([self.thirdEmailAddressTitleField isEditing])
    {
        self.thirdEmailAddressTitleField.text=((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).name;
        
    }else if ( [self.firstEmailAddressTextField isEditing])
    {
        self.firstEmailAddressTextField.text=((UserContact *)([[UserData instance].userContacts objectAtIndex:0])).email;
        
    }else if([self.secondEmailAddressTextField isEditing])
    {
        self.secondEmailAddressTextField.text=((UserContact *)([[UserData instance].userContacts objectAtIndex:1])).email;
        
    }else if ([self.thirdEmailAddressTextField isEditing])
    {
        self.thirdEmailAddressTextField.text=((UserContact *)([[UserData instance].userContacts objectAtIndex:2])).email;
        
    }
    [self hideKeyBoard];
}
-(void)hideKeyBoard
{
    [self.firstEmailAddressTextField resignFirstResponder];
    [self.secondEmailAddressTextField resignFirstResponder];
    [self.thirdEmailAddressTextField resignFirstResponder];
    
    [self.firstEmailAddressTitleField resignFirstResponder];
    [self.secondEmailAddressTitleField resignFirstResponder];
    [self.thirdEmailAddressTitleField resignFirstResponder];
}
-(void)performLoadUserContacts
{
    PFQuery *query = [PFQuery queryWithClassName:[UserContact parseClassName]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"UserConatcts LOADED");
        if ([objects.firstObject isKindOfClass:[UserContact class]])
            [UserData instance].userContacts = [objects mutableCopy];
    }];
    NSLog(@"number of objects are %lu",(unsigned long)[UserData instance].userContacts.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)defaultValuesForControlSwithes
{
    self.FirstdefaultValue = [self.firstDefaultYesAreNoSwitch titleForSegmentAtIndex:self.firstDefaultYesAreNoSwitch.selectedSegmentIndex];
    self.seconddefaultvalue =[self.secondDefaultYesAreNoSwitch titleForSegmentAtIndex:self.secondDefaultYesAreNoSwitch.selectedSegmentIndex];
    self.thirddefaultvalue =[self.thirdDefaultYesAreNoSwitch titleForSegmentAtIndex:self.thirdDefaultYesAreNoSwitch.selectedSegmentIndex];
}
- (IBAction)cancelButtonPressed
{
    [self deregisterForNotifications];
    if(self.isFromNotificationScreen)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonPressed
{
    NSString *firstEmailId = self.firstEmailAddressTextField.text;
    NSString *secondEmailId = self.secondEmailAddressTextField.text;
    NSString *thirdEmailId = self.thirdEmailAddressTextField.text;
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    self.firstEmailidvalue  =[emailTest evaluateWithObject:firstEmailId];
    self.secondEmailidvalue  =[emailTest evaluateWithObject:secondEmailId];
    self.thirdEmailidvalue  = [emailTest evaluateWithObject:thirdEmailId];
    
    
    if((self.firstEmailAddressTextField.text.length > 0) && !(self.firstEmailidvalue))
    {
        [self  alertForTheEmails:@"First"];
    }else if ((self.secondEmailAddressTextField.text.length > 0) &&!(self.secondEmailidvalue))
    {
        [self  alertForTheEmails:@"Second"];
    }else if((self.thirdEmailAddressTextField.text.length > 0) &&!(self.thirdEmailidvalue))
    {
        [self  alertForTheEmails:@"Third"];
    }else {
        BOOL firstDefaultBool,secondDefaultBool,thirdDefaultBool;
        firstDefaultBool = self.firstDefaultYesAreNoSwitch.selectedSegmentIndex? NO : YES;
        secondDefaultBool = self.secondDefaultYesAreNoSwitch.selectedSegmentIndex? NO : YES;
        thirdDefaultBool = self.thirdDefaultYesAreNoSwitch.selectedSegmentIndex? NO : YES;
        for(int i=0;i < 3; i++)
        {
            if([UserData instance].userContacts.count == 3)
            {
                UserContact *contact = [[UserData instance].userContacts objectAtIndex:i];
                contact.user = [PFUser currentUser];
                switch (i) {
                    case 0:
                        contact.name = self.firstEmailAddressTitleField.text;
                        contact.email=self.firstEmailAddressTextField.text;
                        contact.defaultBool=firstDefaultBool;
                        break;
                    case 1:
                        contact.name = self.secondEmailAddressTitleField.text;
                        contact.email=self.secondEmailAddressTextField.text;
                        contact.defaultBool=secondDefaultBool;
                        break;
                    case 2:
                        contact.name = self.thirdEmailAddressTitleField.text;
                        contact.email=self.thirdEmailAddressTextField.text;
                        contact.defaultBool=thirdDefaultBool;
                        break;
                    default:
                        break;
                }
                [[UserData instance].userContacts replaceObjectAtIndex:i withObject:contact];
            }else{
                UserContact *contact = [[UserContact alloc] init];
                contact.user = [PFUser currentUser];
                switch (i) {
                    case 0:
                        contact.name = self.firstEmailAddressTitleField.text;
                        contact.email=self.firstEmailAddressTextField.text;
                        contact.defaultBool=firstDefaultBool;
                        [[UserData instance].userContacts addObject:contact];
                        break;
                        
                    case 1:
                        contact.name = self.secondEmailAddressTitleField.text;
                        contact.email=self.secondEmailAddressTextField.text;
                        contact.defaultBool=secondDefaultBool;
                        [[UserData instance].userContacts addObject:contact];
                        break;
                        
                    case 2:
                        contact.name = self.thirdEmailAddressTitleField.text;
                        contact.email=self.thirdEmailAddressTextField.text;
                        contact.defaultBool=thirdDefaultBool;
                        [[UserData instance].userContacts addObject:contact];
                        break;
                        
                    default:
                        
                        break;
                }
            }
        }
        NSLog(@"emails are %@",[UserData instance].userContacts);
        [self performSaveContacts];
    }
    
}
-(void)performSaveContacts
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFObject saveAllInBackground:[UserData instance].userContacts block:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!succeeded) {
            [Utils showSimpleAlertViewWithTitle:@"Error" content:@"An error occured while saving your contacts" andDelegate:nil];
        }else {
            if(self.isFromNotificationScreen)
                [self.navigationController popViewControllerAnimated:YES];
            else
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
}
-(void)alertForTheEmails:(NSString *)string
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:[NSString stringWithFormat:@"%@ Email Address is invalid",string]
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!isPurchased)
    {
        if(section==9)
        {
            return 3;
        }
    }
    else
        if(section==9)
        {
            return 0;
        }
        else
            return 1;
    
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(!isPurchased)
    {
        return 0;
    }
    else
    {
        return 15;
    }
}


- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    // NSInteger row = indexPath.row;
    if(!isPurchased)
    {
        if(section==9)
        {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 9 && indexPath.row == 2) {
        
        [self purchaseMinderGroup:0];
    
    }
    
}

- (IBAction)detailsStepsSwitchChanged:(UISegmentedControl *)sender
{
    self.FirstdefaultValue = [self.firstDefaultYesAreNoSwitch titleForSegmentAtIndex:self.firstDefaultYesAreNoSwitch.selectedSegmentIndex];
    self.seconddefaultvalue =[self.secondDefaultYesAreNoSwitch titleForSegmentAtIndex:self.secondDefaultYesAreNoSwitch.selectedSegmentIndex];
    self.thirddefaultvalue =[self.thirdDefaultYesAreNoSwitch titleForSegmentAtIndex:self.thirdDefaultYesAreNoSwitch.selectedSegmentIndex];
    
}

- (IBAction)lifeTimePurchaseAction:(UIButton *)sender
{
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"hasUnlimitedEmail"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error saving user : %@",error);
            self.title = @"Email Settings";
            [self.cancelbutton setTitle: isPurchased?@"Cancel":@"Back" forState:UIControlStateNormal] ;
            self.saveButton.hidden = !isPurchased;
        }
    }];
}

#pragma mark- UITextField delegate methods

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}
// This method is called once we click inside the textField
-(void)textFieldDidBeginEditing:(UITextField *)textField{
  
    if( textField == self.secondEmailAddressTextField || textField == self.secondEmailAddressTitleField)
        [self.tableView setContentOffset:CGPointMake(0, 140) animated:YES];
    else if( textField == self.thirdEmailAddressTextField || textField == self.thirdEmailAddressTitleField)
        [self.tableView setContentOffset:CGPointMake(0, 300) animated:YES];
    
       NSLog(@"Text field did begin editing");
}

// This method is called once we complete editing
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if( textField == self.secondEmailAddressTextField || textField == self.secondEmailAddressTitleField)
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    else if( textField == self.thirdEmailAddressTextField || textField == self.thirdEmailAddressTitleField)
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

// This method enables or disables the processing of return key
//-(BOOL) textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return YES;
//}


#pragma mark- Purchase handlers

- (void)purchaseMinderGroup:(int)index
{
    NSLog(@"%@",[[UserData instance].storeGroupsArray objectAtIndex:index]);
    [UserData instance].storeGroup = [[UserData instance].storeGroupsArray objectAtIndex:index];
    /*   if ([[StoreHelper sharedInstance] isProductPurchased:[UserData instance].storeGroup.objectId]) {
     [Utils addTasksFromStoreGroup];
     [Utils showSimpleAlertViewWithTitle:@"Tasks Added" content:[NSString stringWithFormat:@"The tasks from %@ have been added to your task list", [UserData instance].storeGroup.name] andDelegate:nil];
     } else {*/
    for (SKProduct *product in [UserData instance].itunesProducts) {
        if ([product.productIdentifier isEqualToString:[UserData instance].storeGroup.objectId]) {
            
            [[StoreHelper sharedInstance] buyProduct:product];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            return; // in case 2 products with same id, don't try to buy both
            // (but that should never happen)
        }
    }
    //    }
}

- (void)productPurchased:(NSNotification *)notification
{
    NSLog(@"PURCHASED PRODUCT LOADED : %@",notification.userInfo);
    NSDictionary *purchase = notification.userInfo;
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    UserPurchase *newPurchase = [[UserPurchase alloc] init];
    newPurchase.user = [PFUser currentUser];
    newPurchase.storeItemId = [purchase objectForKey:@"storeItemId"];
    newPurchase.receiptId = [purchase objectForKey:@"receiptId"];
    newPurchase.storeItem = [UserData instance].storeGroup;
    newPurchase.amountPaid = [UserData instance].storeGroup.salePrice;
    newPurchase.itemType = [NSNumber numberWithInt:typeEmailSubscription];
    newPurchase.lastTransactionDate = [purchase objectForKey:@"lastTransactionDate"];
    [newPurchase saveEventually:^(BOOL succeeded, NSError *error) {
        NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
        [prevPurchases addObject:newPurchase];
        [UserData instance].userPurchases = [prevPurchases mutableCopy];
    }];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"hasUnlimitedEmail"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error saving user : %@",error);
        }else {
            self.title = @"Email Settings";
            isPurchased = [[[PFUser currentUser] objectForKey:@"hasUnlimitedEmail"] boolValue];
            [self.cancelbutton setTitle: isPurchased?@"Cancel":@"Back" forState:UIControlStateNormal] ;
            self.saveButton.hidden = !isPurchased;
            [self.tableView reloadData];
        }
    }];
}

- (void)productFailed:(NSNotification *)notification
{
    [Utils showSimpleAlertViewWithTitle:notification.userInfo[@"title"] content:notification.userInfo[@"message"] andDelegate:nil];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)deregisterForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    [center removeObserver:self name:IAPHelperProductFailedNotification object:nil];
}

@end
