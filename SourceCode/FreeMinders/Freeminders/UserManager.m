//
//  UserManager.m
//  Freeminders
//
//  Created by Borys Duda on 24/02/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager

static UserManager *gInstance = nil;

+(UserManager *) sharedInstance {
    @synchronized(self) {
        if (gInstance == nil) {
            gInstance = [[self alloc] init];
        }
    }
    
    return gInstance;
}

- (void)signUpUser:(NSString *)username withPassword:(NSString *)password withBlock:(PFBooleanResultBlock)block
{
    PFUser *user = [PFUser user];
    user.password = password;
    user.email = username;
    user.username = username;
    
    [user signUpInBackgroundWithBlock:block];
}

- (void) loginFacebookUserWithBlock:(PFUserResultBlock) block
{
    NSArray *permissionsArray = @[@"email"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:block];
}

- (void) loginUser:(NSString *)username withPassword:(NSString *)password withBlock:(PFUserResultBlock)block
{
    [PFUser logInWithUsernameInBackground:username password:password block:block];
}

- (void) saveLoginUserToLocal:(PFUser *)user
{
    NSLog(@"%@, %@", user.username, user.password);
}

- (void) setUserEmailAddress:(NSString *)email andUsername:(NSString *)username withBlock:(PFBooleanResultBlock)block
{
    [[self getCurrentUser] setEmail:email];
    [[self getCurrentUser] setUsername:username];
    [[self getCurrentUser] saveInBackgroundWithBlock:block];
}


- (void) requestResetPasswordWithEmail:(NSString *)email
{
    [PFUser requestPasswordResetForEmail:email];
}

- (void) resendVerificationEmail:(NSString *)email withBlock:(PFBooleanResultBlock)block
{
    [PFUser currentUser].email = @"foo@foo.com";
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [PFUser currentUser].email = email.lowercaseString;
            [PFUser currentUser].username = email.lowercaseString;
            [[PFUser currentUser] saveInBackgroundWithBlock:block];
        }
    }];
}

- (void) logoutUser
{
    [PFQuery clearAllCachedResults];
    [PFUser logOut];
    if ([self isLinkedWithUser]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [FBSession.activeSession closeAndClearTokenInformation];
        NSLog(@"The user is no longer associated with their Facebook account.");
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            NSLog(@"%@", cookie);
            [storage deleteCookie:cookie];
        }
    }
}

- (PFUser *) getCurrentUser
{
    return [PFUser currentUser];
}

- (NSString *) getCurrentUserEmail
{
    return [PFUser currentUser].email;
}

- (NSString *) getCurrentUserName
{
    return [PFUser currentUser].username;
}

- (BOOL) isLinkedWithUser
{
    return [PFFacebookUtils isLinkedWithUser:[self getCurrentUser]];
}

- (BOOL) isPurchasedUser
{
    return [[[self getCurrentUser] objectForKey:@"hasUnlimitedEmail"] boolValue];
}

- (void) changeUserEmail:(NSString*)email andUserSetting:(PFObject *)userSetting withBlock:(PFBooleanResultBlock)block
{
    [self getCurrentUser].email = email;
    [self getCurrentUser].username = email;
    [PFObject saveAllInBackground:[NSArray arrayWithObjects:userSetting,[self getCurrentUser], nil] block:block];
}

- (void) changePassword:(NSString*)password andUserSetting:(PFObject *)userSetting withBlock:(PFBooleanResultBlock)block
{
    [self getCurrentUser].password = password;
    [PFObject saveAllInBackground:[NSArray arrayWithObjects:userSetting,[self getCurrentUser], nil] block:block];
}

- (void) changeUserEmail:(NSString*)email andPassword:(NSString*)password andUserSetting:(PFObject *)userSetting withBlock:(PFBooleanResultBlock)block
{
    [self getCurrentUser].email = email;
    [self getCurrentUser].username = email;
    [self getCurrentUser].password = password;
    [PFObject saveAllInBackground:[NSArray arrayWithObjects:userSetting,[self getCurrentUser], nil] block:block];
}

- (void) userPurchaseActionWithBlock:(PFBooleanResultBlock)block
{
    [[self getCurrentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"hasUnlimitedEmail"];
    [[self getCurrentUser] saveInBackgroundWithBlock:block];
}


@end
