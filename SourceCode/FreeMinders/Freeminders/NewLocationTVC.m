

#import "NewLocationTVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utils.h"
#import "MapAnnotation.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "AddressCell.h"
#import "UserData.h"
#import "Reminder.h"
#import "WeatherTrigger.h"
#import "DataManager.h"



#define DEFAULT_MAP_SPAN 0.10
#define DEFAULT_RADIUS 3.0
#define METERS_PER_MILE 1609.0
#define MILES_PER_DEGREE 57.2957795

@interface NewLocationTVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *suggestedAddressTextField;
@property (weak, nonatomic) IBOutlet UITableView *suggestedAddressTableView;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextfield;


@property (strong, nonatomic) NSArray *suggestedAddresses;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MapAnnotation *mapAnnotation;
@property (strong, nonatomic) MKCircle *circleOverlay;
@property (strong,nonatomic)  UserLocation *userLocation;



@property (nonatomic) AlertType alertType;

@end

@implementation NewLocationTVC
double MP_SPAN = 0.10;

@synthesize locationToEdit;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.suggestedAddressTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (locationToEdit>=0) {
        NSLog(@"EDIT Location");
        self.userLocation = [[UserData instance].userLocations objectAtIndex:locationToEdit];
        self.titleTextfield.text = self.userLocation.name;
        self.addressLabel.text = self.userLocation.address;
    }else{
        self.userLocation = [[UserLocation alloc] init];
        self.userLocation.radius = [NSNumber numberWithDouble:DEFAULT_RADIUS];
    }
//    [self setupGestureRecognizers];
    [self adjustMapToNewRadius];
    [self setupSlider];
    
    
//    [self setupGestureRecognizers];
}
- (void)setSuggestedAddresses:(NSArray *)add {
    NSLog(@"------: %@",add);
    _suggestedAddresses = add;
}
- (void)setupMap
{
    if (self.userLocation.location.latitude != 0.0
        && self.userLocation.location.longitude != 0.0) {
        
        self.radiusSlider.hidden = NO;
        
        float lat = self.userLocation.location.latitude;
        float lng = self.userLocation.location.longitude;
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        self.mapAnnotation = [[MapAnnotation alloc] init];
        [self.mapAnnotation setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
        [self.mapView addAnnotation:self.mapAnnotation];
        
        float mapSpanY = MP_SPAN;
        float mapSpanX = mapSpanY * self.mapView.frame.size.width / self.mapView.frame.size.height;
        
        MKCoordinateSpan span = MKCoordinateSpanMake(mapSpanX , mapSpanY);
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lng), span);
        [self.mapView setRegion:region animated:NO];
        
        double rad = self.userLocation.radius?[self.userLocation.radius doubleValue]:DEFAULT_RADIUS/3;//(locationToEdit >= 0)?((UserLocation *)[[UserData instance].userLocations objectAtIndex:locationToEdit]).radius.doubleValue:DEFAULT_RADIUS;
        
        self.circleOverlay = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(lat, lng) radius:(rad * METERS_PER_MILE)];
        
        [self.mapView addOverlay:self.circleOverlay];
        
        if (self.userLocation.address.length > 0) {
            self.addressLabel.text = self.userLocation.address;
            self.addressLabel.hidden = NO;
        } else {
            self.addressLabel.hidden = YES;
        }
    }
    else
    {
     self.radiusSlider.hidden = YES;   
    }
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyboard
{
    if ([self.suggestedAddressTextField isFirstResponder])
        [self.suggestedAddressTextField resignFirstResponder];
    if ([self.titleTextfield isFirstResponder])
        [self.titleTextfield resignFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertType == locationServices) {
        NSURL*url=[NSURL URLWithString:@"prefs://"];
        [[UIApplication sharedApplication] openURL:url];
        [self getUserLocation];
    }
    
    self.alertType = none;
}

- (void)setupSlider
{
    [self.radiusSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.radiusSlider setMinimumTrackTintColor:[UIColor blackColor]];
    self.radiusSlider.value = self.userLocation.radius.floatValue;
    [self.radiusSlider addTarget:self action:@selector(itemSlider:withEvent:) forControlEvents:UIControlEventValueChanged];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.tableView] && ! [self.suggestedAddressTextField isEditing]) {
        return NO;
    } else if ([touch.view isDescendantOfView:self.radiusSlider]) {
        return NO;
    } else {
        return YES;
    }
}
- (void)adjustMapToNewRadius
{
    MP_SPAN = (self.userLocation.radius.doubleValue / MILES_PER_DEGREE) * 1.25;
    
    [self setupMap];
    
    if (self.userLocation.location)
        self.radiusSlider.maximumValue = self.mapView.region.span.latitudeDelta * MILES_PER_DEGREE;
}
- (void)itemSlider:(UISlider *)slider withEvent:(UIEvent*)e;
{
    // EVERY TOUCH
    UITouch *touch = [e.allTouches anyObject];
    if (touch.phase == UITouchPhaseEnded) {
        [self adjustMapToNewRadius];
        NSLog(@"ENDED");
    } else {
        self.userLocation.radius = [NSNumber numberWithFloat:slider.value];
        [self setupMap];
        NSLog(@"ACTIVE");
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
//    [self hideKeyboard];
//    if (self.suggestedAddressTextField.text.length > 0)
//        [self performSearchForAddresses:textField.text];
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [self hideKeyboard];
    [textField resignFirstResponder];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.titleTextfield) {
        NSMutableString *proposed = [NSMutableString stringWithString:textField.text];
        [proposed replaceCharactersInRange:range withString:string];
        [self performSearchForAddresses:proposed];
        // Do stuff.
    }
    return YES; // Or NO. Whatever. It's your function.
}



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
        ((UserLocation *)[[UserData instance].userLocations objectAtIndex:locationToEdit]).location = [PFGeoPoint geoPointWithLocation:location];
        ((UserLocation *)[[UserData instance].userLocations objectAtIndex:locationToEdit]).address = @"Your Location";
        [self setupMap];
    }
}


