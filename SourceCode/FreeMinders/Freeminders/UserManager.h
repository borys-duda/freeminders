//
//  UserManager.h
//  Freeminders
//
//  Created by Borys Duda on 24/02/15.
//  Copyright (c) 2015 Freeminders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface UserManager : NSObject

+(UserManager *) sharedInstance;

- (void) signUpUser:(NSString *)username withPassword:(NSString *)password withBlock:(PFBooleanResultBlock)block;
- (void) loginFacebookUserWithBlock:(PFUserResultBlock) block;
- (void) loginUser:(NSString *)username withPassword:(NSString *)password withBlock:(PFUserResultBlock)block;
- (void) saveLoginUserToLocal:(PFUser *)user;
- (void) setUserEmailAddress:(NSString *)email andUsername:(NSString *)username withBlock:(PFBooleanResultBlock)block;
- (void) requestResetPasswordWithEmail:(NSString *)email;
- (void) resendVerificationEmail:(NSString *)email withBlock:(PFBooleanResultBlock)block;
- (void) logoutUser;

- (PFUser *) getCurrentUser;
- (NSString *) getCurrentUserEmail;
- (NSString *) getCurrentUserName;
- (BOOL) isLinkedWithUser;
- (BOOL) isPurchasedUser;

- (void) changeUserEmail:(NSString*)email andUserSetting:(PFObject *)userSetting withBlock:(PFBooleanResultBlock)block;
- (void) changePassword:(NSString*)password andUserSetting:(PFObject *)userSetting withBlock:(PFBooleanResultBlock)block;
- (void) changeUserEmail:(NSString*)email andPassword:(NSString*)password andUserSetting:(PFObject *)userSetting withBlock:(PFBooleanResultBlock)block;
- (void) userPurchaseActionWithBlock:(PFBooleanResultBlock)block;

@end
