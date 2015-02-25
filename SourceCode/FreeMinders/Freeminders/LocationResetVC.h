//
//  LocationResetVCViewController.h
//  Freeminders
//
//  Created by Vegunta's on 11/10/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationResetVC : UIViewController<UIGestureRecognizerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@end
