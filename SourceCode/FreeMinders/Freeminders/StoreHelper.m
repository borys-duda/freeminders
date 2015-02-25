//
//  StoreHelper.m
//  Freeminders
//
//  Created by Spencer Morris on 5/30/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "StoreHelper.h"
#import "StoreItem.h"
#import "UserData.h"
#import "UserPurchase.h"

@interface StoreHelper () <SKProductsRequestDelegate>
@end

@implementation StoreHelper {
    
    SKProductsRequest * _productsRequest;
    
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

+ (StoreHelper *)sharedInstance
{
    static dispatch_once_t once;
    static StoreHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithProductIdentifiers:[self getProductIds]];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}

+ (NSSet *)getProductIds
{
    NSMutableSet * productIdentifiers = [[NSMutableSet alloc] init];
    
    for (StoreItem *group in [UserData instance].storeGroupsArray) {
        [productIdentifiers addObject:group.objectId];
    }
    
    return [productIdentifiers copy];
}

- (void)setPurchasedProducts {
    [_purchasedProductIdentifiers removeAllObjects];
    for (NSString * productIdentifier in _productIdentifiers) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    for (UserPurchase *purchase in [UserData instance].userPurchases) {
        if ([purchase.itemType isEqualToNumber:[NSNumber numberWithInt:typeSubscription]]) {
            [UserData instance].userSubscription = purchase;
            [[NSUserDefaults standardUserDefaults] setObject:purchase.expireDate forKey:@"subscriptionExpireDate"];
        }else if ([purchase.itemType isEqualToNumber:[NSNumber numberWithInt:typeIndividual]]){
            if (!purchase.expireDate) {
                [_purchasedProductIdentifiers addObject:purchase.storeItemId];
            }
        }else {
            [_purchasedProductIdentifiers addObject:purchase.storeItemId];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:purchase.storeItemId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
/*    for (NSString * productIdentifier in _productIdentifiers) {
        BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
        if (productPurchased) {
            [_purchasedProductIdentifiers addObject:productIdentifier];
            NSLog(@"Previously purchased: %@", productIdentifier);
        } else {
            NSLog(@"Not purchased: %@", productIdentifier);
        }
    }*/
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    //    if (_productIdentifiers.count < [UserData instance].storeGroupsArray.count) {
    _productIdentifiers = [StoreHelper getProductIds];
    //    }
    
    if (_productsRequest) {
        [_productsRequest cancel];
    }
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (void)requestSubscriptionsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    if (_productIdentifiers.count < [UserData instance].storeGroupsArray.count) {
        _productIdentifiers = [StoreHelper getProductIds];
    }
    if (_productsRequest) {
        [_productsRequest cancel];
    }
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (BOOL)isProductPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark- SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark- Payments

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
    NSMutableDictionary *purchaseInfo = [[NSMutableDictionary alloc] init];
    [purchaseInfo setValue:transaction.transactionIdentifier forKey:@"receiptId"];
    [purchaseInfo setValue:transaction.payment.productIdentifier forKey:@"storeItemId"];
    [purchaseInfo setValue:transaction.transactionDate forKey:@"lastTransactionDate"];
    [self provideContentForProductIdentifier:purchaseInfo];
    //    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
    NSMutableDictionary *purchaseInfo = [[NSMutableDictionary alloc] init];
    [purchaseInfo setValue:transaction.originalTransaction.transactionIdentifier forKey:@"receiptId"];
    [purchaseInfo setValue:transaction.originalTransaction.payment.productIdentifier forKey:@"storeItemId"];
    [purchaseInfo setValue:transaction.transactionDate forKey:@"lastTransactionDate"];
    [self provideContentForProductIdentifier:purchaseInfo];
    //    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...%d----%@-----%@",transaction.error.code,transaction.error.localizedDescription,transaction.error.localizedFailureReason);
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:@"The purchase was not completed" forKey:@"message"];
    [info setObject:@"Purchase Cancelled" forKey:@"title"];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [info setObject:@"Purchase Failed" forKey:@"title"];
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:nil userInfo:info];
}

- (void)provideContentForProductIdentifier:(NSDictionary *)purchaseInfo//(NSString *)productIdentifier
{
    if (![UserData instance].isHavingActiveSubscription){
        [_purchasedProductIdentifiers addObject:[purchaseInfo objectForKey:@"storeItemId"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[purchaseInfo objectForKey:@"storeItemId"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:[purchaseInfo objectForKey:@"storeItemId"] userInfo:purchaseInfo];
}

@end
