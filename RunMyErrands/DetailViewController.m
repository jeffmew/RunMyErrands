//
//  DetailViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-14.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self initiateMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Geo
- (void) initiateMap {
 
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.task.coordinate;
        mapRegion.span.latitudeDelta = 0.005;
        mapRegion.span.longitudeDelta = 0.005;
        [self.mapView setRegion:mapRegion animated: YES];
        [self.mapView addAnnotation:self.task];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:[Task class]]) {
        return nil;
    }
    
    Task *task = (Task *) annotation;
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomDAnno"];
    
    if (!annotationView) {
        annotationView = task.annoView;
    }else {
        annotationView.annotation = annotation;
    }
    return annotationView;
}
@end
