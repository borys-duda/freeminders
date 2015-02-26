//
//  SubscriptionTVC.m
//  Freeminders
//
//  Created by Vegunta's on 15/10/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "SubscriptionTVC.h"
#import "BorderedButton.h"
#import "SubscriptionCell.h"
#import "StoreHelper.h"
#import "StoreItem.h"
#import "UserPurchase.h"
#import "Utils.h"
#import "StoreGroupCell.h"
#import "DataManager.h"

@interface SubscriptionTVC ()

@property (weak,nonatomic) IBOutlet UIButton *activeSubsriptionButton;
@property (weak,nonatomic) IBOutlet UILabel *expriesNameLabel;
@property (weak,nonatomic) IBOutlet UILabel *expriesDataLabel;
//@property (weak,nonatomic) IBOutlet UILabel *oneMonthLabel;
//@property (weak,nonatomic) IBOutlet UILabel *threeMonthLabel;
//@property (weak,nonatomic) IBOutlet UILabel *sixMonthLabel;
//@property (weak,nonatomic) IBOutlet UILabel *tweleMonthLabel;
//@property (weak,nonatomic) IBOutlet UIButton *oneMonthButton;
//@property (weak,nonatomic) IBOutlet UIButton *threeMonthButton;
//@property (weak,nonatomic) IBOutlet UIButton *sixMonthButton;
//@property (weak,nonatomic) IBOutlet UIButton *tweleMonthButton;

@end

@implementation SubscriptionTVC

bool isActiveSubscriptionEnabled;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isActiveSubscriptionEnabled = [[UserData instance] isHavingActiveSubscription];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self performLoadSubscripions];
    [self setUpUi];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedNotification object:nil];
}

-(void)performLoadSubscripions
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] loadSubscriptionWithBlock:^(NSArray *objects, NSError *error) {
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
            NSLog(@"Subsriptions : %@",products);
            // Check that every purchase has an object in Parse database
            /*            for (SKProduct *product in products) {
             if ([[NSUserDefaults standardUserDefaults] boolForKey:product.productIdentifier]) {
             BOOL found = NO;
             
             for (UserPurchase *purchase in [UserData instance].userPurchases) {
             if ([purchase.storeItemId isEqualToString:product.productIdentifier])
             found = YES;
             }
             
             if (! found) {
             PFQuery *query = [PFQuery queryWithClassName:[UserPurchase parseClassName]];
             [query whereKey:@"storeItemId" equalTo:product.productIdentifier];
             [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
             if ([query countObjects] == 0) {
             UserPurchase *purchase = [[UserPurchase alloc] init];
             purchase.userId = [PFUser currentUser].objectId;
             purchase.storeItemId = product.productIdentifier;
             [purchase saveInBackground];
             }
             }
             }
             }*/
        }
    }];
}

-(void)setUpUi
{
    if(!isActiveSubscriptionEnabled)
    {
        self.expriesDataLabel.hidden=YES;
        self.expriesNameLabel.hidden=YES;
        NSMutableAttributedString *titleStringForHelp = [[NSMutableAttributedString alloc] initWithString:@"No Currently Active Subscription"];
        [titleStringForHelp addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleStringForHelp length])];
        [titleStringForHelp addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]range:NSMakeRange(0, [titleStringForHelp length])];
        [self.activeSubsriptionButton setAttributedTitle:titleStringForHelp forState:UIControlStateNormal];
//        self.oneMonthLabel.text=@"1 Month Subscription";
//        self.threeMonthLabel.text=@"3 Month Subscription";
//        self.sixMonthLabel.text=@"6 Month Subscription";
//        self.tweleMonthLabel.text=@"12 Month Subscription";
    }
    else{
        self.expriesDataLabel.hidden=NO;
        self.expriesNameLabel.hidden=NO;
        NSMutableAttributedString *titleStringForHelp = [[NSMutableAttributedString alloc] initWithString:@"Active Subscription"];
        [titleStringForHelp addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleStringForHelp length])];
        [titleStringForHelp addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]range:NSMakeRange(0, [titleStringForHelp length])];
        [self.activeSubsriptionButton setAttributedTitle:titleStringForHelp forState:UIControlStateNormal];
         self.activeSubsriptionButton.titleLabel.textAlignment=NSTextAlignmentCenter;
