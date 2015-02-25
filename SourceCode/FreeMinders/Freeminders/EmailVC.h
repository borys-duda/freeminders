//
//  EmailVC.h
//  Freeminders
//
//  Created by Vegunta's on 05/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTVC.h"
#import "MBProgressHUD.h"
#import "Const.h"

@interface EmailVC : CustomTVC <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

- (IBAction)lifeTimePurchaseAction:(UIButton *)sender;
@property (nonatomic) BOOL isFromNotificationScreen;
@end
