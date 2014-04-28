//
//  GoogleMapViewController.m
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//
#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "GoogleMapViewController.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "PAWSearchRadius.h"
#import "PAWDriverCar.h"
#import <MBProgressHUD.h>

//定義地球1經度為111km
#define KM_PER_ONE_LATITUDE_DELTA	111.0

@interface CoordsList : NSObject
@property(nonatomic, readonly, copy) GMSPath *path;
@property(nonatomic, readonly) NSUInteger target;

- (id)initWithPath:(GMSPath *)path;

- (CLLocationCoordinate2D)next;

@end

static CGFloat kOverlayHeight = 140.0f;

@implementation CoordsList


- (id)initWithPath:(GMSPath *)path {
    if ((self = [super init])) {
        _path = [path copy];
        _target = 0;
    }
    return self;
}

- (CLLocationCoordinate2D)next {
    ++_target;
    if (_target == [_path count]) {
        _target = 0;
    }
    return [_path coordinateAtIndex:_target];
}

@end

@interface GoogleMapViewController (){
    GMSMarker *_stopMarker;
}
@property (nonatomic, strong) PAWSearchRadius *searchRadius;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) GMSMarker *marker1;
@property (nonatomic, strong) GMSMarker *marker2;
@property (nonatomic, strong) GMSMarker *marker3;
@property (nonatomic, strong) GMSMarker *marker4;
@property (nonatomic, strong) GMSMarker *marker5;
@property (nonatomic, strong) GMSMutablePath *coords1;
@property (nonatomic, strong) GMSMutablePath *coords2;
@property (nonatomic, strong) GMSMutablePath *coords3;
@property (nonatomic, strong) GMSMutablePath *coords4;
@property (nonatomic, strong) GMSMutablePath *coords5;

// cars:
@property (nonatomic, strong) NSMutableArray *allCars;

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (void)updatePostsForLocation:(CLLocation *)location withNearbyDistance:(CLLocationAccuracy) filterDistance;

@end

@implementation GoogleMapViewController{
    GMSMapView *mapView_;
    UIView *overlay_;
    BOOL firstLocationUpdate_;
    BOOL isReadLocation_;
    BOOL isDriver;
}
@synthesize driverBtn, passengersBtn, uploadOrStopLocation;
@synthesize titleLabel;
@synthesize searchRadius = _searchRadius;
@synthesize mapPannedSinceLocationUpdate = _mapPannedSinceLocationUpdate;               //地圖平移由於位置更新，地圖會跟著用戶跑？
@synthesize allCars = _allCars;
@synthesize lastRefresh = _lastRefresh;
@synthesize marker1, marker2, marker3, marker4, marker5;
@synthesize coords1, coords2, coords3, coords4, coords5;
@synthesize objects;
@synthesize detailItem = _detailItem;

