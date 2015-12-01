//
//  LoginVC.m
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-11-30.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

#import "LoginVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "ErrandListViewController.h"


@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UIView *transitionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.transitionView.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLogin:(UIButton *)sender {
    NSArray *permissions = @[@"public_profile", @"user_friends"];
    
    self.transitionView.hidden = false;
    [self.activitySpinner startAnimating];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [self.activitySpinner stopAnimating];
            self.transitionView.hidden = true;
            
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            
            //first time user -> onboard
            
        } else {
            NSLog(@"User logged in through Facebook!");

            [self performSegueWithIdentifier:@"showErrandList" sender:nil];
            ErrandListViewController *elVC = [[ErrandListViewController alloc] init];
            [self presentViewController:elVC animated:YES completion:^{
                [self.activitySpinner stopAnimating];
                self.transitionView.hidden = true;
            }];
        }
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
