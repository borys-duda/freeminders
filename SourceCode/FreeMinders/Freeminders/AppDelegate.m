//
//  AppDelegate.m
//  Freeminders
//
//  Created by Spencer Morris on 4/4/14.
//  Copyright (c) 2014 Freeminders. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#import "Utils.h"
#import "Const.h"
#import "UserData.h"
#import "Reminder.h"
#import "YahooError.h"
#import "WeatherData.h"
#import "YahooChannel.h"
#import "YahooQuery.h"
#import "YahooResults.h"
#import "WeatherCondition.h"
#import "WeatherForcast.h"
#import "BackgroundFetchManager.h"
#import "StoreHelper.h"

@interface AppDelegate ()

@property (strong, nonatomic) RKObjectManager *manager;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Const initialize];
    [self setupThirdPartyServices:launchOptions];
    [self setupUI];
    
    // Background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Background location
    if ([PFUser currentUser]) {
        [self setupLocationManager];
    }
    // register for push notifications

    // None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // The following line must only run under iOS 8. This runtime check prevents
    // it from running if it doesn't exist (such as running under iOS 7 or earlier).
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    // use registerForRemoteNotifications
#endif
    
    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    // store kit
//    [StoreHelper sharedInstance];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)setupThirdPartyServices:(NSDictionary *)launchOptions
{
    // SETUP PARSE
//    [Parse setApplicationId:@"1u1Bm64sm45gIS5dpQ6sX5dbkvqEok5MlgQF8ra5"
//                  clientKey:@"WedFBQIHIrzs0gppoV7aeQWU62Rs80pcQ2FfUEmM"];
    [Parse setApplicationId:@"tFABB2RCAMsZW2PPzXhhk35199GfhAzkwHFKAb4z"
                  clientKey:@"gWhTYD2Ivhzp56OCv4ocOdjLHRfbAC1eirCdQdJJ"];
    [PFFacebookUtils initializeFacebook];
    [Utils registerAllParseClasses];
    
    PFACL *defaultACL = [PFACL ACL];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    // SETUP RESTKIT
    [self setupRestkit];
}

- (void)setupUI
{
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithWhite:0.9 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:FONT_HELVETICA_NEUE_MEDIUM size:18], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:COLOR_FREEMINDER_BLUE];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark- Location services

- (void)setupLocationManager
{
    NSLog(@"SETUP LOCATION MANAGER");
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_SHOULD_RUN_LOCATION_UPDATES]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.firstObject;
//    NSLog(@"BACKGROUND LOCATION UPDATE TO LAT: %f LNG: %f", location.coordinate.latitude, location.coordinate.longitude);
    [UserData instance].location = location;
    if ([PFUser currentUser]) {
        [[BackgroundFetchManager sharedInstance] performLoadTasks];
    }
}

#pragma mark- Push notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"NOTIFICATION RECEIVED");
    NSString *taskId = [notification.userInfo objectForKey:@"taskId"];
    if (taskId)
        [self handlePushNotificationClickedWithTaskId:taskId];
}

- (void)handlePushNotificationClickedWithTaskId:(NSString *)taskId
{
    NSMutableArray *mutablePendingTasks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_TAPPED_TASK_ID_ARRAY] mutableCopy];
    if (! mutablePendingTasks) mutablePendingTasks = [[NSMutableArray alloc] init];
    if (! [mutablePendingTasks containsObject:taskId]) {
        [mutablePendingTasks addObject:taskId];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[mutablePendingTasks copy] forKey:USER_DEFAULTS_TAPPED_TASK_ID_ARRAY];
    
    if ([PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:[Reminder parseClassName]];
        [query whereKey:@"objectId" equalTo:taskId];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"TASK LOADED");
            Reminder *task = nil;
            if ([objects.firstObject isKindOfClass:[Reminder class]] || objects.count == 0)
                task = [objects firstObject];
            
            if (task) {
                task.lastNotificationDate = [NSDate date];
                [task setAllStepsChecked:NO];
                [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:LocalNotificationRecieved object:nil userInfo:nil];
                }];
            }
        }];
    }
}

#pragma mark- Background tasks

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ([PFUser currentUser]) {
        [self setupLocationManager];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark- Other methods

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    // Locate the receipt
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    
    // Test whether the receipt is present at the above path
    if(! [[NSFileManager defaultManager] fileExistsAtPath:[receiptURL path]])
    {
        // Validation fails
        exit(173);
    }
    
    // Proceed with further receipt validation steps
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

//    
//    for (UIWindow* window in [UIApplication sharedApplication].windows){
//        for (UIView *subView in [window subviews]){
//            for(UIView *subViews in [subView subviews])
//            {
//            if ([subViews isKindOfClass:[UIAlertView class]]) {
//                NSLog(@"has AlertView");
//            }else {
//                NSLog(@"No AlertView");
//            }
//            }
//        }
//    }
//    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Utils updateUserLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupRestkit
{
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://query.yahooapis.com"]];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    self.manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    
    /**
     * SIMPLE ENTITIES MAPPING:
     */
    
    // Forcast mapping:
    RKObjectMapping *forcastMapping = [RKObjectMapping mappingForClass:[WeatherForcast class]];
    [forcastMapping addAttributeMappingsFromDictionary:
     @{
       @"code":         @"code",
       @"text":         @"text",
       @"date":         @"date",
       @"low":          @"low",
       @"high":         @"high",
       @"day":          @"day"
       }];
    
    // Condition mapping:
    RKObjectMapping *conditionMapping = [RKObjectMapping mappingForClass:[WeatherCondition class]];
    [conditionMapping addAttributeMappingsFromDictionary:
     @{
       @"code":         @"code",
       @"text":         @"text",
       @"date":         @"date",
       @"temp":         @"temp"
       }];
    
    // Error mapping:
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[YahooError class]];
    [errorMapping addAttributeMappingsFromDictionary:
     @{
       @"description":      @"description"
       }];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"error" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [[RKObjectManager sharedManager] addResponseDescriptor:errorResponseDescriptor];
    
    /**
     * COMPLEX ENTITIES MAPPING:
     */
    
    // WeatherData mapping:
    RKObjectMapping *weatherMapping = [RKObjectMapping mappingForClass:[WeatherData class]];
    [weatherMapping addAttributeMappingsFromDictionary:
     @{
       @"title":            @"title"
       }];
    [weatherMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"condition" toKeyPath:@"condition" withMapping:conditionMapping]];
    [weatherMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"forecast" toKeyPath:@"forecast" withMapping:forcastMapping]];
    
    // Channel mapping:
    RKObjectMapping *channelMapping = [RKObjectMapping mappingForClass:[YahooChannel class]];
    [channelMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"item" toKeyPath:@"weatherData" withMapping:weatherMapping]];
    
    // Results mapping:
    RKObjectMapping *resultsMapping = [RKObjectMapping mappingForClass:[YahooResults class]];
    [resultsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"channel" toKeyPath:@"channel" withMapping:channelMapping]];
    
    // Query mapping:
    RKObjectMapping *queryMapping = [RKObjectMapping mappingForClass:[YahooQuery class]];
    [queryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"results" toKeyPath:@"results" withMapping:resultsMapping]];
    RKResponseDescriptor *yahooResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:queryMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"query" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:yahooResponseDescriptor];
    
}

@end