- (void)setDetailItem:(id)detailItem{
    if (_detailItem != detailItem) {
        NSLog(@"detail = %@", detailItem);
        _detailItem = detailItem;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CGRect frame = CGRectMake(0, 0, 240, 44);
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = @"乘車地點";
    self.navigationItem.titleView = self.titleLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];
    
    // 初始化 iOSLocation
    iOSLocation = [[CLLocationManager alloc] init];
    iOSLocation.delegate = self;
    
    
    //開始計算目前行動裝置所在位置的功能。比較精准耗電。乘客用。
    [iOSLocation startUpdatingLocation];
    
    /* 司機身份調用的方法。調用該方法設備一定要有電話模組。
    [iOSLocation startMonitoringSignificantLocationChanges];
    */
    
    _lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:_lastRefresh forKey:kPAPUserDefaultsHomeFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[[PFUser currentUser] objectForKey:kPAPUserTypeKey] isEqualToString:kPAPUserTypeDriverKey]) {
        isDriver = YES;
        [self driverBtnPressed:nil];
    }else if ([[[PFUser currentUser] objectForKey:kPAPUserTypeKey] isEqualToString:kPAPUserTypePassengerKey]){
        isDriver = NO;
        [self passengersBtn:nil];
    }
    
    //一開始，地圖不會跟著用戶跑。
    self.mapPannedSinceLocationUpdate = NO;
    
    isReadLocation_ = YES;
    isDriver = NO;
    [self.uploadOrStopLocation setTitle:@"關閉更新位置" forState:UIControlStateNormal];
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@YES forKey:kPAPUserIsReadLocationKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (iOSLocation.location.coordinate.latitude && iOSLocation.location.coordinate.longitude) {
//        NSLog(@"精度%f, 緯度%f", iOSLocation.location.coordinate.latitude, iOSLocation.location.coordinate.longitude);
        
        // Do any additional setup after loading the view.
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:iOSLocation.location.coordinate.latitude
                                                                longitude:iOSLocation.location.coordinate.longitude
                                                                     zoom:15];
        
        mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        mapView_.delegate = self;
        mapView_.settings.compassButton = YES;
        mapView_.settings.myLocationButton = YES;
        mapView_.padding = UIEdgeInsetsZero;
        
        // Listen to the myLocation property of GMSMapView.
        [mapView_ addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        
        [mapView_ addSubview:self.driverBtn];
        [mapView_ addSubview:self.passengersBtn];
        [mapView_ addSubview:self.uploadOrStopLocation];
        
        self.view = mapView_;
        
        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            mapView_.myLocationEnabled = YES;
        });
        
        // custom Marker
        _stopMarker = [[GMSMarker alloc] init];
        _stopMarker.title = @"設定上車地點";
        _stopMarker.position = iOSLocation.location.coordinate;
        _stopMarker.appearAnimation = kGMSMarkerAnimationPop;
        _stopMarker.flat = NO;
        _stopMarker.draggable = YES;
        _stopMarker.groundAnchor = CGPointMake(0.5, 0.5);
        _stopMarker.map = mapView_;
        
        
        
        mapView_.selectedMarker = _stopMarker;
        
        //更新地址
        [self uploadAddress:iOSLocation.location.coordinate];
        
        CGSize size = self.view.bounds.size;
        CGRect overlayFrame = CGRectMake(0, mapView_.bounds.size.height, size.width, 0);
        overlay_ = [[UIView alloc] initWithFrame:overlayFrame];
        overlay_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        overlay_.backgroundColor = [UIColor colorWithHue:0.0 saturation:1.0 brightness:1.0 alpha:0.5];
        
        UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
        [send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [send setTitle:@"預約車輛到此處接送" forState:UIControlStateNormal];
        send.backgroundColor = [UIColor blackColor];
        send.frame = CGRectMake(20.0, 80.0, 280.0f, 30.0f);
        [send addTarget:self action:@selector(sendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [overlay_ addSubview:send];
        
        [self.view addSubview:overlay_];
    }else{
        //一秒後啟動doAfterOneSecond
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(viewDidAppear:) userInfo:nil repeats:NO];
    }
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
    
    [iOSLocation stopUpdatingLocation];
    [iOSLocation stopMonitoringSignificantLocationChanges];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NSNotificationCenter notification handlers
- (void)distanceFilterDidChange:(NSNotification *)note {
	CLLocationAccuracy filterDistance = [[[note userInfo] objectForKey:kPAWFilterDistanceKey] doubleValue];
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
	if (self.searchRadius == nil) {
		self.searchRadius = [[PAWSearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
        
//		[self.mapView addOverlay:self.searchRadius];
	} else {
		self.searchRadius.radius = appDelegate.filterDistance;
	}
    
	// Update our pins for the new filter distance:
	[self updatePostsForLocation:appDelegate.currentLocation withNearbyDistance:filterDistance];
    
    //地圖是否跟著用戶跑
    //If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their location at 2x filterDistance
//		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//        
//		[self.mapView setRegion:newRegion animated:YES];
//		self.mapPannedSinceLocationUpdate = NO;
	} else {
		// Just zoom to the new search radius (or maybe don't even do that?)
//		MKCoordinateRegion currentRegion = mapView.region;
//		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//        
//		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
//		[self.mapView setRegion:newRegion animated:YES];
//		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	}
}

- (void)locationDidChange:(NSNotification *)note {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	// If they panned the map since our last location update, don't recenter it.
	if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their new location at 2x filterDistance
//		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//        
//		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
//		[self.mapView setRegion:newRegion animated:YES];
//		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
        
        //        double lat = appDelegate.currentLocation.coordinate.latitude;
        //        double lon = appDelegate.currentLocation.coordinate.longitude;
        //        PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:lat longitude:lon];
        
        //        PFObject *UserLocation = [PFObject objectWithClassName:@"UserLocation"];
        //        [UserLocation setObject:[PFUser currentUser] forKey:@"user"];
        //        [UserLocation setObject:location forKey:@"location"];
        
        //        [UserLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //            //Coding here
        //        }];
        
	} // else do nothing.
    
	// If we haven't drawn the search radius on the map, initialize it.
	if (self.searchRadius == nil) {
		self.searchRadius = [[PAWSearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
//		[self.mapView addOverlay:self.searchRadius];
	} else {
		self.searchRadius.coordinate = appDelegate.currentLocation.coordinate;
	}
    
	// Update the map with new pins cars:
	[self queryForAllPostsNearLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
	// And update the existing pins to reflect any changes in filter distance:
	[self updatePostsForLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
}



#pragma mark - Fetch map pins
//搜尋當前乘車用戶附近所有的其他司機用戶。
- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    
    //進入L2頻道選項，搜尋資料庫類別為Activity，其中photo資料要等於QuestionID，type資料要等於"comment"。
    
//    [self startSignificantChangeUpdates];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set the map's region centered on their new location at 2x filterDistance
//    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 120.0f)];
//    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//    [self.mapView setRegion:newRegion animated:YES];
//	self.mapPannedSinceLocationUpdate = NO;
//    self.mapView.zoomEnabled = NO;              //允許縮放地圖與否
//    self.mapView.scrollEnabled = NO;            //允許拖曳捲動地圖與否。
//    self.mapView.delegate = self;
//    self.mapView.showsUserLocation = YES;            //用戶當前位置顯示
    
    //    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, nearbyDistance / 2, nearbyDistance / 2);
    //    [self.mapView setRegion:newRegion animated:YES];
    
    
	PFQuery *query = [PFUser query];
    
	if (currentLocation == nil) {
		NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
	}
    
	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.allCars count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
	// Query for posts sort of kind of near our current location.
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
	[query whereKey:kPAPUserLocationLocationKey nearGeoPoint:point withinKilometers:kPAWWallPostMaximumSearchDistance];
//	[query includeKey:kPAPPhotoUserKey];
	query.limit = kPAWMapCarsSearch;
    
    //搜尋24小時以內的資料
    NSDate *twoWeeksBeforeNow = [NSDate dateWithTimeIntervalSinceReferenceDate:([NSDate timeIntervalSinceReferenceDate] - 24*60*60 * 1)];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:twoWeeksBeforeNow];
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"error in geo query!"); // todo why is this ever happening?
		} else {
			// We need to make new post objects from objects,
			// and update allCars and the map to reflect this new array.
			// But we don't want to remove all annotations from the mapview blindly,
			// so let's do some work to figure out what's new and what needs removing.
            
			// 1. Find genuinely new posts:
			NSMutableArray *newCars = [[NSMutableArray alloc] initWithCapacity:kPAWMapCarsSearch];
			// (Cache the objects we make for the search in step 2:)
			NSMutableArray *allNewCars = [[NSMutableArray alloc] initWithCapacity:kPAWMapCarsSearch];
			for (PFUser *object in objects) {
				PAWDriverCar *newCar = [[PAWDriverCar alloc] initWithPFUser:object];
				[allNewCars addObject:newCar];
				BOOL found = NO;
				for (PAWDriverCar *currentCar in _allCars) {
					if ([newCar equalToCar:currentCar]) {
						found = YES;
					}
				}
				if (!found) {
					[newCars addObject:newCar];
				}
			}
			// newPosts now contains our new objects.
            
			// 2. Find posts in allPosts that didn't make the cut.
			NSMutableArray *carsToRemove = [[NSMutableArray alloc] initWithCapacity:kPAWMapCarsSearch];
			for (PAWDriverCar *currentCar in _allCars) {
				BOOL found = NO;
				// Use our object cache from the first loop to save some work.
				for (PAWDriverCar *allNewCar in allNewCars) {
					if ([currentCar equalToCar:allNewCar]) {
						found = YES;
					}
				}
				if (!found) {
					[carsToRemove addObject:currentCar];
				}
			}
			// postsToRemove has objects that didn't come in with our new results.
            
			// 3. Configure our new posts; these are about to go onto the map.
			for (PAWDriverCar *newCar in newCars) {
				CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newCar.coordinate.latitude longitude:newCar.coordinate.longitude];
				// if this post is outside the filter distance, don't show the regular callout.
				CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
				[newCar setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
				// Animate all pins after the initial load:
//				newCar.animatesDrop = mapPinsPlaced;
			}
            
			// At this point, newAllPosts contains a new list of post objects.
			// We should add everything in newPosts to the map, remove everything in postsToRemove,
			// and add newPosts to allPosts.
            // 要用Google Map SDK的方式移除與新增marker
//			[mapView_ removeAnnotations:carsToRemove];
//			[mapView_ addAnnotations:newCars];
            
            NSLog(@"newPosts = %@", newCars);
			[_allCars addObjectsFromArray:newCars];
			[_allCars removeObjectsInArray:carsToRemove];
            
            // This method is called every time objects are loaded from Parse via the PFQuery
            // This method is called before a PFQuery is fired to get more objects
            _lastRefresh = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:_lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
		}
	}];
}