//        self.oneMonthLabel.text=@"1 Month Extension";
//        self.threeMonthLabel.text=@"3 Month Extension";
//        self.sixMonthLabel.text=@"6 Month Extension";
//        self.tweleMonthLabel.text=@"12 Month Extension";
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        self.expriesDataLabel.text = [dateFormat stringFromDate:[UserData instance].userSubscription.expireDate];
    }
  
}
- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
        
    }else if(section == 1){
        
        return [UserData instance].storeGroupsArray.count;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==  1) {
        
        return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    else{
         return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        
    }
    if(indexPath.section==0)
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    static NSString *CELL_IDENTIFIER = nil;//@"SubscriptionCell";
     SubscriptionCell *subscriptionCell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER ];
    
    if (subscriptionCell == nil)
        subscriptionCell = [[SubscriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    
    if(indexPath.section==1)
    {
        NSSortDescriptor *sortDisc = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
        NSArray *subscriptions = [[UserData instance].storeGroupsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDisc, nil]];
        ((StoreItem *)[subscriptions objectAtIndex:indexPath.row]).reminderGroups = [NSNull null];
            subscriptionCell.textLabel.text=((StoreItem *)[subscriptions objectAtIndex:indexPath.row]).name;
//            subscriptionCell.amountButton.titleLabel.text=@"4.99";
/*            UIButton *amountButton = [UIButton buttonWithType:UIButtonTypeCustom];
            //		[disagreeButton setBackgroundImage:[UIImage imageNamed:@"agreementButton.png"] forState:UIControlStateNormal];
            [amountButton setTitle:[NSString stringWithFormat:@"$%.02f", ((StoreItem *)[[UserData instance].storeGroupsArray objectAtIndex:indexPath.row]).price.floatValue] forState:UIControlStateNormal];;
            amountButton.frame=CGRectMake(250, 7, 60,30);
            amountButton.tintColor=COLOR_FREEMINDER_BLUE;
            amountButton.layer.borderWidth = 1.0f;
            amountButton.layer.borderColor = [amountButton.tintColor CGColor];
            amountButton.layer.cornerRadius = 10;
            [amountButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
            [amountButton setBackgroundColor:[UIColor whiteColor]];
            [subscriptionCell addSubview:amountButton];*/
        subscriptionCell.selectionStyle = UITableViewCellSelectionStyleNone;
        subscriptionCell.userInteractionEnabled = YES;
        UIButton *priceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        priceButton.frame = CGRectMake(250, 10, 65, 30);
        priceButton.layer.cornerRadius = 10.0f;
        priceButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
        priceButton.layer.borderWidth = 1.0f;
        [priceButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
        priceButton.userInteractionEnabled = NO;
        cell.textLabel.text = ((StoreItem *)[subscriptions objectAtIndex:indexPath.row]).name;
        NSLog(@"%@",[NSString stringWithFormat:@"$%.02f", ((StoreItem *)[subscriptions objectAtIndex:indexPath.row]).price.floatValue]);
        [priceButton setTitle:[NSString stringWithFormat:@"$%.02f", ((StoreItem *)[subscriptions objectAtIndex:indexPath.row]).price.floatValue] forState:UIControlStateNormal];
        [subscriptionCell.contentView addSubview:priceButton];

            return subscriptionCell;
    }
   
    return nil;
    
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == 1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        [self purchaseMinderGroup:indexPath.row];
    }
}

#pragma mark- Purchase handlers

