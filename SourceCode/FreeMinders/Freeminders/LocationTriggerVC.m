//
//  LocationTriggerVC.m
//  Freeminders
//
//  Created by Spencer Morris on 5/14/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "LocationTriggerVC.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "AddressCell.h"
#import "Utils.h"
#import "MapAnnotation.h"
#import "UserLocation.h"
#import "DataManager.h"

#define DEFAULT_RADIUS 3.0
#define METERS_PER_MILE 1609.0
#define MILES_PER_DEGREE 57.2957795

@interface LocationTriggerVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isRepeatSwitch;

@property (strong, nonatomic) NSArray *suggestedAddresses;
@property (strong, nonatomic) MapAnnotation *mapAnnotation;
@property (strong, nonatomic) MKCircle *circleOverlay;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic) AlertType alertType;

@property (strong, nonatomic) NSMutableString *proposedTextForSearch;

@end

@implementation LocationTriggerVC

double MAP_SPAN = 0.10;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (![UserData instance].task.locationTriggers || ![UserData instance].task.locationTriggers.count) {
        [UserData instance].task.locationTriggers = [[NSMutableArray alloc] init];
          LocationTrigger *trigger = [[LocationTrigger alloc] init];
         [[UserData instance].task.locationTriggers addObject:trigger];

        ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).radius = [NSNumber numberWithDouble:DEFAULT_RADIUS];
        // Location
        if([UserData instance].userLocations > 0)
        {
            for(int i=0; i < [UserData instance].userLocations.count; i++)
            {
                if(((UserLocation *)([[UserData instance].userLocations objectAtIndex:i])).isDefault)
                {
                    ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location=((UserLocation *)([[UserData instance].userLocations objectAtIndex:i])).location;
                    ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).userLocation = ((UserLocation *)([[UserData instance].userLocations objectAtIndex:i]));
                    self.addressLabel.text=((UserLocation *)([[UserData instance].userLocations objectAtIndex:i])).address;
                }
            }
        }else if ([UserData instance].userInfo.defaultLocationPoint) {
             ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = [UserData instance].userInfo.defaultLocationPoint;
             self.addressLabel.text=@"Your Location";
        } else {
            ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
        }
        // Address
        ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address = [UserData instance].userInfo.defaultLocationAddress;
        [[DataManager sharedInstance] saveReminder:[UserData instance].task];
    }
    UserLocation *usrLocation = ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).userLocation;
    if (usrLocation && ![usrLocation isEqual:[NSNull null]]) {
        ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).userLocation.location;
    }
    
    [self.isRepeatSwitch setOn:((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).isRepeat];
//    [self setupGestureRecognizers];
    [self adjustMapToNewRadius];
    [self setupSlider];
}

- (void)setupSlider
{
    [self.radiusSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor blackColor]];
     self.radiusSlider.value = ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).radius.floatValue;
    [self.radiusSlider addTarget:self action:@selector(itemSlider:withEvent:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.tableView addGestureRecognizer:tap];
}

- (void)hideKeyboard
{
    [self.textField resignFirstResponder];
}