// When we update the search filter distance, we need to update our pins' titles to match.
- (void)updatePostsForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
    // 更新地圖上的車輛。
    
	for (PAWDriverCar *car in _allCars) {
		CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:car.coordinate.latitude longitude:car.coordinate.longitude];
		// if this post is outside the filter distance, don't show the regular callout.
		CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
		if (distanceFromCurrent > nearbyDistance) { // Outside search radius
			[car setTitleAndSubtitleOutsideDistance:YES];
//			[mapView viewForAnnotation:car];
//			[(MKPinAnnotationView *) [mapView viewForAnnotation:car] setPinColor:post.pinColor];
		} else {
			[car setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
//			[mapView viewForAnnotation:car];
//			[(MKPinAnnotationView *) [mapView viewForAnnotation:car] setPinColor:post.pinColor];
		}
	}
}

#pragma mark - CLLocationManagerDelegate methods and helpers
- (void)startSignificantChangeUpdates {
	if (nil == iOSLocation) {
		iOSLocation = [[CLLocationManager alloc] init];
	}
    
	iOSLocation.delegate = self;
    [iOSLocation startMonitoringSignificantLocationChanges];
    
	iOSLocation.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	iOSLocation.distanceFilter = kCLLocationAccuracyNearestTenMeters;
	[iOSLocation startUpdatingLocation];
    
    
    
	CLLocation *currentLocation = iOSLocation.location;
	if (currentLocation) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.currentLocation = currentLocation;
        
        
        //儲存當前用戶位置
        PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
        //儲存用戶所在地經緯度
        PFUser *currentUserData = [PFUser currentUser];
        if (location.latitude && location.longitude ) {
            [currentUserData setObject:location forKey:@"location"];
        }
        //儲存用戶資料
        [currentUserData saveEventually];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			// Re-enable the post button if it was disabled before.
			[iOSLocation startUpdatingLocation];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
        {{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Taxi 無法訪問當前位置。\n\n同意Taxi訪問您當前位子。" message:nil delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alertView show];
        }}
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"btn = %i", buttonIndex);
    //Code.....
    switch (buttonIndex) {
        case 0:
            NSLog(@"確定取消");
            break;
        case 1:
            NSLog(@"確定接送user_%@", _detailItem);
            NSMutableSet *channelSet = [NSMutableSet setWithCapacity:1];
            
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", _detailItem];
            [channelSet addObject:privateChannelName];
            
            //收到的推播訊息範例： "Chen: Test"
            NSString *alert = [NSString stringWithFormat:@"%@將去接送", [[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]];
            
            // make sure to leave enough space for payload overhead
            if (alert.length > 100) {
                alert = [alert substringToIndex:99];
                alert = [alert stringByAppendingString:@"…"];
            }
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  alert, kAPNSAlertKey,                                                 //"推播顯示訊息內容", @"alert"
                                  kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey, //"a" , "p"
                                  kPAPPushPayloadActivityTakeUpKey, kPAPPushPayloadActivityTypeKey,    //"t" , "t" //送出答應接送
                                  [[PFUser currentUser] objectId], @"du",                               //“司機用戶ID” , "du"
                                  @"Increment",kAPNSBadgeKey,
                                  nil];
            PFPush *push = [[PFPush alloc] init];
            [push setChannels:[channelSet allObjects]];
            [push setData:data];
            [push sendPushInBackground];
            
//            NSURL *prefsURL = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
//            
//            if ([[UIApplication sharedApplication] canOpenURL:prefsURL]) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
//            } else {
//                // Can't redirect user to settings, display alert view
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
//                NSLog(@"無法開啓喔");
//            }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // If it's a relatively recent event, turn off updates to save power
    // 如果它是一個相對較新的事件，關閉更新，以節省電力
    CLLocation *location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        // 如果該事件是最新的，用它做什麼。
        NSLog(@"緯度:%f, 經度:%f, 高度:%f", location.coordinate.latitude, location.coordinate.longitude, location.altitude);
        
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLocation:location];
        
        if (currentPoint.latitude && currentPoint.longitude) {
            PFObject *currentLocation = [PFObject objectWithClassName:kPAPUserLocationClassKey];
            [currentLocation setObject:[PFUser currentUser] forKey:kPAPUserLocationUserKey];
            [currentLocation setObject:currentPoint forKey:kPAPUserLocationLocationKey];
            
            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [ACL setPublicReadAccess:YES];
            currentLocation.ACL = ACL;
            
            [currentLocation saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"記錄用戶經緯度");
                }
            }];
            
            [[PFUser currentUser] setObject:currentPoint forKey:kPAPUserLocationLocationKey];
            [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"用戶最新位置已經上傳");
                }
            }];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
    
	if (error.code == kCLErrorDenied) {
		[iOSLocation stopUpdatingLocation];
        [iOSLocation stopMonitoringSignificantLocationChanges];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:@"請重新設定同意啟用位置服務"
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
        
	} else if (error.code == kCLErrorLocationUnknown){
        
    }else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:@"檢索位置發生錯誤"
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
//    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
//    NSLog(@"keyPath = %@, Object = %@, context = %@", keyPath, object, context);
    
