//
//  MainViewController.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/2/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var userFullName: UIBarButtonItem!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true)
        let userName = NSUserDefaults.standardUserDefaults().valueForKey("UserFullName") as? String
        self.userFullName.title = userName!
    }

    func deleteUser(){
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appdelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        var error : NSError? = nil
        
        do{
            try context.executeRequest(deleteRequest)
            try context.save()
            
        } catch let err as NSError{
            error = err
            print(error)
            abort()
        }
        
    }

    @IBAction func Logout(sender: AnyObject) {
        
        deleteUser()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("UserFullName")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("GuidToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("PersonId")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("AppVersion")
        
        navigationController!.popViewControllerAnimated(true)
        
        
    }
    

}
