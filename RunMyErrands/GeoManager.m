//
//  LocationManager.m
//  RottenMangoes
//
//  Created by Steele on 2015-11-10.
//  Copyright © 2015 Steele. All rights reserved.
//

#import "GeoManager.h"


@implementation GeoManager


+ (instancetype)sharedManager {
    static GeoManager *sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[self alloc] init];
    });
    return sharedLocationManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}


-(void)setUpLocationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 10;
        //have to move 100m before location manager checks again
        
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];
        //NSLog(@"new location Manager in startLocationManager");
    }
    
    [_locationManager startUpdatingLocation];
    //NSLog(@"Start Regular Location Manager");
}


- (void)startLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            [self setUpLocationManager];
            
        }else if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)){
            [self setUpLocationManager];
            
        }else{
            
            UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Location services are disabled, Please go into Settings > Privacy > Location to enable them for Play"  message:nil  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];

            //      [self presentViewController:alertController animated:YES completion:nil];

            
        }
    }
    NSLog(@"monitoring available %D",[CLLocationManager isMonitoringAvailableForClass:[GeoManager class]]);
}

-(void)stopLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        if (_locationManager) {
            [_locationManager stopUpdatingLocation];
            //NSLog(@"Stop Regular Location Manager");
        }
    }
}

-(void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    CLLocation * loc = [locations objectAtIndex: [locations count] - 1];
    
    //NSLog(@"Time %@, latitude %+.6f, longitude %+.6f currentLocation accuracy %1.2f loc accuracy %1.2f timeinterval %f",[NSDate date],loc.coordinate.latitude, loc.coordinate.longitude, loc.horizontalAccuracy, loc.horizontalAccuracy, fabs([loc.timestamp timeIntervalSinceNow]));
    
    NSTimeInterval locationAge = -[loc.timestamp timeIntervalSinceNow];
    if (locationAge > 10.0){
        //NSLog(@"locationAge is %1.2f",locationAge);
        return;
    }
    
    if (loc.horizontalAccuracy < 0){
        //NSLog(@"loc.horizontalAccuracy is %1.2f",loc.horizontalAccuracy);
        return;
    }
    
    if (_currentLocation == nil || _currentLocation.horizontalAccuracy >= loc.horizontalAccuracy){
        _currentLocation = loc;
        
        if (loc.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            //[self stopLocationManager];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdated" object:nil];
    }
}

- (void) initiateMap {
    
    //        _currentLocation = [[CLLocation alloc] initWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    //
    //        CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
    //
    //        MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, zoominMapArea, zoominMapArea);
    //
    //        // [_mapView setRegion:adjustedRegion animated:YES];

}



- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    //NSLog(@"didStartMonitoringForRegion for %@", region);
    [_locationManager requestStateForRegion:region];
    NSLog(@"Number of Geo Regions %ld",(long)self.locationManager.monitoredRegions.count);
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
    NSLog(@"monitoringDidFailForRegion %@",error);
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion %@",region.identifier);
    
    [self inLocationNotificationForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //NSLog(@"didExitRegion");
}


-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    //NSLog(@"didDetermineState %li",(long)state);
    
    if (state == 1) {
     //   [self inLocationNotificationForRegion:region];
    }
}

-(void)addTaskLocation:(CLRegion*)region {
    
    [_locationManager startMonitoringForRegion:region];
}



-(void)inLocationNotificationForRegion:(CLRegion *)region {
        
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.regionTriggersOnce = YES;
    localNotification.alertTitle = @"You are in the Area";
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = [NSString stringWithFormat:@" %@", region.identifier];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