//    mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
    
    //更新地址
//    [self uploadAddress:location.coordinate];
    
//    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLocation:location];
//    PFObject *currentLocation = [PFObject objectWithClassName:kPAPUserLocationClassKey];
//    [currentLocation setObject:[PFUser currentUser] forKey:kPAPUserLocationUserKey];
//    [currentLocation setObject:currentPoint forKey:kPAPUserLocationLocationKey];
//    
//    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
//    [ACL setPublicReadAccess:YES];
//    currentLocation.ACL = ACL;
//    
//    [currentLocation saveEventually:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"儲存經緯度");
//        }
//    }];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    _stopMarker.position = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    [mapView_ clear];
    if (isDriver) {
        
    }else{
        _stopMarker.map = mapView_;
    }
    
    _stopMarker.position = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
    //開始更新地址
    [self uploadAddress:_stopMarker.position];
    
    //開始撈取附近的車輛Driver
    PFQuery *queryDriver = [PFUser query];
    [queryDriver whereKey:kPAPUserTypeKey equalTo:kPAPUserTypeDriverKey];
    PFGeoPoint *nearPoint = [PFGeoPoint geoPointWithLatitude:position.target.latitude longitude:position.target.longitude];
    [queryDriver whereKey:kPAPUserLocationLocationKey nearGeoPoint:nearPoint withinKilometers:10.0f];
    
    queryDriver.limit = kPAWMapCarsSearch;
    
    //搜尋1小時以內的資料
