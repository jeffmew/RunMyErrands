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


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    self.locationManager = [GeoManager sharedManager];
    [self.locationManager startLocationManager];
    self.mapView.showsUserLocation = true;
    
    //////Temp for testing
    CLLocationCoordinate2D task01center = CLLocationCoordinate2DMake(37.331820,-122.032180);
    Task *task01 = [[Task alloc]initWithCoordinate:task01center andTitle:@"Banannas" andSubtitle:@"Pick up from whole foods"];
    
    CLLocationCoordinate2D task02center = CLLocationCoordinate2DMake(37.331820,-122.031080);
    Task *task02 = [[Task alloc]initWithCoordinate:task02center andTitle:@"Motor Oil" andSubtitle:@"Pick up from Canadian Tire"];

    CLLocationCoordinate2D task03center = CLLocationCoordinate2DMake(37.331820,-122.031180);
    Task *task03 = [[Task alloc]initWithCoordinate:task03center andTitle:@"TV" andSubtitle:@"Pick up from Best Buy"];

    if (!self.taskArray) {
        self.taskArray = [NSMutableArray array];
    }
   
    [self.taskArray addObject:task01];
    [self.taskArray addObject:task02];
    [self.taskArray addObject:task03];
    
    //    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(37.331820,-122.031180);
    //    CLRegion *task01Region = [[CLCircularRegion alloc]initWithCenter:center radius:1000.0 identifier:@"task01"];
    //
    //    task01Region.notifyOnEntry = YES;
    //    task01Region.notifyOnExit = YES;
    //
    //    Task * testTask = [[Task alloc]initWithCoordinate:center andTitle:@"Test" andSubtitle:@""];
    //
    //
    //    [self.mapView addAnnotation:testTask];
    //
    //    [self.locationManager addTaskLocation:task01Region];
    
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


-(void)mapViewDidFinishLoadingMap:(nonnull MKMapView *)mapView{
    
    for (Task *task in self.taskArray) {
        
        CLLocationCoordinate2D center = task.coordinate;
        CLRegion *taskRegion = [[CLCircularRegion alloc]initWithCenter:center radius:1000.0 identifier:task.title];
        
        [self.mapView addAnnotation:task];
        
        [self.locationManager addTaskLocation:taskRegion];
    }
    
}
- (IBAction)closeMap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    [mapView setRegion:mapRegion animated: YES];
}


@end
