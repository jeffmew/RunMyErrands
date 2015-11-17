//
//  Task.m
//  RunMyErrandsMaps
//
//  Created by Steele on 2015-11-16.
//  Copyright © 2015 Steele. All rights reserved.
//

#import "Task.h"


@implementation Task


- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle;
{
    self = [super init];
    if (self) {
        _coordinate = aCoordinate;
        _title = aTitle;
        _subtitle = aSubtitle;
    }
    return self;
}


//-(void)getTaskLocation {
//
//CLLocationCoordinate2D center = CLLocationCoordinate2DMake(42.280597,-83.751891);
//CLRegion *task01Region = [[CLCircularRegion alloc]initWithCenter:center radius:100.0 identifier:@"task01"];
//
//    
//}
@end