//    NSDate *tenMinsBeforeNow = [NSDate dateWithTimeIntervalSinceReferenceDate:([NSDate timeIntervalSinceReferenceDate] - 60*60 * 1)];
//    [queryDriver whereKey:@"createdAt" greaterThanOrEqualTo:tenMinsBeforeNow];
    
    [queryDriver orderByDescending:@"updatedAt"];
    [queryDriver setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [queryDriver findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"driver count = %i", objects.count);
        
        self.objects = objects;
        
        if (objects.count > 0) {
            int i;
            NSLog(@"driver count 1");
            for (i= 1; i<= objects.count; i++) {
                NSLog(@"driver count 2 i = %i", i);
                PFUser *DriverUser = [objects objectAtIndex:i-1];
                [self queryForCarCoord:DriverUser AndTag:i];
            }
        }
    }];
    
    mapView_.selectedMarker = _stopMarker;
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    UIEdgeInsets padding = mapView_.padding;
    
    
    [UIView animateWithDuration:1.0 animations:^{
        CGSize size = self.view.bounds.size;
        if (padding.bottom == 0.0f) {
//            overlay_.frame = CGRectMake(0, size.height - kOverlayHeight, size.width, kOverlayHeight);
//            mapView_.padding = UIEdgeInsetsMake(0, 0, kOverlayHeight, 0);
        } else {
            overlay_.frame = CGRectMake(0, mapView_.bounds.size.height, size.width, 0);
            mapView_.padding = UIEdgeInsetsZero;
        }
    }];
    
    NSLog(@"tap map");
    mapView_.selectedMarker = _stopMarker;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    NSLog(@"tap map 2");
    mapView_.selectedMarker = _stopMarker;
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    NSLog(@"did tap info window of marker = %@", marker.title);
    if ([marker.title isEqualToString:@"設定上車地點"]) {
        //點擊設定上車地點之後，出現發送通知按鈕
        
        UIEdgeInsets padding = mapView_.padding;
        
        [UIView animateWithDuration:1.0 animations:^{
            CGSize size = self.view.bounds.size;
            if (padding.bottom == 0.0f) {
                overlay_.frame = CGRectMake(0, size.height - kOverlayHeight, size.width, kOverlayHeight);
                mapView_.padding = UIEdgeInsetsMake(0, 0, kOverlayHeight, 0);
            } else {
                overlay_.frame = CGRectMake(0, mapView_.bounds.size.height, size.width, 0);
                mapView_.padding = UIEdgeInsetsZero;
            }
        }];
    }
}


