//
//  DataManager.m
//  Freeminders
//
//  Created by Borys Duda on 24/02/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "DataManager.h"
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
            [internetReachability startNotifier];
            NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
            if (netStatus == NotReachable) {
                isConnected = false;
            } else {
                isConnected = true;
            }
        }
    }
    
    return gInstance;
}

- (BOOL) checkConnectionStatus
{
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
        isConnected = false;
    } else {
        isConnected = true;
    }
    
    return isConnected;
}

- (void) saveDatas:(NSArray *)array withBlock:(PFBooleanResultBlock)block
{
    [PFObject pinAllInBackground:array];
    if (isConnected) {
        [PFObject saveAllInBackground:array block:block];
    } else {
        for (int i = 0; i < array.count; i++) {
            PFObject *object = [array objectAtIndex:i];
//            if (i == array.count - 1) {
//                [object saveEventually:block];
//            } else {
                [object saveEventually];
//            }
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
    
    if (isConnected) {
        [object pin];
        [object saveInBackgroundWithBlock:block];
    } else {
        [object saveEventually];
        [object pinInBackgroundWithBlock:block];
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

// Edit
- (void) saveReminders:(NSArray *)array withBlock:(PFBooleanResultBlock)block
{
    if (isConnected) {
        [Reminder saveAllInBackground:array block:block];
    } else {
        for (int i = 0; i < array.count; i++) {
            Reminder *object = [array objectAtIndex:i];
            [object saveEventually];
        }
        
    }
}

- (void) saveReminders:(NSArray *)array
{
    if (isConnected) {
        [Reminder saveAllInBackground:array];
    } else {
        for (int i = 0; i < array.count; i++) {
            Reminder *object = [array objectAtIndex:i];
            [object saveEventually];
        }
        
    }
}

- (void) saveReminder:(Reminder *)reminder withBlock:(PFBooleanResultBlock)block
{
    if (isConnected) {
        [reminder pin];
        [reminder saveInBackgroundWithBlock:block];
    } else {
        [reminder saveEventually];
        [reminder pinInBackgroundWithBlock:block];
    }
}

- (void) saveReminder:(Reminder *)reminder
{
    if (isConnected) {
        [reminder saveInBackground];
    } else {
        [reminder saveEventually];
    }
}

- (void) saveReminderGroup:(ReminderGroup *)group withBlock:(PFBooleanResultBlock)block
{
    if (isConnected) {
        [group pin];
        [group saveInBackgroundWithBlock:block];
    } else {
        [group saveEventually];
        [group pinInBackgroundWithBlock:block];
    }
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
//    query.cachePolicy = kPFCachePolicyNetworkElseCache;
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
    [self checkConnectionStatus];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    if (![UserData instance].isHavingActiveSubscription) {
        [query whereKey:@"isSubscribed" notEqualTo:[NSNumber numberWithBool:YES]];
    }
//    query.cachePolicy = kPFCachePolicyNetworkElseCache;
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
        if (isConnected) {
            [object pinInBackground];
            [object saveInBackgroundWithBlock:block];
        }
        else {
            [object pinInBackgroundWithBlock:block];
            [object saveEventually];
        }
    }
}







- (void) deleteObject:(PFObject <PFSubclassing> *)object withBlock:(PFBooleanResultBlock)block
{
    [object unpinInBackground];
    if (!isConnected) {
        [object unpinInBackgroundWithBlock:block];
        [object deleteEventually];
    }else {
        [object unpinInBackground];
        [object deleteInBackgroundWithBlock:block];
    }
}

- (void) deleteObject:(PFObject <PFSubclassing> *)object{
    [object unpinInBackground];
    [object deleteInBackground];
}

- (void) deleteReminder:(Reminder *)reminder withBlock:(PFBooleanResultBlock)block
{
    [reminder unpinInBackground];
    if (!isConnected) {
        [reminder unpinInBackgroundWithBlock:block];
        [reminder deleteEventually];
    }else {
        [reminder unpinInBackground];
        [reminder deleteInBackgroundWithBlock:block];
    }
}

- (void) deleteReminders:(NSArray *)reminders withBlock:(PFBooleanResultBlock)block
{
    if (!isConnected) {
        [Reminder unpinAllInBackground:reminders block:block];
        for (int i = 0; i < reminders.count; i++) {
            Reminder *reminder = (Reminder *)[reminders objectAtIndex:i];
            [reminder deleteEventually];
        }
    } else {
        [PFObject unpinAllInBackground:reminders];
        [PFObject deleteAllInBackground:reminders block:block];
    }
}




- (void) findAllTasksWithTaskSetId:(PFObject <PFSubclassing>*)object withBlock:(PFArrayResultBlock) block
{
    PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
    if (!isConnected) {
        [query fromLocalDatastore];
    }
    [query whereKey:@"reminderGroup" equalTo:object];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:block];
}

- (void) deleteAllObjects:(NSArray*)objects withBlock:(PFBooleanResultBlock) block
{
    if (!isConnected) {
        [PFObject unpinAllInBackground:objects block:block];
        for (int i = 0; i < objects.count; i++) {
            PFObject *object = (PFObject *)[objects objectAtIndex:i];
            [object deleteEventually];
        }
    } else {
        [PFObject unpinAllInBackground:objects];
        [PFObject deleteAllInBackground:objects block:block];
    }
}

@end









