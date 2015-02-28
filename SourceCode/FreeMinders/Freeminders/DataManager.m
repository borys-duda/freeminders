//
//  DataManager.m
//  Freeminders
//
//  Created by Borys Duda on 24/02/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "DataManager.h"
#import "UserData.h"
#import "UserContact.h"
#import "UserManager.h"
#import "Reachability.h"

@implementation DataManager

static DataManager *gInstance = nil;
static BOOL isConnected = false;

+(DataManager *) sharedInstance {
    @synchronized(self) {
        if (gInstance == nil) {
            gInstance = [[self alloc] init];
            Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
            [internetReachability startNotifier];
            NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
            switch (netStatus)
            {
            case NotReachable:
                isConnected = false;
                break;
            case ReachableViaWWAN:
                isConnected = true;
                break;
            case ReachableViaWiFi:
                isConnected = true;
                break;
            }
        }
    }
    
    return gInstance;
}

- (void) reachabilityChanged:(NSNotification *) note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            isConnected = false;
            break;
        case ReachableViaWWAN:
            isConnected = true;
            break;
        case ReachableViaWiFi:
            isConnected = true;
            break;
    }
}

- (void) saveDatas:(NSArray *)array withBlock:(PFBooleanResultBlock)block
{
    [PFObject pinAllInBackground:array];
    if (isConnected) {
        [PFObject saveAllInBackground:array block:block];
    } else {
        for (int i = 0; i < array.count; i++) {
            PFObject *object = [array objectAtIndex:i];
            if (i == array.count - 1) {
                [object saveEventually:block];
            } else {
                [object saveEventually];
            }
        }

    }
}

- (void) saveDatas:(NSArray *)array
{
    [PFObject pinAllInBackground:array];
    if (isConnected) {
        [PFObject saveAllInBackground:array];
    } else {
        for (int i = 0; i < array.count; i++) {
            PFObject *object = [array objectAtIndex:i];
            [object saveEventually];
        }
    }
}

- (void) saveObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block
{
    [object pin];
    if (isConnected) {
        [object saveInBackgroundWithBlock:block];
    } else {
        [object saveEventually:block];
    }
}

- (void) saveObject:(PFObject <PFSubclassing> *)object
{
    [object pin];
    if (isConnected) {
        [object saveInBackground];
    } else {
        [object saveEventually];
    }

}

- (void) saveToLocalWithObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block
{
    [object saveEventually:block];
}

- (void) saveToLocalWithObject:(PFObject <PFSubclassing> *)object
{
    [object saveEventually];
}

- (void) loadSubscriptionWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[StoreItem parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"isEnabled" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"itemType" equalTo:[NSNumber numberWithInt:typeDonation]];
    [query setLimit:1000];
    [query orderBySortDescriptors:[NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES], nil]];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadUserContactsWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[UserContact parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[[UserManager sharedInstance] getCurrentUser]];
    [query setLimit:1000];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadTaskSetsWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[ReminderGroup parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[[UserManager sharedInstance] getCurrentUser]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query setLimit:1000];
    if (![UserData instance].isHavingActiveSubscription) {
        [query whereKey:@"isSubscribed" notEqualTo:[NSNumber numberWithBool:YES]];
    }
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadUserSettingsWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[UserSetting parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[[UserManager sharedInstance] getCurrentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadDefaultAddress:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[UserLocation parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadDetailedTasksWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    if (![UserData instance].isHavingActiveSubscription) {
        [query whereKey:@"isSubscribed" notEqualTo:[NSNumber numberWithBool:YES]];
    }
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderBySortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"lastNotificationDate" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO], nil]];
    [query includeKey:@"weatherTriggers.userLocation"];
    [query includeKey:@"locationTriggers.userLocation"];
    [query includeKey:@"dateTimeTriggers"];
    [query includeKey:@"reminderSteps"];
    [query includeKey:@"userContacts"];
    [query includeKey:@"reminderGroup"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadStoreGroupsWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[StoreItem parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"isEnabled" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"itemType" equalTo:[NSNumber numberWithInt:typeIndividual]];
    [query includeKey:@"reminderGroups"];
    [query includeKey:@"reminderGroups.reminders"];
    [query includeKey:@"reminderGroups.reminders.weatherTriggers.userLocation"];
    [query includeKey:@"reminderGroups.reminders.locationTriggers.userLocation"];
    [query includeKey:@"reminderGroups.reminders.dateTimeTriggers"];
    [query includeKey:@"reminderGroups.reminders.reminderSteps"];
    [query includeKey:@"storeCategories"];
    [query setLimit:1000];
    [query orderBySortDescriptors:[NSArray arrayWithObjects: [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO], nil]];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadStoreTasksWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"isStoreTask" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"weatherTriggers"];
    [query includeKey:@"locationTriggers"];
    [query includeKey:@"datetimeTriggers"];
    [query includeKey:@"reminderSteps"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadTasksWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) loadUserPurchasedWithBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[UserPurchase parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"itemType" equalTo:[NSNumber numberWithInt:typeSubscription]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) checkUserPurchasedWithProductId:(NSString*)productId withObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock) block;
{
    PFQuery *query = [PFQuery queryWithClassName:[UserPurchase parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"storeItemId" equalTo:productId];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    if ([query countObjects] == 0) {
        
        [object saveInBackgroundWithBlock:block];
    }
}







- (void) deleteObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block
{
    [object deleteInBackgroundWithBlock:block];
}

- (void) deleteObject:(PFObject <PFSubclassing> *)object{
    [object deleteInBackground];
}

- (void) deleteAllTasksWithTaskSetId:(PFObject <PFSubclassing>*)object withBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    [query whereKey:@"reminderGroup" equalTo:object];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

@end









