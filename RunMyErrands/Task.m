//
//  Task.m
//  RunMyErrandsMaps
//
//  Created by Steele on 2015-11-16.
//  Copyright © 2015 Steele. All rights reserved.
//

#import "Task.h"


@implementation Task

@dynamic title;
@dynamic subtitle;
@dynamic taskDescription;
@dynamic address;
@dynamic locationName;
@dynamic lattitude;
@dynamic longitude;
//@dynamic coordinate;
@dynamic isComplete;
@dynamic category;

+ (void)load {
    [self registerSubclass];
}

+ (NSString*)parseClassName {
    return @"Task";
}

-(CLLocationCoordinate2D) coordinate {
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake([self.lattitude doubleValue], [self.longitude doubleValue]);
    return newCoordinate;
}

-(void) updateCoordinate {
    self.coordinate = CLLocationCoordinate2DMake([self.lattitude doubleValue], [self.longitude doubleValue]);
}

-(void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.lattitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
//    coordinate = newCoordinate;
}


-(MKAnnotationView*)annoView {
    
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CustomAnno"];
    
    NSString *imageName;
    switch ([self.category intValue]) {
        case 0:
            imageName = @"runmyerrands";
            break;
        case 1:
            imageName = @"die";
            break;
        case 2:
            imageName = @"briefcase";
            break;
        case 3:
            imageName = @"cart";
            break;
        default:
            break;
    }
    
    CGSize size = CGSizeMake(40, 40);
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *annoIcon = [self imageWithImage:image scaledToSize:size];
    annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:annoIcon];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    
    return annotationView;
}

-(MKAnnotationView*)annoDetailView {
    
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CustomDetailAnno"];
    
    NSString *imageName;
    switch ([self.category intValue]) {
        case 0:
            imageName = @"runmyerrands";
            break;
        case 1:
            imageName = @"die";
            break;
        case 2:
            imageName = @"briefcase";
            break;
        case 3:
            imageName = @"cart";
            break;
        default:
            break;
    }
    
    CGSize size = CGSizeMake(40, 40);
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *annoIcon = [self imageWithImage:image scaledToSize:size];
    annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:annoIcon];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    return annotationView;
    
}


-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