#pragma mark - MarkerLayer & AnimateToNextCoord
- (void)queryForCarCoord:(PFUser *)Driver AndTag:(int)Tag{
//    GMSMutablePath *coords;
//    __block GMSMarker *marker;
    
    
    
    PFQuery *userLocationQuery = [PFQuery queryWithClassName:kPAPUserLocationClassKey];
    [userLocationQuery whereKey:kPAPUserLocationUserKey equalTo:Driver];
    
    userLocationQuery.limit = kPAWMapCarsSearch;
    
    //搜尋60分鐘以內的資料
    NSDate *tenMinsBeforeNow = [NSDate dateWithTimeIntervalSinceReferenceDate:([NSDate timeIntervalSinceReferenceDate] - 60*60 * 1)];
    [userLocationQuery whereKey:@"createdAt" greaterThanOrEqualTo:tenMinsBeforeNow];
    
    [userLocationQuery orderByDescending:@"updatedAt"];
    [userLocationQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [userLocationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"line = %i", objects.count);
        
        if (objects.count > 0) {
            if (Tag == 1) {
                // Create a plane that flies to several airports around western Europe.
                self.coords1 = nil;
                self.coords1 = [GMSMutablePath path];
                int i;
                for (i=1; i<=objects.count; i++) {
                    PFObject *location = [objects objectAtIndex:i-1];
                    PFGeoPoint *locationGeo = [location objectForKey:kPAPUserLocationLocationKey];
                    [self.coords1 addLatitude:locationGeo.latitude longitude:locationGeo.longitude];
                }
                
                self.marker1.map = nil;
                self.marker1 = [GMSMarker markerWithPosition:[self.coords1 coordinateAtIndex:0]];
                self.marker1.icon = [UIImage imageNamed:@"aeroplane"];
                self.marker1.groundAnchor = CGPointMake(0.5f, 0.5f);
                self.marker1.flat = YES;                                  // 方向
                self.marker1.map = mapView_;
                self.marker1.userData = [[CoordsList alloc] initWithPath:self.coords1];
                [self animateToNextCoord:self.marker1];
            }else if (Tag == 2){
                // Create a plane that flies to several airports around western Europe.
                self.coords2 = nil;
                self.coords2 = [GMSMutablePath path];
                int i;
                for (i=1; i<=objects.count; i++) {
                    PFObject *location = [objects objectAtIndex:i-1];
                    PFGeoPoint *locationGeo = [location objectForKey:kPAPUserLocationLocationKey];
                    [self.coords2 addLatitude:locationGeo.latitude longitude:locationGeo.longitude];
                }
                
                self.marker2.map = nil;
                self.marker2 = [GMSMarker markerWithPosition:[self.coords2 coordinateAtIndex:0]];
                self.marker2.icon = [UIImage imageNamed:@"aeroplane"];
                self.marker2.groundAnchor = CGPointMake(0.5f, 0.5f);
                self.marker2.flat = YES;                                  // 方向
                self.marker2.map = mapView_;
                self.marker2.userData = [[CoordsList alloc] initWithPath:self.coords2];
                [self animateToNextCoord:self.marker2];
            }else if (Tag == 3){
                // Create a plane that flies to several airports around western Europe.
                self.coords3 = nil;
                self.coords3 = [GMSMutablePath path];
                int i;
                for (i=1; i<=objects.count; i++) {
                    PFObject *location = [objects objectAtIndex:i-1];
                    PFGeoPoint *locationGeo = [location objectForKey:kPAPUserLocationLocationKey];
                    [self.coords3 addLatitude:locationGeo.latitude longitude:locationGeo.longitude];
                }
                
                self.marker3.map = nil;
                self.marker3 = [GMSMarker markerWithPosition:[self.coords3 coordinateAtIndex:0]];
                self.marker3.icon = [UIImage imageNamed:@"aeroplane"];
                self.marker3.groundAnchor = CGPointMake(0.5f, 0.5f);
                self.marker3.flat = YES;                                  // 方向
                self.marker3.map = mapView_;
                self.marker3.userData = [[CoordsList alloc] initWithPath:self.coords3];
                [self animateToNextCoord:self.marker3];
            }else if (Tag == 4){
                // Create a plane that flies to several airports around western Europe.
                self.coords4 = nil;
                self.coords4 = [GMSMutablePath path];
                int i;
                for (i=1; i<=objects.count; i++) {
                    PFObject *location = [objects objectAtIndex:i-1];
                    PFGeoPoint *locationGeo = [location objectForKey:kPAPUserLocationLocationKey];
                    [self.coords4 addLatitude:locationGeo.latitude longitude:locationGeo.longitude];
                }
                
                self.marker4.map = nil;
                self.marker4 = [GMSMarker markerWithPosition:[self.coords4 coordinateAtIndex:0]];
                self.marker4.icon = [UIImage imageNamed:@"aeroplane"];
                self.marker4.groundAnchor = CGPointMake(0.5f, 0.5f);
                self.marker4.flat = YES;                                  // 方向
                self.marker4.map = mapView_;
                self.marker4.userData = [[CoordsList alloc] initWithPath:self.coords4];
                [self animateToNextCoord:self.marker4];
            }else if (Tag == 5){
                // Create a plane that flies to several airports around western Europe.
                self.coords5 = nil;
                self.coords5 = [GMSMutablePath path];
                int i;
                for (i=1; i<=objects.count; i++) {
                    PFObject *location = [objects objectAtIndex:i-1];
                    PFGeoPoint *locationGeo = [location objectForKey:kPAPUserLocationLocationKey];
                    [self.coords5 addLatitude:locationGeo.latitude longitude:locationGeo.longitude];
                }
                
                self.marker5.map = nil;
                self.marker5 = [GMSMarker markerWithPosition:[self.coords5 coordinateAtIndex:0]];
                self.marker5.icon = [UIImage imageNamed:@"aeroplane"];
                self.marker5.groundAnchor = CGPointMake(0.5f, 0.5f);
                self.marker5.flat = YES;                                  // 方向
                self.marker5.map = mapView_;
                self.marker5.userData = [[CoordsList alloc] initWithPath:self.coords5];
                [self animateToNextCoord:self.marker5];
            }
//            [MBProgressHUD hideHUDForView:mapView_ animated:YES];
        }
    }];
}


