//
//  ErrandListViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-14.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "ErrandListViewController.h"
#import "AddNewTaskViewController.h"
#import "DetailViewController.h"
#import <Parse/Parse.h>
#import "Task.h"

@interface ErrandListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) NSArray *taskArray;
@end



@implementation ErrandListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    
    [PFUser logInWithUsernameInBackground:@"jeff" password:@"jeff" block:^(PFUser *user, NSError *error) {
        if (error) {
        } else {
          //  [self createNewTeam];
            [self loadTaskObjects];
        }
    }];
    
    
    
}

//-(void) addNewTeamMember {
//    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
//    
//    [query getObjectInBackgroundWithId:@"IluX14keVf" block:^(PFObject * _Nullable team, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        } else {
//            //messages found
//            NSArray *updatedTeam = team[@"team"];
//            updatedTeam = [updatedTeam arrayByAddingObjectsFromArray:@[[PFUser currentUser].objectId]];
//            team[@"team"] = updatedTeam;
//            [team saveInBackground];
//        }
//    }];	
//}

- (void) createNewTeam {
    PFObject *newTeam = [PFObject objectWithClassName:@"Team"];
    newTeam[@"name"] = @"Team RME";
    newTeam[@"teamLead"] = [PFUser currentUser].objectId;
    newTeam[@"team"] = @[[PFUser currentUser].objectId];
    newTeam[@"tasks"] = @[];

    [newTeam saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description            
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self loadTaskObjects];
    //[self.tableview reloadData];
}

-(void) loadTaskObjects {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFQuery *query = [PFQuery queryWithClassName:@"Team"];
        [query whereKey:@"team" equalTo:[[PFUser currentUser] objectId]];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                
                NSArray *tasks = object[@"tasks"];
                
                PFQuery *taskQuery = [PFQuery queryWithClassName:@"Task"];
                [taskQuery whereKey:@"objectId" containedIn:tasks];
                [taskQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    } else {
                        self.taskArray = objects;
                        
                        for (Task *taskFromArray in self.taskArray) {
                            //
                            [taskFromArray updateCoordinate];
                        }
                        
                        Task *atask = self.taskArray.lastObject;
                        NSLog(@"%f", atask.coordinate.longitude);
                        [self.tableview reloadData];
                    }
                }];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addButton:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"addNewTask" sender:nil];
}

#pragma mark - Core Data stack

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.taskArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"tasklistCell" forIndexPath:indexPath];

    Task *taskAtCell = self.taskArray[indexPath.section];
    
    cell.textLabel.text = taskAtCell.title;
    cell.layer.cornerRadius = 6;
    
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"addNewTask"]) {
       // AddNewTaskViewController *addNewTaskVC = (AddNewTaskViewController *)[segue destinationViewController];

    } else if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailViewController *detailVC = (DetailViewController*)[segue destinationViewController];
        detailVC.taskArray = self.taskArray;
    }
}


@end
