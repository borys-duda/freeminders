//
//  StoreVC.h
//  Freeminders
//
//  Created by Spencer Morris on 5/20/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "CustomVC.h"

@interface StoreVC : CustomVC <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic)BOOL isFromMyGroupsScreen;
@end
