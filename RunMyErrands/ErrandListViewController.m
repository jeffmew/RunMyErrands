//
//  ErrandListViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-14.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "ErrandListViewController.h"
#import "AddNewTaskViewController.h"
#import <Parse/Parse.h>

@interface ErrandListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) NSArray *tasks;
@end



@implementation ErrandListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    
    [PFUser logInWithUsernameInBackground:@"jeff" password:@"jeff" block:^(PFUser *user, NSError *error) {
        if (error) {
        } else {
            [self loadTaskObjects];
        }
    }];
    
    //[self createNewTeam];
    
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

//- (void) createNewTeam {
//    PFObject *newTeam = [PFObject objectWithClassName:@"Team"];
//    newTeam[@"name"] = @"Team RME";
//    newTeam[@"teamLead"] = [PFUser currentUser].objectId;
//    newTeam[@"team"] = @[[PFUser currentUser].objectId];
//    newTeam[@"tasks"] = @[];
//
//    [newTeam saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            // The object has been saved.
//        } else {
//            // There was a problem, check error.description            
//        }
//    }];
//}

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
                        self.tasks = objects;
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
    return self.tasks.count;
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
    
    
    /*
     you can't set distance between cells directly, but you can set the height for header in section to achieve the same result.
     
     1.set the numbers of cell you need as sections:
     
     - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
     {
     return 3; // in your case, there are 3 cells
     }
     2.return only 1 cell for each section
     
     - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
     {
     return 1;
     }
     3.set the height for header in section to set space between cells
     
     - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
     {
     return 10.; // you can have your own choice, of course
     }
     4.set the header's background color to clear color, so it won't look weird
     
     - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
     {
     UIView *headerView = [[UIView alloc] init];
     headerView.backgroundColor = [UIColor clearColor];
     return headerView;
     }
    
    */
    
    PFObject *task = [self.tasks objectAtIndex:indexPath.section];
    cell.textLabel.text = [task objectForKey:@"name"];
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

    }
}


@end
