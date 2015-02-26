//
//  DonateTVC.m
//  Freeminders
//
//  Created by Vegunta's on 27/09/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "DonateTVC.h"
#import "StoreHelper.h"
#import "StoreItem.h"
#import "UserPurchase.h"
#import "Utils.h"
#import "DataManager.h"
#import "UserManager.h"

@interface DonateTVC ()

@property (strong,nonatomic)IBOutlet UITextView *textView;

@end

@implementation DonateTVC

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
    [self performLoadDonations];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedNotification object:nil];
}

-(void)performLoadDonations
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
            NSLog(@"Donations : %@",products);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)cancelButtonPressed
{
    [self deregisterForNotifications];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
    }
    if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
            
            return cell;
            
        }
        else if(indexPath.row==1)
        {
            cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
            
            return cell;
        }
    }
    
    return 0;
}

- (IBAction)donateButtonPressed:(UIButton *)sender {
    if ([UserData instance].storeGroupsArray.count >= sender.tag) {
        [self purchaseMinderGroup:(sender.tag-1)];
    }
}

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
    newPurchase.user = [[UserManager sharedInstance] getCurrentUser];
    newPurchase.storeItemId = [purchase objectForKey:@"storeItemId"];
    newPurchase.receiptId = [purchase objectForKey:@"receiptId"];
    newPurchase.storeItem = [UserData instance].storeGroup;
    newPurchase.amountPaid = [UserData instance].storeGroup.salePrice;
    newPurchase.itemType = [NSNumber numberWithInt:typeDonation];
    newPurchase.lastTransactionDate = [purchase objectForKey:@"lastTransactionDate"];
    //    newPurchase.expireDate = [[purchase objectForKey:@"lastTransactionDate"] dateByAddingTimeInterval:SECONDS_PER_DAY*[[UserData instance].storeGroup.validity intValue]];
    
    [[DataManager sharedInstance] saveToLocalWithObject:newPurchase withBlock:^(BOOL succeeded, NSError *error) {
        NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
        [prevPurchases addObject:newPurchase];
        [UserData instance].userPurchases = [prevPurchases mutableCopy];
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
