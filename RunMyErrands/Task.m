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
@dynamic coordinate;
@dynamic isComplete;
@dynamic category;

+ (void)load {
    [self registerSubclass];
}

+ (NSString*)parseClassName {
    return @"Task";
}

-(CLLocationCoordinate2D) getCoordinate {
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake([self.lattitude doubleValue], [self.longitude doubleValue]);
    return newCoordinate;
}

-(void) updateCoordinate {
    self.coordinate = CLLocationCoordinate2DMake([self.lattitude doubleValue], [self.longitude doubleValue]);
}

-(void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.lattitude = @(newCoordinate.latitude);
    self.longitude = @(newCoordinate.longitude);
    coordinate = newCoordinate;
}

//-(void)getTaskLocation {
//
//CLLocationCoordinate2D center = CLLocationCoordinate2DMake(42.280597,-83.751891);
//CLRegion *task01Region = [[CLCircularRegion alloc]initWithCenter:center radius:100.0 identifier:@"task01"];
//
//    
//}
@end
