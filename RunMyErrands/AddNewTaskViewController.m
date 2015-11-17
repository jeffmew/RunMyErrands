//
//  AddNewTaskViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-15.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "AddNewTaskViewController.h"
#import <Parse/Parse.h>

@interface AddNewTaskViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPickerView;
@property (nonatomic) double longititude;
@property (nonatomic) double lattitude;
@property (nonatomic) NSArray *pickerData;
@property (nonatomic) NSInteger *categoryChoice;
@property (nonatomic) NSString *teamKey;
@property (nonatomic) NSMutableArray *taskArray;
@end

@implementation AddNewTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pickerData = @[@"General",@"Entertainment",@"Business",@"Food"];
    
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
    } else if (self.addressTextField.text.length == 0) {
        alertControllerTitle = @"Enter an Address";
        alertControllerMessage = @"Please Enter an Address or Choose it on the Map";
        [self presentAlertController:alertControllerTitle aMessage:alertControllerMessage];
    } else {
        PFObject *newTask = [PFObject objectWithClassName:@"Task"];
        newTask[@"name"] = self.taskNameTextField.text;
        newTask[@"description"] = self.descriptionTextField.text;
        if (self.addressTextField.text != 0) {
            newTask[@"address"] = self.addressTextField.text;
        } else {
            newTask[@"lattitude"] = @(self.lattitude);
            newTask[@"longititude"] = @(self.longititude);
        }
        
        newTask[@"isComplete"] = @NO;
        
        [newTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                PFQuery *teams = [PFQuery queryWithClassName:@"Team"];
                [teams whereKey:@"team" equalTo:[[PFUser currentUser] objectId]];
                
                [teams getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    
                    NSArray *tasks = object[@"tasks"];
                    tasks = [tasks arrayByAddingObjectsFromArray:@[newTask.objectId]];
                    
                    object[@"tasks"] = tasks;
                    [object saveInBackground];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];                                
            } else {
                // There was a problem, check error.description
                alertControllerTitle = @"Error";
                alertControllerMessage = @"Oops There Was a Problem in Adding The Task";
                [self presentAlertController:alertControllerTitle aMessage:alertControllerMessage];
            }
        }];
    }
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
    //tap to hide keyboard
    [self.view endEditing:YES];
}


#pragma - UIPickerView Delegate Functions

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.categoryChoice = &(row);
}

#pragma - AddTaskDelegate Function

-(void)addTasksArray:(NSMutableArray*)array {
    self.taskArray = array;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"mapSegue"]) {
        MapViewController *mapVC = (MapViewController*)[segue destinationViewController];
        mapVC.delegate = self;
        mapVC.taskArray = self.taskArray;

    }
}


@end
