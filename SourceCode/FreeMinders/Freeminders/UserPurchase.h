//
//  UserPurchases.h
//  Freeminders
//
//  Created by Saisyam Dampuri on 10/31/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <Parse/Parse.h>
#import "StoreItem.h"

@interface UserPurchase : PFObject <PFSubclassing>

@property (strong, nonatomic) StoreItem *storeItem;
@property (strong, nonatomic) NSString *storeItemId;
//@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSNumber *amountPaid; // in dollars (as float)
//@property (strong, nonatomic) NSNumber *amountReceived; // in dollars (as float)
@property (strong, nonatomic) NSString *receiptId;
@property (strong, nonatomic) NSDate *expireDate;
@property (strong, nonatomic) NSDate *lastTransactionDate;
@property (strong, nonatomic) NSNumber *itemType;

@end
