//
//  UserPurchases.m
//  Freeminders
//
//  Created by Saisyam Dampuri on 10/31/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "UserPurchase.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserPurchase

@dynamic storeItem, storeItemId, user, amountPaid, receiptId, expireDate, lastTransactionDate, itemType;

+ (NSString *)parseClassName
{
    return @"UserPurchase";
}
@end