- (void)adjustMapToNewRadius
{
    MAP_SPAN = (((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).radius.doubleValue / MILES_PER_DEGREE) * 1.25;
    
    [self setupMap];
    
    if (((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location)
        self.radiusSlider.maximumValue = self.mapView.region.span.latitudeDelta * MILES_PER_DEGREE;
}

- (void)setupMap
{
    if (((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location.latitude
        && ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location.longitude) {
        self.radiusSlider.hidden = NO;
        
        float lat = ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location.latitude;
        float lng = ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location.longitude;
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        self.mapAnnotation = [[MapAnnotation alloc] init];
        [self.mapAnnotation setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
        [self.mapView addAnnotation:self.mapAnnotation];
        
        float mapSpanY = MAP_SPAN;
        float mapSpanX = mapSpanY * self.mapView.frame.size.width / self.mapView.frame.size.height;
        
        MKCoordinateSpan span = MKCoordinateSpanMake(mapSpanX, mapSpanY);
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lng), span);
        [self.mapView setRegion:region animated:NO];
        
        self.circleOverlay = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(lat, lng) radius:(((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).radius.doubleValue * METERS_PER_MILE)];
        
        [self.mapView addOverlay:self.circleOverlay];
        
        if (((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address.length > 0) {
            self.addressLabel.text = ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address;
            self.addressLabel.hidden = NO;
//            self.textField.text=((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address;
        }
    }
}

#pragma mark- UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView] && ! [self.textField isEditing]) {
        return NO;
    } else if ([touch.view isDescendantOfView:self.radiusSlider]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark- MKMapView delegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer* circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    [circleView setStrokeColor:[UIColor blueColor]];
    [circleView setLineWidth:3.0f];
    [circleView setFillColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1]];
    
    return circleView;
}

#pragma mark- UITextField methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self hideKeyboard];
    
//    if (textField.text.length > 0)
//        [self performSearchForAddresses:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}
- (IBAction)cancelButtonpressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _proposedTextForSearch = [NSMutableString stringWithString:textField.text];
    [_proposedTextForSearch replaceCharactersInRange:range withString:string];
    [self performSearchForAddresses:_proposedTextForSearch];
    
    // Do stuff.
    return YES; // Or NO. Whatever. It's your function.
}

#pragma mark- UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_proposedTextForSearch.length>0)
    {
        return self.suggestedAddresses.count;
    }
    else{
        return [[UserData instance].userLocations count] + 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        NSString *CELL_IDENTIFIER = @"currentLocationCell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
//        
//        if (cell == nil)
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
//        
//        return cell;
//    }
    if(_proposedTextForSearch.length>0)
    {
        NSString *CELL_IDENTIFIER = @"addressCell";
        AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        
        if (cell == nil)
            cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row)];
        cell.addressLabel.text = place.name;
        
        return cell;
    }
    else{
            if (indexPath.row == 0) {
                NSString *CELL_IDENTIFIER = @"currentLocationCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        
                if (cell == nil)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
               return cell;
            }
        
        NSString *CELL_IDENTIFIER = @"addressCell";
        AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        
        if (cell == nil)
            cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        if (indexPath.row < [[UserData instance].userLocations count]+1) {
            UserLocation *location = [[UserData instance].userLocations objectAtIndex:indexPath.row-1];
            NSString *address = [NSString stringWithFormat:@"%@ %@",location.name, location.isDefault?@"(Default)":@""];
            cell.addressLabel.text = address;
            cell.addressLabel.textColor = [UIColor grayColor];
            cell.addressLabel.font = [UIFont systemFontOfSize:14];
        }
         return cell;

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    if(self.textField.text.length > 0)
    {
//    if (indexPath.row == 0) {
//        double lat = [UserData instance].location.coordinate.latitude;
//        double lng = [UserData instance].location.coordinate.longitude;
//        if (lat != 0.0 && lng != 0.0) {
//            ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
//            ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address = @"User/Custom Location";
//            [self setupMap];
//        } else {
//            self.alertType = locationServices;
//            [Utils showSimpleAlertViewWithTitle:@"Allow Location Services" content:@"Allow location services to center on your location" andDelegate:self];
//        }
//    } else
   if([self.suggestedAddresses count] > indexPath.row)
   {
       SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row)];
        if (place) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                NSLog(@"Placemark: %@", placemark);
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:placemark.location];
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address = addressString;
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).userLocation = nil;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if(!placemark.location)
                {
                    [Utils showSimpleAlertViewWithTitle:@"Invalid Address" content:@"Please choose a different location. There was a problem getting data on the chosen location" andDelegate:self];
                }else{
                    [self adjustMapToNewRadius];
                    [self setupMap];
                }
            }];
        }
    }
    }
    else
    {
        if (indexPath.row == 0) {
            double lat = [UserData instance].location.coordinate.latitude;
            double lng = [UserData instance].location.coordinate.longitude;
            if (lat != 0.0 && lng != 0.0) {
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address = @"Your Location";
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).userLocation = nil;
                [self setupMap];
            } else {
                self.alertType = locationServices;
                [Utils showSimpleAlertViewWithTitle:@"Allow Location Services" content:@"Allow location services to center on your location" andDelegate:self];
            }
        }else{
            
            if (indexPath.row < [[UserData instance].userLocations count]+1){
                UserLocation *location = [[UserData instance].userLocations objectAtIndex:indexPath.row -1];
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = location.location;
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).userLocation = location;
                ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address = location.address;
                
            }
        }
        [self adjustMapToNewRadius];
        [self setupMap];
    }
   
}

#pragma mark- UIAlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == locationServices) {
         NSURL*url=[NSURL URLWithString:@"prefs://"];
        [[UIApplication sharedApplication] openURL:url];
        [self getUserLocation];
        
    }
    
    self.alertType = none;
}

#pragma mark- Actions

- (IBAction)savePressed
{
    [UserData instance].didChangeTrigger = YES;
    [UserData instance].task.lastNotificationDate=nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)itemSlider:(UISlider *)slider withEvent:(UIEvent*)e;
{
    // EVERY TOUCH
    UITouch *touch = [e.allTouches anyObject];
    if (touch.phase == UITouchPhaseEnded) {
        [self adjustMapToNewRadius];
        NSLog(@"ENDED");
    } else {
        ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).radius = [NSNumber numberWithFloat:slider.value];
        [self setupMap];
        NSLog(@"ACTIVE");
    }
}

- (IBAction)isRepeatSwitchToggled:(UISwitch *)sender
{
    ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).isRepeat = sender.isOn;
}

#pragma mark- Location methods

- (void)getUserLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *location = [locations firstObject];
    [UserData instance].location = location;
    if (location) {
        ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).location = [PFGeoPoint geoPointWithLocation:location];
        ((LocationTrigger *)[[UserData instance].task.locationTriggers objectAtIndex:0]).address = @"Your Location";
        [self setupMap];
    }
}

#pragma mark- Networking

- (void)performSearchForAddresses:(NSString *)queryString
{
    self.suggestedAddresses = [[NSArray alloc] init];
    [self.tableView reloadData];
    
    SPGooglePlacesAutocompleteQuery *query = [SPGooglePlacesAutocompleteQuery query];
    query.input = queryString;
    query.language = @"en";
    query.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    query.sensor = YES;
    
    //    query.location = CLLocationCoordinate2DMake(41.8759635, -87.628563);
    
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        NSLog(@"Places returned %@", places);
        
        self.suggestedAddresses = places;
        [self.tableView reloadData];
    }];
}

#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
