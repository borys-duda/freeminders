//
//  LocationResetVCViewController.m
//  Freeminders
//
//  Created by Vegunta's on 11/10/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import "LocationResetVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "AddressCell.h"
#import "Utils.h"
#import "MapAnnotation.h"
#import "UserLocation.h"
#import "UserData.h"
#import "MBProgressHUD.h"


#define DEFAULT_RADIUS 3.0
#define METERS_PER_MILE 1609.0
#define MILES_PER_DEGREE 57.2957795

@interface LocationResetVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isRepeatSwitch;

@property (strong, nonatomic) NSArray *suggestedAddresses;
@property (strong, nonatomic) MapAnnotation *mapAnnotation;
@property (strong, nonatomic) MKCircle *circleOverlay;
@property (strong, nonatomic) UserLocation *locationToReset;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableString *proposedTextForSearch;

@property (nonatomic) AlertType alertType;

@end

@implementation LocationResetVC

double MAP_SPANS = 0.10;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationToReset = [[UserLocation alloc] init];
    self.locationToReset.radius = [NSNumber numberWithFloat:DEFAULT_RADIUS];
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    
//    [self.isRepeatSwitch setOn:NO];
//    [self setupGestureRecognizers];
    [self adjustMapToNewRadius];
    [self setupSlider];
    [self titleForNavigation];
}
- (IBAction)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed
{    
    [[UserData instance].reminderGroup resetLocations:self.locationToReset isRepeat:[self.isRepeatSwitch isOn]];
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)titleForNavigation
{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setNumberOfLines:3];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:15]];
    [title setText:@"Weather & Location Group Reset"];
    self.navigationItem.titleView = title;
}

- (void)setupSlider
{
    [self.radiusSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor blackColor]];
    self.radiusSlider.value = self.locationToReset.radius.floatValue;
    [self.radiusSlider addTarget:self action:@selector(itemSlider:withEvent:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyboard
{
    [self.textField resignFirstResponder];
}

- (void)adjustMapToNewRadius
{
    MAP_SPANS = (self.locationToReset.radius.doubleValue / MILES_PER_DEGREE) * 1.25;
    
    [self setupMap];
    
    if (self.locationToReset.location)
        self.radiusSlider.maximumValue = self.mapView.region.span.latitudeDelta * MILES_PER_DEGREE;
}

- (void)setupMap
{
    if (self.locationToReset.location.latitude
        && self.locationToReset.location.longitude) {
        self.radiusSlider.hidden = NO;
        
        float lat = self.locationToReset.location.latitude;
        float lng = self.locationToReset.location.longitude;
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        self.mapAnnotation = [[MapAnnotation alloc] init];
        [self.mapAnnotation setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
        [self.mapView addAnnotation:self.mapAnnotation];
        
        float mapSpanY = MAP_SPANS;
        float mapSpanX = mapSpanY * self.mapView.frame.size.width / self.mapView.frame.size.height;
        
        MKCoordinateSpan span = MKCoordinateSpanMake(mapSpanX, mapSpanY);
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lng), span);
        [self.mapView setRegion:region animated:NO];
        
        self.circleOverlay = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(lat, lng) radius:(self.locationToReset.radius.doubleValue * METERS_PER_MILE)];
        
        [self.mapView addOverlay:self.circleOverlay];
        
        if (self.locationToReset.address.length > 0) {
            self.addressLabel.text = self.locationToReset.address;
            self.addressLabel.hidden = NO;
        } else {
            self.addressLabel.hidden = YES;
        }
    } else {
        self.radiusSlider.hidden = YES;
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
    if(_proposedTextForSearch.length > 0)
    {
         return self.suggestedAddresses.count;
    }
    else{
        return 1 + [[UserData instance].userLocations count];
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
    
    
    if(_proposedTextForSearch.length > 0)
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
        if([self.suggestedAddresses count] > indexPath.row)
        {
        SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row)];
        if (place) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                NSLog(@"Placemark: %@", placemark);
                self.locationToReset.location = [PFGeoPoint geoPointWithLocation:placemark.location];
                self.locationToReset.address = addressString;
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
    else{
        if (indexPath.row == 0) {
            double lat = [UserData instance].location.coordinate.latitude;
            double lng = [UserData instance].location.coordinate.longitude;
            if (lat != 0.0 && lng != 0.0) {
                self.locationToReset.location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
                self.locationToReset.address = @"Your Location";
                [self setupMap];
            } else {
                self.alertType = locationServices;
                [Utils showSimpleAlertViewWithTitle:@"Allow Location Services" content:@"Allow location services to center on your location" andDelegate:self];
            }
        } else if (indexPath.row < [[UserData instance].userLocations count]+1){
            UserLocation *location = [[UserData instance].userLocations objectAtIndex:indexPath.row-1];
            self.locationToReset = location;
            self.locationToReset.location = location.location;
            self.locationToReset.address = location.address;
            self.locationToReset.radius = location.radius;
            
        }
        [self adjustMapToNewRadius];
        [self setupMap];
    }

}

#pragma mark- UIAlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == locationServices) {
        [self getUserLocation];
    }
    
    self.alertType = none;
}

#pragma mark- Actions

- (void)itemSlider:(UISlider *)slider withEvent:(UIEvent*)e;
{
    // EVERY TOUCH
    UITouch *touch = [e.allTouches anyObject];
    if (touch.phase == UITouchPhaseEnded) {
        [self adjustMapToNewRadius];
        NSLog(@"ENDED");
    } else {
        self.locationToReset.radius = [NSNumber numberWithFloat:slider.value];
        [self setupMap];
         NSLog(@"ACTIVE");
    }
}

//- (IBAction)isRepeatSwitchToggled:(UISwitch *)sender
//{
//}

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
        self.locationToReset.location = [PFGeoPoint geoPointWithLocation:location];
        self.locationToReset.address = @"Your Location";
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




