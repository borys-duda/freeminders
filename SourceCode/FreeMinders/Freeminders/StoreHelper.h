//
//  StoreHelper.h
//  Freeminders
//
//  Created by Spencer Morris on 5/30/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IAPHelperProductPurchasedNotification @"IAPHelperProductPurchasedNotification"
#define IAPHelperProductFailedNotification @"IAPHelperProductFailedNotification"

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface StoreHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (StoreHelper *)sharedInstance;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)isProductPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (void)provideContentForProductIdentifier:(NSDictionary *)purchaseInfo;
- (void)setPurchasedProducts;

@end
