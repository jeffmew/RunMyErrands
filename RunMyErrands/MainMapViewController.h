//
//  MapViewController.h
//  RunMyErrandsMaps
//
//  Created by Steele on 2015-11-16.
//  Copyright © 2015 Steele. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Task.h"

@interface MainMapViewController : UIViewController

@property (nonatomic)NSArray *taskArray;

@property (nonatomic, strong) Task *task;

@end
