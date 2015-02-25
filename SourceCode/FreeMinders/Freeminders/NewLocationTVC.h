//
//  NewLocationTVC.h
//  Freeminders
//
//  Created by Vegunta's on 14/08/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//
#import "CustomTVC.h"
#import <MapKit/MapKit.h>
#import "UserLocation.h"


@interface NewLocationTVC : CustomTVC
<UITextFieldDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDataSource,CLLocationManagerDelegate>

@property int locationToEdit;
@end
