//
//  DetailViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-14.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.taskNameLabel.text =  self.task.title;
    self.taskDescriptionLabel.text = [NSString stringWithFormat:@"DESCRIPTION: %@", self.task.taskDescription];
    self.locationNameLabel.text = [NSString stringWithFormat:@"WHERE: %@", self.task.subtitle];
    self.addressLabel.text = [NSString stringWithFormat:@"ADDRESS: %@", self.task.address];
    
    NSString *imageName;
    switch ([self.task.category intValue]) {
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
    
    if ([self.task.isComplete boolValue]) {
        imageName = [imageName stringByAppendingString:@"-grey"];
    }
    
    self.imageView.image = [UIImage imageNamed:imageName];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)markAsComplete:(UIButton *)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Task"];
    [query getObjectInBackgroundWithId:self.task.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        Task *selectedTask = (Task*)object;
        selectedTask.isComplete = @(YES);
        self.task.isComplete = @(YES);
        [selectedTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self viewDidLoad];
            }
        }];
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
