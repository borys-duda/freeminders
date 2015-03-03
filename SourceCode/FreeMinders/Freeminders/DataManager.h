//
//  DataManager.h
//  Freeminders
//
//  Created by Borys Duda on 24/02/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface DataManager : NSObject

+(DataManager *) sharedInstance;

- (BOOL) checkConnectionStatus;

- (void) saveDatas:(NSArray *)array withBlock:(PFBooleanResultBlock)block;
- (void) saveDatas:(NSArray *)array;
- (void) saveObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block;
- (void) saveObject:(PFObject <PFSubclassing> *)object;
- (void) saveToLocalWithObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block;
- (void) saveToLocalWithObject:(PFObject <PFSubclassing> *)object;

- (void) loadSubscriptionWithBlock:(PFArrayResultBlock) block;
- (void) loadUserContactsWithBlock:(PFArrayResultBlock) block;
- (void) loadTaskSetsWithBlock:(PFArrayResultBlock) block;
- (void) loadUserSettingsWithBlock:(PFArrayResultBlock) block;
- (void) loadDefaultAddress:(PFArrayResultBlock) block;
- (void) loadDetailedTasksWithBlock:(PFArrayResultBlock) block;
- (void) loadTasksWithBlock:(PFArrayResultBlock) block;
- (void) loadStoreGroupsWithBlock:(PFArrayResultBlock) block;
- (void) loadStoreTasksWithBlock:(PFArrayResultBlock) block;
- (void) loadUserPurchasedWithBlock:(PFArrayResultBlock) block;

- (void) checkUserPurchasedWithProductId:(NSString*)productId withObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock) block;

- (void) deleteObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block;
- (void) deleteObject:(PFObject <PFSubclassing> *)object;
- (void) findAllTasksWithTaskSetId:(PFObject <PFSubclassing>*)object withBlock:(PFArrayResultBlock) block;
- (void) deleteAllObjects:(NSArray*)objects withBlock:(PFBooleanResultBlock) block;



@end
