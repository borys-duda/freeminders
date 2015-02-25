//
//  LocationTriggerVC.h
//  Freeminders
//
//  Created by Spencer Morris on 5/14/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "CustomVC.h"
#import <MapKit/MapKit.h>

@interface LocationTriggerVC : CustomVC <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@end