- (void)animateToNextCoord:(GMSMarker *)marker {
    CoordsList *coords = marker.userData;
    CLLocationCoordinate2D coord = [coords next];
    CLLocationCoordinate2D previous = marker.position;
    
    CLLocationDirection heading = GMSGeometryHeading(previous, coord);
    CLLocationDistance distance = GMSGeometryDistance(previous, coord);
    
    // Use CATransaction to set a custom duration for this animation. By default, changes to the
    // position are already animated, but with a very short default duration. When the animation is
    // complete, trigger another animation step.
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:(distance / (0.05 * 1000))];  // custom duration, 0.05km/sec
    
    __weak GoogleMapViewController *weakSelf = self;
    [CATransaction setCompletionBlock:^{
//        [weakSelf animateToNextCoord:marker]; //重複循環
    }];
    
    marker.position = coord;
    
    [CATransaction commit];
    
    // If this marker is flat, implicitly trigger a change in rotation, which will finish quickly.
    if (marker.flat) {
        marker.rotation = heading;
    }
}




#pragma mark - Actions
- (IBAction)driverBtnPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:kPAPUserTypeDriverKey forKey:kPAPUserTypeKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
    _stopMarker.map = nil;
    isDriver = YES;
    [iOSLocation startMonitoringSignificantLocationChanges];
    [iOSLocation stopUpdatingLocation];
}

