//
//  MapViewController.m
//  RunMyErrandsMaps
//
//  Created by Steele on 2015-11-16.
//  Copyright © 2015 Steele. All rights reserved.
//

#import "MapViewController.h"
#import "GeoManager.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) GeoManager *locationManager;
@property (nonatomic) BOOL didLoadLocations;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self allowNotifications];
    
    self.mapView.delegate = self;
    
    self.didLoadLocations = NO;
    
    self.locationManager = [GeoManager sharedManager];
    [self.locationManager startLocationManager];
    self.mapView.showsUserLocation = true;
    
    //////Temp for testing
    CLLocationCoordinate2D task01center = CLLocationCoordinate2DMake(37.331820,-122.032180);
    Task *task01 = [[Task alloc]initWithCoordinate:task01center andTitle:@"Banannas" andSubtitle:@"Pick up from whole foods"];
    
    CLLocationCoordinate2D task02center = CLLocationCoordinate2DMake(49.281894626184886,-123.10850102985563);
    Task *task02 = [[Task alloc]initWithCoordinate:task02center andTitle:@"Study" andSubtitle:@"Lighthouse Labs"];
    
    CLLocationCoordinate2D task03center = CLLocationCoordinate2DMake(37.331820,-122.031180);
    Task *task03 = [[Task alloc]initWithCoordinate:task03center andTitle:@"TV" andSubtitle:@"Pick up from Best Buy"];
    
    if (!self.taskArray) {
        self.taskArray = [NSMutableArray array];
    }
    
    [self.taskArray addObject:task01];
    [self.taskArray addObject:task02];
    //    [self.taskArray addObject:task03];
    
    //    task01Region.notifyOnEntry = YES;
    //    task01Region.notifyOnExit = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dropPinGesture:(UILongPressGestureRecognizer *)sender {
    
    if ([sender state] == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        Task *touchTask = [[Task alloc]initWithCoordinate:touchMapCoordinate andTitle:@"picker" andSubtitle:@""];
        
        if (!self.taskArray) {
            self.taskArray = [NSMutableArray new];
        }
        
        [self.taskArray addObject:touchTask];
        [self.delegate addTasksArray:self.taskArray];
        
        [self.mapView addAnnotation:touchTask];
    }
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
    
    
    if (!self.didLoadLocations) {
        
        self.didLoadLocations = YES;
        for (Task *task in self.taskArray) {
            
            CLLocationCoordinate2D center = task.coordinate;
            CLRegion *taskRegion = [[CLCircularRegion alloc]initWithCenter:center radius:500.0 identifier:task.title];
            
            [self.mapView addAnnotation:task];
            
            [self.locationManager addTaskLocation:taskRegion];
        }
    }
    
}


-(void)mapViewDidFinishLoadingMap:(nonnull MKMapView *)mapView{
    
    
}


- (IBAction)closeMap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    MKCoordinateRegion mapRegion;
//    mapRegion.center = mapView.userLocation.coordinate;
//    mapRegion.span.latitudeDelta = 0.2;
//    mapRegion.span.longitudeDelta = 0.2;
//    [mapView setRegion:mapRegion animated: YES];
}


-(void)allowNotifications {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
}


@end
