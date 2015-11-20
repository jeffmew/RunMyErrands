//
//  ErrandListViewController.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-14.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "ErrandListViewController.h"
#import "RunMyErrands-Swift.h"
#import "AddNewTaskViewController.h"
#import "DetailViewController.h"
#import <Parse/Parse.h>
#import "Task.h"
#import "GeoManager.h"

@interface ErrandListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *helloUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *youHaveTasksLabel;
@property (nonatomic) NSArray *taskArray;
@property (nonatomic) GeoManager *locationManager;

@end


@implementation ErrandListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [GeoManager sharedManager];
    [self.locationManager startLocationManager];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [PFUser logInWithUsernameInBackground:@"jeff" password:@"jeff" block:^(PFUser *user, NSError *error) {
        if (error) {
        } else {
            //[self addNewTeamMember]
            [self setGreeting];
            [self loadTaskObjects];
        }
    }];
}

-(void) setGreeting {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        self.helloUserLabel.text = [[NSString stringWithFormat:@"%@, %@...", [self randHello], currentUser.username] capitalizedString];
        self.youHaveTasksLabel.text = [NSString stringWithFormat:@"%@", [self randWelcomeMessage]];
    }
}

-(NSString*) randHello {
    int rand = arc4random() % 5;
    switch (rand) {
        case 0:
            return @"Hello";
            break;
        
        case 1:
            return @"Salutations";
            break;
            
        case 2:
            return @"Bonjour";
            break;
            
        case 3:
            return @"Greetings";
            break;
        
        case 4:
            return @"Hi";
            break;
            
        default:
            return @"Hello";
            break;
    }
}

-(NSString*) randWelcomeMessage {
    int rand = arc4random() % 5;
    switch (rand) {
        case 0:
            return @"Get to work.";
            break;
            
        case 1:
            return @"Here are your tasks.";
            break;
            
        case 2:
            return @"Today is a good day to finish a task.";
            break;
            
        case 3:
            return @"Get it done.";
            break;
            
        case 4:
            return @"Yesterday you said tomorrow.";
            break;
            
        default:
            return @"Just do it.";
            break;
    }
}


-(void) addNewTeamMember {
    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
    
    [query getObjectInBackgroundWithId:@"KXHjYWYANj" block:^(PFObject * _Nullable team, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            //messages found
            NSArray *updatedTeam = team[@"team"];
            updatedTeam = [updatedTeam arrayByAddingObjectsFromArray:@[[PFUser currentUser].objectId]];
            team[@"team"] = updatedTeam;
            [team saveInBackground];
        }
    }];	
}


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
    [self setGreeting];
    [self loadTaskObjects];
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
                [taskQuery addAscendingOrder:@"isComplete"];
                [taskQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    } else {
                        self.taskArray = objects;
                        
                        for (Task *taskFromArray in self.taskArray) {
                            [taskFromArray updateCoordinate];
                        }
                        
                        [self.tableview reloadData];
                        [self trackGeoRegions];
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
    ErrandsListTableViewCell *cell =(ErrandsListTableViewCell*)[self.tableview dequeueReusableCellWithIdentifier:@"tasklistCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = nil;
    cell.subtitleLabel.text = nil;
    cell.titleLabel.attributedText = nil;
    cell.subtitleLabel.attributedText = nil;
    cell.categoryImage.image = nil;
    
    Task *taskAtCell = self.taskArray[indexPath.section];
    
    NSString *imageName;
    switch ([taskAtCell.category intValue]) {
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
    
    if ([taskAtCell.isComplete boolValue]) {
    
        if (taskAtCell.title) {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[taskAtCell.title capitalizedString]];
            [title addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, [title length])];
            cell.titleLabel.attributedText = title;
        }
        
        if (taskAtCell.subtitle) {
            NSMutableAttributedString *subtitle = [[NSMutableAttributedString alloc] initWithString:[taskAtCell.subtitle capitalizedString]];
            [subtitle addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, [subtitle length])];
            cell.subtitleLabel.attributedText = subtitle;
        }
        
        imageName = [imageName stringByAppendingString:@"-grey"];
        
    } else {
        
        cell.titleLabel.text = [taskAtCell.title capitalizedString];
        cell.subtitleLabel.text = [taskAtCell.subtitle capitalizedString];
        
    }
    
    cell.layer.cornerRadius = 6;
    cell.categoryImage.image = [UIImage imageNamed:imageName];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"addNewTask"]) {
        AddNewTaskViewController *addNewTaskVC = (AddNewTaskViewController *)[segue destinationViewController];
        addNewTaskVC.taskArray = self.taskArray;
        
    } else if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailViewController *detailVC = (DetailViewController*)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];
        Task *selectedTask = self.taskArray[indexPath.section];
        detailVC.task = selectedTask;
    }
}


#pragma mark - Geo

-(void)trackGeoRegions {
    
    [self.locationManager removeAllTaskLocation];
    for (Task *task in self.taskArray) {
        CLLocationCoordinate2D center = task.coordinate;
        CLRegion *taskRegion = [[CLCircularRegion alloc]initWithCenter:center radius:200.0 identifier:[NSString stringWithFormat:@"%@\n%@",task.title,task.subtitle]];
        taskRegion.notifyOnEntry = YES;
        
        //Determine if to track the task location.
        if (![task.isComplete boolValue]) {
            [self.locationManager addTaskLocation:taskRegion];
        }else {
            [self.locationManager removeTaskLocation:taskRegion];
        }
    }
}

@end
