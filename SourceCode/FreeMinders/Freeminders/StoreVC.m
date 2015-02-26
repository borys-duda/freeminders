//
//  StoreVC.m
//  Freeminders
//
//  Created by Spencer Morris on 5/20/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "StoreVC.h"
#import "UserData.h"
#import "Utils.h"
#import "StoreGroupCell.h"
#import "StoreItem.h"
#import "UserPurchase.h"
#import "StoreHelper.h"
#import <StoreKit/StoreKit.h>
#import "DataManager.h"
#import "UserManager.h"

@interface StoreVC ()
@property (strong,nonatomic)  UIView *actionMenu;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredGroupArray;

@end

@implementation StoreVC
@synthesize isFromMyGroupsScreen;

NSString *SEGUE_VIEW_STORE_GROUP = @"viewStoreGroup",*SEGU_EMAIL_SEREEN=@"emailScreen",*SEGU_SUBSCRIPTION_SEREEN=@"subscriptionScreen";
;
bool isPurchased;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UserData instance] setStoreGroupsByLetter:nil];
   // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,70)];
    [UserData instance].purchaseInProgress = NO;
    //    [self performLoadStoreGroups];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self performLoadStoreGroups];
    [self setUpUiActionMenu];
    [self deregisterForNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFailed:) name:IAPHelperProductFailedNotification object:nil];
    if(isPurchased)
    {
        [_actionMenu removeFromSuperview];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
     [_actionMenu removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)setUpUiActionMenu
{
    self.actionMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 70)];
    self.actionMenu.backgroundColor = [UIColor whiteColor];
    
  CGRect rect = CGRectMake(0, 24, 60, 35);
    CGPoint center;
    
    isPurchased = [[[PFUser currentUser] objectForKey:@"hasUnlimitedEmail"] boolValue];
    UILabel *groupResetLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 220, 15)];
    groupResetLabel.text=@"ADD ON ACCOUNT FEATURES";
    groupResetLabel.font=[UIFont systemFontOfSize:14];
    groupResetLabel.textColor=[UIColor blackColor];
    [self.actionMenu addSubview:groupResetLabel];
    
    if(!isPurchased)
    {
        UIButton *emailButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 24, 320, 35)];       //CGRectMake(0, 24, 158, 35)];

        rect = CGRectMake(0, 24, 120, 35);
        center = emailButton.center;
        emailButton.frame = rect;
        emailButton.center = center;
        emailButton.layer.borderWidth = 1.0f;
        emailButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
        emailButton.layer.cornerRadius = 10;
        [emailButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [emailButton setTitle:@"Email" forState:UIControlStateNormal];
        [emailButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
        [emailButton addTarget:self action:@selector(emailFeatureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionMenu addSubview:emailButton];
        
        UIButton *subscriptionButton =[[UIButton alloc]initWithFrame:CGRectMake(160, 24, 158, 35)];
        rect = CGRectMake(160, 24, 120, 35);
        center = subscriptionButton.center;
        subscriptionButton.frame = rect;
        subscriptionButton.center = center;
        subscriptionButton.layer.borderWidth = 1.0f;
        subscriptionButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
        subscriptionButton.layer.cornerRadius = 10;
        [subscriptionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [subscriptionButton setTitle:@"Subscription" forState:UIControlStateNormal];
        [subscriptionButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
        [subscriptionButton addTarget:self action:@selector(subscriptionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.actionMenu addSubview:subscriptionButton];
        [subscriptionButton setHidden:YES];

   }else{
       
        UIButton *subscriptionButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 24, 320, 35)];
        rect = CGRectMake(0, 24, 120, 35);
        center = subscriptionButton.center;
        subscriptionButton.frame = rect;
        subscriptionButton.center = center;
        subscriptionButton.layer.borderWidth = 1.0f;
        subscriptionButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
        subscriptionButton.layer.cornerRadius = 10;
        [subscriptionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [subscriptionButton setTitle:@"Subscription" forState:UIControlStateNormal];
        [subscriptionButton setTitleColor:COLOR_FREEMINDER_BLUE forState:UIControlStateNormal];
        [subscriptionButton addTarget:self action:@selector(subscriptionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionMenu addSubview:subscriptionButton];
       [subscriptionButton setHidden:YES];

    }
    
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect actionmenurect = _actionMenu.frame;
    actionmenurect.origin.y = mainWindow.frame.size.height - actionmenurect.size.height;
    _actionMenu.frame = actionmenurect;
    [mainWindow addSubview: _actionMenu];
    NSLog(@"FRAME : %@",NSStringFromCGRect(mainWindow.frame));
    NSLog(@"FRAME : %@",NSStringFromCGRect(self.view.frame));
    
}
-(void)emailFeatureButtonAction:(UIButton *)sender
{
     sender.selected=!sender.selected;
    [self performSegueWithIdentifier:SEGU_EMAIL_SEREEN sender:self];
}
-(void)subscriptionButtonAction:(UIButton *)sender
{
    sender.selected=YES;
    [[UserData instance] setStoreGroupsByLetter:nil];
    [self performSegueWithIdentifier:SEGU_SUBSCRIPTION_SEREEN sender:self];

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
    [self.tableView reloadData];
}

- (void)productFailed:(NSNotification *)notification
{
    [Utils showSimpleAlertViewWithTitle:notification.userInfo[@"title"] content:notification.userInfo[@"message"] andDelegate:nil];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)purchaseMinderGroup
{
    if ([[StoreHelper sharedInstance] isProductPurchased:[UserData instance].storeGroup.objectId]) {
        //        [Utils addTasksFromStoreGroup];
        //        [Utils showSimpleAlertViewWithTitle:@"Tasks Added" content:[NSString stringWithFormat:@"The tasks from %@ have been added to your task list", [UserData instance].storeGroup.name] andDelegate:nil];
        if ([Utils didGroupExist:[UserData instance].storeGroup.objectId]) {
            [Utils showSimpleAlertViewWithTitle:@"Duplicate Group" content:[NSString stringWithFormat:@"The group %@ is already downloaded.", [UserData instance].storeGroup.name] andDelegate:nil];
        }else{
            [Utils addTasksFromStoreGroup:self.view];
//            [Utils showSimpleAlertViewWithTitle:@"Reminder Group Added" content:[NSString stringWithFormat:@"The %@ has been successfully added to your account.",[UserData instance].storeGroup.name ]andDelegate:self];
        }
        
    } else if([UserData instance].isHavingActiveSubscription){
        NSMutableDictionary *purchaseInfo = [[NSMutableDictionary alloc] init];
        [purchaseInfo setValue:[UserData instance].storeGroup.objectId forKey:@"storeItemId"];
        [purchaseInfo setValue:[NSDate date] forKey:@"lastTransactionDate"];
        [[StoreHelper sharedInstance] provideContentForProductIdentifier:purchaseInfo];
//        [Utils showSimpleAlertViewWithTitle:@"Reminder Group Added" content:[NSString stringWithFormat:@"The %@ is being downloaded. Please allow up to 5 minutes for integration into your account.",[UserData instance].storeGroup.name ]andDelegate:self];
    }else {
        for (SKProduct *product in [UserData instance].itunesProducts) {
            if ([product.productIdentifier isEqualToString:[UserData instance].storeGroup.objectId]) {
                
                [[StoreHelper sharedInstance] buyProduct:product];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                return; // in case 2 products with same id, don't try to buy both
                // (but that should never happen)
            }
        }
    }
}

#pragma mark- SearchBar methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.name contains[c] %@) OR (SELF.description contains[c] %@)", searchText, searchText];
    self.filteredGroupArray = [[UserData instance].storeGroupsArray filteredArrayUsingPredicate:predicate];
}

#pragma mark- UITableView methods 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [UserData instance].storeGroupsByLetter.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredGroupArray.count;
    } else {
        return [self groupArrayAtSection:section].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CELL_IDENTIFIER = @"storeGroupCell";
    
    StoreGroupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil)
        cell = [[StoreGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = YES;
    
    cell.priceButton.layer.cornerRadius = 10.0f;
    cell.priceButton.layer.borderColor = [COLOR_FREEMINDER_BLUE CGColor];
    cell.priceButton.layer.borderWidth = 1.0f;
    
    StoreItem *storeGroup;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        storeGroup = [self.filteredGroupArray objectAtIndex:indexPath.row];
    } else {
        NSArray *storeGroups = [self groupArrayAtSection:indexPath.section];
        storeGroup = [storeGroups objectAtIndex:indexPath.row];
    }
    
    cell.titleLabel.text = storeGroup.name;
    cell.detailsLabel.text = [NSString stringWithFormat:@"%i Reminders + %i Steps + %i Triggers \n", (int)((ReminderGroup *)[storeGroup.reminderGroups objectAtIndex:0]).reminders.count, [storeGroup numberOfSteps], [storeGroup numberOfTriggers]];
    
    if ([storeGroup isPurchased] || [UserData instance].isHavingActiveSubscription) {
        [cell.priceButton setTitle:@"Add" forState:UIControlStateNormal];
    } else {
        [cell.priceButton setTitle:[NSString stringWithFormat:@"$%.02f", storeGroup.price.floatValue] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    } else {
        StoreItem *group = [self groupArrayAtSection:section].firstObject;
        
        if (group.name.length > 0)
            return [group.name substringToIndex:1];
        else
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0.0;
    } else {
        return 20.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deregisterForNotifications];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [UserData instance].storeGroup = [self.filteredGroupArray objectAtIndex:indexPath.row];
    } else {
        NSArray *storeGroups = [self groupArrayAtSection:indexPath.section];
        [UserData instance].storeGroup = [storeGroups objectAtIndex:indexPath.row];
    }
    
    [self.searchBar endEditing:YES];
}

- (NSArray *)groupArrayAtSection:(NSInteger)section
{
    NSMutableArray *arrayKeys = [[[UserData instance].storeGroupsByLetter allKeys] mutableCopy];
    [arrayKeys sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    return [[UserData instance].storeGroupsByLetter objectForKey:[arrayKeys objectAtIndex:section]];
}

#pragma mark- Actions

- (IBAction)priceButtonPressed:(UIButton *)button
{
    for (int i = 0; i < [self.tableView numberOfSections]; i++) {
        for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
            StoreGroupCell *cell = (StoreGroupCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            if (button == cell.priceButton) {
                NSLog(@"BUTTON FOUND");
                NSArray *storeGroups = [self groupArrayAtSection:i];
                [UserData instance].storeGroup = [storeGroups objectAtIndex:j];
                [self purchaseMinderGroup];
                
                return;
            }
        }
    }
    
    for (StoreGroupCell *cell in [self.searchDisplayController.searchResultsTableView visibleCells]) {
        if (button == cell.priceButton) {
            NSLog(@"BUTTON FOUND");
            [UserData instance].storeGroup = [self.filteredGroupArray objectAtIndex:[self.searchDisplayController.searchResultsTableView indexPathForCell:cell].row];
            [self purchaseMinderGroup];
            
            return;
        }
    }
}

- (IBAction)cancelButtonPressed
{
//    if ([Utils isModal:self]) {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    if ([UserData instance].purchaseInProgress) {
        return;
    }
    if (isFromMyGroupsScreen)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    }
    
}

#pragma mark- Networking

- (void)performLoadStoreGroups
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DataManager sharedInstance] loadStoreGroupsWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"STORE GROUPS LOADED");
        [[UserData instance] setStoreGroupsByLetter:objects];
        //        [self performLoadStoreTasks];
        [self.tableView reloadData];
        [self performLoadItunesProducts];
    }];
}

