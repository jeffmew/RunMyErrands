//
//  CreateNewGroupViewController.swift
//  RunMyErrands
//
//  Created by Jeff Mew on 2015-12-02.
//  Copyright © 2015 Jeff Mew. All rights reserved.
//

import UIKit
import Parse

class CreateNewGroupViewController: UIViewController {

    @IBOutlet weak var newGroupNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
    @IBAction func createNewGroup(sender: UIButton) {
        
        if let newGroupName = self.newGroupNameTextField.text {
            let newGroup = PFObject(className: "Group")
            newGroup["name"] = newGroupName
            let relation = newGroup.relationForKey("member")
            let currentUser = PFUser.currentUser()
            newGroup["teamLeader"] = currentUser!.objectId
            
            relation.addObject(currentUser!)
            
            newGroup.saveInBackgroundWithBlock({ (bool: Bool, error: NSError?) -> Void in
                print("New Team Created")
            })
        }
    }
    
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
