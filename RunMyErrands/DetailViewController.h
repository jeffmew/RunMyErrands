//
//  DetailViewController.h
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-14.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end
