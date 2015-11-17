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

@protocol AddTasksDelegate <NSObject>

-(void)addTasksArray:(NSMutableArray*)array;

@end

@interface MapViewController : UIViewController

@property (nonatomic)NSMutableArray *taskArray;
@property (nonatomic, strong) id <AddTasksDelegate> delegate;

@end