- (void)purchaseMinderGroup:(int)index
{
    NSLog(@"%@",[UserData instance].storeGroupsArray);
    NSSortDescriptor *sortDisc = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
    NSArray *subscriptions = [[UserData instance].storeGroupsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDisc, nil]];
    [UserData instance].storeGroup = [subscriptions objectAtIndex:index];
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
    [[DataManager sharedInstance] loadUserPurchasedWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count) {
            UserPurchase *previousPuchase = objects.firstObject;
            previousPuchase.storeItemId = [purchase objectForKey:@"storeItemId"];
            previousPuchase.receiptId = [purchase objectForKey:@"receiptId"];
            previousPuchase.storeItem = [UserData instance].storeGroup;
            previousPuchase.amountPaid = [UserData instance].storeGroup.salePrice;
            previousPuchase.lastTransactionDate = [purchase objectForKey:@"lastTransactionDate"];
            if ([previousPuchase.expireDate compare:[purchase objectForKey:@"lastTransactionDate"]] == NSOrderedAscending) {
                // Subscription expired. Subscription in lapse
                previousPuchase.expireDate = [[purchase objectForKey:@"lastTransactionDate"] dateByAddingTimeInterval:SECONDS_PER_DAY*[[UserData instance].storeGroup.validity intValue]];
            }else if ([previousPuchase.expireDate compare:[purchase objectForKey:@"lastTransactionDate"]] == NSOrderedDescending){
                // Subscription still alive
                previousPuchase.expireDate = [previousPuchase.expireDate dateByAddingTimeInterval:SECONDS_PER_DAY*[[UserData instance].storeGroup.validity intValue]];
            }else{
                // Subscription expired
                previousPuchase.expireDate = [previousPuchase.expireDate dateByAddingTimeInterval:SECONDS_PER_DAY*[[UserData instance].storeGroup.validity intValue]];
            }
            [[DataManager sharedInstance] saveToLocalWithObject:previousPuchase];
            [UserData instance].userSubscription = previousPuchase;
            NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
            for (int i=0; i < prevPurchases.count; i++) {
                UserPurchase *purchase = prevPurchases[i];
                if ([purchase.objectId isEqualToString:previousPuchase.objectId]) {
                    [prevPurchases replaceObjectAtIndex:i withObject:previousPuchase];
                }
            }
            [UserData instance].userPurchases = [prevPurchases mutableCopy];
        }else {
            UserPurchase *newPurchase = [[UserPurchase alloc] init];
            newPurchase.user = [PFUser currentUser];
            newPurchase.storeItemId = [purchase objectForKey:@"storeItemId"];
            newPurchase.receiptId = [purchase objectForKey:@"receiptId"];
            newPurchase.storeItem = [UserData instance].storeGroup;
            newPurchase.amountPaid = [UserData instance].storeGroup.salePrice;
            newPurchase.itemType = [NSNumber numberWithInt:typeSubscription];
            newPurchase.lastTransactionDate = [purchase objectForKey:@"lastTransactionDate"];
            newPurchase.expireDate = [[purchase objectForKey:@"lastTransactionDate"] dateByAddingTimeInterval:SECONDS_PER_DAY*[[UserData instance].storeGroup.validity intValue]];
            [[DataManager sharedInstance] saveToLocalWithObject:newPurchase withBlock:^(BOOL succeeded, NSError *error) {
                NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
                [prevPurchases addObject:newPurchase];
                [UserData instance].userPurchases = [prevPurchases mutableCopy];
            }];
            [UserData instance].userSubscription = newPurchase;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[UserData instance].userSubscription.expireDate forKey:@"subscriptionExpireDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isActiveSubscriptionEnabled = YES;
        [self setUpUi];
    }];
}

- (void)productFailed:(NSNotification *)notification
{
    [Utils showSimpleAlertViewWithTitle:notification.userInfo[@"title"] content:notification.userInfo[@"message"] andDelegate:nil];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}



@end