- (IBAction)passengersBtn:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:kPAPUserTypePassengerKey forKey:kPAPUserTypeKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
    _stopMarker.map = (GMSMapView *)self.view;
    mapView_.selectedMarker = _stopMarker;
    isDriver = NO;
    [iOSLocation startUpdatingLocation];
    [iOSLocation stopMonitoringSignificantLocationChanges];
}

- (IBAction)uploadOrStopLocationBtnPressed:(id)sender {
    if (isReadLocation_) {
        isReadLocation_ = NO;
        [self.uploadOrStopLocation setTitle:@"啟動更新位置" forState:UIControlStateNormal];
        
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setObject:@NO forKey:kPAPUserIsReadLocationKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        currentUser.ACL = ACL;
        
        [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
            
        }];
    }else{
        isReadLocation_ = YES;
        [self.uploadOrStopLocation setTitle:@"關閉更新位置" forState:UIControlStateNormal];
        
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setObject:@YES forKey:kPAPUserIsReadLocationKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        currentUser.ACL = ACL;
        
        [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
            
        }];
    }
}

- (void)uploadAddress:(CLLocationCoordinate2D)coor {
    /*
     分析google地理位置
     */
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%f,%f&sensor=true",coor.latitude, coor.longitude];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *jsonStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *resultDict = [jsonStr objectFromJSONString];
    if ([[resultDict objectForKey:@"status"] isEqualToString:@"OK"]) {
        NSDictionary *dict = [[resultDict objectForKey:@"results"] objectAtIndex:0];
        NSString *formatted_address = [dict objectForKey:@"formatted_address"];
        
        self.titleLabel.text = formatted_address;
    }
}

//登出
- (IBAction)logoutBtnPressed:(id)sender {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
}

- (void)sendBtnPressed:(id)sender{
    NSLog(@"sendBtnPressed. 發送推播給司機= %@", self.objects);
    //先找出距離乘客最近的五輛車（五位司機會員）。
    
    self.hud = [MBProgressHUD showHUDAddedTo:mapView_ animated:YES];
    [self.hud setLabelText:@"預約車輛中,請稍後..."];
    [self.hud setDimBackground:YES];
    
    NSMutableSet *channelSet = [NSMutableSet setWithCapacity:self.objects.count];
    
    // 設定這個推播訊息要被傳送的人們，當然不包含當前用戶。
    // set up this push notification to be sent to all commenters, excluding the current  user
    for (PFUser *author in self.objects) {
        NSString *privateChannelName = [author objectForKey:kPAPUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length != 0 && ![[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            NSLog(@"PhotoDetailsView ChannelSet PrivateChannelName = %@", privateChannelName);
            [channelSet addObject:privateChannelName];
        }
    }
    
    if (channelSet.count > 0) {
        //收到的推播訊息範例： "Chen: Test"
        NSString *alert = [NSString stringWithFormat:@"%@請求接送", [[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]];
        
        // make sure to leave enough space for payload overhead
        if (alert.length > 100) {
            alert = [alert substringToIndex:99];
            alert = [alert stringByAppendingString:@"…"];
        }
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              alert, kAPNSAlertKey,                                             //"推播顯示訊息內容", @"alert"
                              kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey, //"a" , "p"
                              kPAPPushPayloadActivitySendPlzKey, kPAPPushPayloadActivityTypeKey,    //"s" , "t" //送出請求接送
                              [[PFUser currentUser] objectId], @"pu",                             //“乘客用戶ID” , "pu"
                              @"Increment",kAPNSBadgeKey,
                              nil];
        PFPush *push = [[PFPush alloc] init];
        [push setChannels:[channelSet allObjects]];
        [push setData:data];
        [push sendPushInBackground];
        
    }
}


- (void)getSendPlzAlert{
    //司機端接收到通知
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否接此乘客" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alertView show];
}

- (void)getTakeOutAlert:(id)passengerId{
    [MBProgressHUD hideHUDForView:mapView_ animated:YES];
    //乘客端接收到通知
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"司機%@將要來接送", _detailItem] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


@end