#pragma mark- UITableView methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [super numberOfSectionsInTableView:tableView];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [super tableView:tableView numberOfRowsInSection:section];
    } else {
        return self.suggestedAddresses.count + 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        if (indexPath.row == 0) {
            NSString *CELL_IDENTIFIER = @"currentLocationCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
            
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
              
            return cell;
        }
        NSString *CELL_IDENTIFIER = @"addressCell";
        AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        
        if (cell == nil)
            cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        
        SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row - 1)];
        cell.textLabel.font=[UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:14.0f];
        cell.textLabel.textColor=[UIColor lightGrayColor];
        cell.textLabel.text = place.name;
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        NSInteger section = indexPath.section ;
        if(section == 0)
        {
            return 50;
        }
        else  if (section == 1) {
            int addition = [[UIScreen mainScreen] bounds].size.height == 568 ? 88 : 0;
            return [super tableView:tableView heightForRowAtIndexPath:indexPath] + addition;
        }
    }
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if(section == 0)
        {
            return [super tableView:tableView heightForHeaderInSection:section];
        }
        else  if (section == 1) {
            return [super tableView:tableView heightForHeaderInSection:section];
        }
        
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    if (tableView == self.tableView) {
        // DO NOTHING
    } else {
        if (indexPath.row == 0) {
            double lat = [UserData instance].location.coordinate.latitude;
            double lng = [UserData instance].location.coordinate.longitude;
            if (lat != 0.0 && lng != 0.0) {
                self.userLocation.location = [PFGeoPoint geoPointWithLocation:[UserData instance].location];
                self.userLocation.address = @"Your Location";
                [self adjustMapToNewRadius];
                [self setupMap];
            } else {
                self.alertType = locationServices;
                [Utils showSimpleAlertViewWithTitle:@"Allow Location Services" content:@"Allow location services to center on your location" andDelegate:self];
            }
        } else {
            
            if([self.suggestedAddresses count] > indexPath.row)            {
                NSLog(@" index paths working how %@",[self.suggestedAddresses objectAtIndex:(indexPath.row-1)]);
                SPGooglePlacesAutocompletePlace *place = [self.suggestedAddresses objectAtIndex:(indexPath.row-1)];
                if (place) {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                        NSLog(@"Placemark: %@", placemark);
                        self.userLocation.location = [PFGeoPoint geoPointWithLocation:placemark.location];
                        self.userLocation.address = addressString;
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
    }
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (IBAction)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveButtonPressed
{
    self.userLocation.name=self.titleTextfield.text;
    self.userLocation.user=[PFUser currentUser];
    if(locationToEdit < 0)
        self.userLocation.isDefault=NO;
    if (self.userLocation.name.length) {
        [self performSaveLocation:self.userLocation];
    } else{
        [Utils showSimpleAlertViewWithTitle:@"Invalid Location" content:@"Please enter name for the location" andDelegate:nil];
    }
    
}
- (void)performSaveLocation:(UserLocation *)loctionTitle
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (locationToEdit>=0) {
        [[UserData instance].userLocations replaceObjectAtIndex:locationToEdit withObject:loctionTitle];
    }else {
        [[UserData instance].userLocations addObject:loctionTitle];
    }
    [[DataManager sharedInstance] saveDatas:[UserData instance].userLocations withBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            NSLog(@"User Locations saved");
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (void)performSearchForAddresses:(NSString *)queryString
{
    self.suggestedAddresses = [[NSArray alloc] init];
    [self.suggestedAddressTableView reloadData];
    
    SPGooglePlacesAutocompleteQuery *query = [SPGooglePlacesAutocompleteQuery query];
    query.input = queryString;
    query.language = @"en";
    query.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    query.sensor = YES;
    
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        NSLog(@"Places returned %@", places);
        
        self.suggestedAddresses = places;
        [self.suggestedAddressTableView reloadData];
    }];
}

#pragma mark- End of lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