- (void)performLoadStoreTasks
{
    [[DataManager sharedInstance] loadStoreTasksWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"STORE TASKS LOADED");
        [self performLoadItunesProducts];
        [UserData instance].storeTasks = objects;
        [self.tableView reloadData];

    }];
}

- (void)performLoadItunesProducts
{
    [[StoreHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            [UserData instance].itunesProducts = products;
            [[StoreHelper sharedInstance] setPurchasedProducts];
            // Check that every purchase has an object in Parse database
            for (SKProduct *product in products) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:product.productIdentifier]) {
                    BOOL found = NO;
                    
                    for (UserPurchase *purchase in [UserData instance].userPurchases) {
                        if ([purchase.storeItemId isEqualToString:product.productIdentifier]){
                            found = YES;
                        }
                    }
                    
                    if (!found) {
//                        PFQuery *query = [PFQuery queryWithClassName:[UserPurchase parseClassName]];
//                        [query whereKey:@"storeItemId" equalTo:product.productIdentifier];
//                        [query whereKey:@"user" equalTo:[PFUser currentUser]];
//                        if ([query countObjects] == 0) {
//                            UserPurchase *purchase = [[UserPurchase alloc] init];
//                            purchase.user = [PFUser currentUser];
//                            purchase.storeItemId = product.productIdentifier;
//                            [purchase saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                                NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
//                                [prevPurchases addObject:purchase];
//                                [UserData instance].userPurchases = [prevPurchases mutableCopy];
//                            }];
//                        }
                        UserPurchase *purchase = [[UserPurchase alloc] init];
                        purchase.user = [PFUser currentUser];
                        purchase.storeItemId = product.productIdentifier;
                        [[DataManager sharedInstance] checkUserPurchasedWithProductId:product.productIdentifier withObject:purchase withBlock:^(BOOL succeeded, NSError *error) {
                            NSMutableArray *prevPurchases = [[UserData instance].userPurchases mutableCopy];
                            [prevPurchases addObject:purchase];
                            [UserData instance].userPurchases = [prevPurchases mutableCopy];
                        }];
                        
                    }
                }else{
                    
                }
            }
        }else{
            [Utils showSimpleAlertViewWithTitle:@"Failed" content:@"Can't connect to the iTunes Store now." andDelegate:nil];
        }
        [self.tableView reloadData];
    }];
}

- (void)deregisterForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    [center removeObserver:self name:IAPHelperProductFailedNotification object:nil];
}


#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
