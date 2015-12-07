//
//  MapViewController.m
//  RunMyErrandsMaps
//
//  Created by Steele on 2015-11-16.
//  Copyright © 2015 Steele. All rights reserved.
//

#import "MainMapViewController.h"
#import "DetailViewController.h"
#import "GeoManager.h"
#import <Parse/Parse.h>

@interface MainMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) GeoManager *locationManager;
@property (nonatomic) BOOL didLoadLocations;


@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.didLoadLocations = NO;
    
    self.locationManager = [GeoManager sharedManager];
    [self.locationManager startLocationManager];
    self.mapView.showsUserLocation = true;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self loadTaskObjects];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) loadTaskObjects {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFQuery *query = [PFQuery queryWithClassName:@"Team"];
        [query whereKey:@"team" equalTo:[[PFUser currentUser] objectId]];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                
                NSArray *tasks = object[@"tasks"];
                
                PFQuery *taskQuery = [PFQuery queryWithClassName:@"Task"];
                [taskQuery whereKey:@"objectId" containedIn:tasks];
                [taskQuery addAscendingOrder:@"isComplete"];
                [taskQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    } else {
                        self.taskArray = objects;
                        
                        for (Task *taskFromArray in self.taskArray) {
                            [taskFromArray updateCoordinate];
                        }
                        
                        [self trackGeoRegions];
                        [self reloadAnnotations];
                    }
                }];
            }
        }];
    }
}


#pragma mark - Geo

-(void)trackGeoRegions {
    
    [self.locationManager removeAllTaskLocation];
    for (Task *task in self.taskArray) {
        CLLocationCoordinate2D center = task.coordinate;
        CLRegion *taskRegion = [[CLCircularRegion alloc]initWithCenter:center radius:200.0 identifier:[NSString stringWithFormat:@"%@\n%@",task.title,task.subtitle]];
        taskRegion.notifyOnEntry = YES;
        
        //Determine if to track the task location.
        if (![task.isComplete boolValue]) {
            [self.locationManager addTaskLocation:taskRegion];
        }else {
            [self.locationManager removeTaskLocation:taskRegion];
        }
    }
}




-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.didLoadLocations) {
        self.didLoadLocations = YES;
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.05;
        mapRegion.span.longitudeDelta = 0.05;
        [mapView setRegion:mapRegion animated: YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:[Task class]]) {
        return nil;
    }
    Task *task = (Task *) annotation;
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomDetailAnno"];
    
    if (!annotationView) {
        annotationView = task.annoDetailView;
    }else {
        annotationView.annotation = annotation;
    }
    return annotationView;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[Task class]]) {
        [self performSegueWithIdentifier:@"showDetailFromMap" sender:(Task *) view.annotation];
    }
}

-(void)reloadAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (Task *task in self.taskArray) {
        //Determine if to track the task location.
        if (![task.isComplete boolValue]) {
            [self.mapView addAnnotation:task];
        }else {
            [self.mapView removeAnnotation:task];
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetailFromMap"]) {
        DetailViewController *detailVC = (DetailViewController *)[segue destinationViewController];
        detailVC.task = sender;
        
    }
}


@end
