//
//  AddNewTaskViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-15.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "AddNewTaskViewController.h"
#import <Parse/Parse.h>
#import "Task.h"

@interface AddNewTaskViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationName;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *groupPickerView;
@property (nonatomic) NSArray *categoryPickerData;
@property (nonatomic) NSArray *groupPickerData;
@property (nonatomic) NSInteger *categoryChoice;
@property (nonatomic) NSInteger *groupChoice;
@property (nonatomic) NSString *teamKey;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (nonatomic) Task* task;
@end

@implementation AddNewTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categoryPickerView.delegate = self;
    self.categoryPickerData = @[@"General",@"Entertainment",@"Business",@"Food"];
    
//    self.categoryPickerView.layer.cornerRadius = 6;
    self.task = [Task object];
    self.task.isComplete = @NO;
    NSMutableAttributedString *categoryAttributeString = [[NSMutableAttributedString alloc] initWithString:@"Category"];
    [categoryAttributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[categoryAttributeString length]}];
    self.categoryLabel.attributedText = categoryAttributeString;
    
    NSMutableAttributedString *groupAttributeString = [[NSMutableAttributedString alloc] initWithString:@"Group"];
    [groupAttributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[groupAttributeString length]}];
    self.groupLabel.attributedText = groupAttributeString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)okButtonPressed:(UIButton *)sender {
    __block NSString *alertControllerTitle;
    __block NSString *alertControllerMessage;
    
    if (self.taskNameTextField.text.length == 0) {
        alertControllerTitle = @"Enter a Name";
        alertControllerMessage = @"Please Enter a Task Name";
        [self presentAlertController:alertControllerTitle aMessage:alertControllerMessage];
    } else if (self.addressTextField.text.length == 0 && !self.task.longitude) {
        alertControllerTitle = @"Enter an Address";
        alertControllerMessage = @"Please Enter an Address or Choose it on the Map";
        [self presentAlertController:alertControllerTitle aMessage:alertControllerMessage];
    } else {
        self.task.title = [self.taskNameTextField.text capitalizedString];
        self.task.taskDescription = [self.descriptionTextField.text capitalizedString];
        self.task.subtitle = [self.locationName.text capitalizedString];
        self.task.category = @([self.categoryPickerView selectedRowInComponent:0]);
        
        if (self.addressTextField.text.length != 0) {
            self.task.address = self.addressTextField.text;
            [self geoCodeAddress:self.task.address];
        }else if (self.task.coordinate.latitude) {
            self.task.address = @"";
            [self saveTask];
        }
    }
}

-(void)saveTask {
    
    [self.task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            PFQuery *teams = [PFQuery queryWithClassName:@"Team"];
            [teams whereKey:@"team" equalTo:[[PFUser currentUser] objectId]];
            
            [teams getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                NSArray *tasks = object[@"tasks"];
                tasks = [tasks arrayByAddingObjectsFromArray:@[self.task.objectId]];
                
                object[@"tasks"] = tasks;
                [object saveInBackground];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            // There was a problem, check error.description
            NSString *alertControllerTitle = @"Error";
            NSString *alertControllerMessage = @"Oops There Was a Problem in Adding The Task";
            [self presentAlertController:alertControllerTitle aMessage:alertControllerMessage];
        }
    }];
}


-(void) presentAlertController:(NSString *)title aMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //
                                               }];
    
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma - UITapGestureRecognizer Delegate Functions

- (IBAction)tapDetected:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


#pragma - UIPickerView Delegate Functions

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categoryPickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.categoryPickerData[row];
}

#pragma - AddTaskDelegate Function

-(void)addTasksArray:(NSMutableArray*)array {
    self.taskArray = array;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"mapSegue"]) {
        MapViewController *mapVC = (MapViewController*)[segue destinationViewController];
        mapVC.taskArray = self.taskArray;
        mapVC.task = self.task;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0]];
        [tView setTextColor:[UIColor whiteColor]];
        tView.textAlignment = NSTextAlignmentCenter;
        //[tView setTextAlignment:UITextAlignmentLeft];
        tView.numberOfLines=3;
    }
    // Fill the label text here
    tView.text = self.categoryPickerData[row];
    return tView;
}

#pragma mark - Geo

-(void)geoCodeAddress:(NSString*)address {
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            
            self.task.coordinate = coordinate;
            [self saveTask];
        } else {
            NSLog(@"location error");
            return;
        }
    }];
}

@end
