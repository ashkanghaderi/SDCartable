//
//  AuthenticationViewController.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/2/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import UIKit
import CoreData


class AuthenticationViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userNameTxt: MaterialTextField!
    @IBOutlet weak var passwordTxt: MaterialTextField!
    var user : User?
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
    
        userNameTxt.delegate = self
        passwordTxt.delegate = self
        CheckLoginNecessary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func userNameEditEnd(sender: AnyObject) {
        if  userNameTxt.isFirstResponder() {
            userNameTxt.resignFirstResponder()
        }
    }

    @IBAction func passwordEditEnd(sender: AnyObject) {
        
        if  passwordTxt.isFirstResponder() {
            passwordTxt.resignFirstResponder()
        }
    }
    @IBAction func loginAction(sender: AnyObject) {
        guard userNameTxt.text != nil || passwordTxt.text != nil else {
            showError(USER_NAME_AND_PASSWORD_REQUIERD)
            return
        }
        
        LoginOperation(GenerateLoginParameters(), url: ATHENTICATION_URL)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginSegue" {
            let destinationVC = segue.destinationViewController as! BriefPersonDevicesViewController
            destinationVC.user = sender as? User
            
        }
    }
    
    
    func GenerateLoginParameters() -> Dictionary<String, String> {
        return  ["network":"Normal","username":userNameTxt.text!,"password":passwordTxt.text!,"softwareName":"IOS-ServiceDesk","softwareVersion":"110","deviceOs":"IOS","osVersion":UIDevice.currentDevice().systemVersion,"deviceModel":UIDevice.currentDevice().model,"deviceSerial":String(UIDevice.currentDevice().identifierForVendor)]
    }
    
    
    func LoginOperation(params : Dictionary<String, String>, url : String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            //handle error. Probably return or mark function as throws
            print(error)
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // handle error
            guard error == nil else { return }
            
            if let error = error where error.code == -999 {
                return  // Search was cancelled
                
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                
                if let data = data, receivedJSON : JSON = JSON(data: data) {
                    
                    let result : [AuthenticationModel] = self.parseDictionary(receivedJSON)
                    
                    if result.first?.guidToken != nil && result.first?.guidToken != ""{
                        self.Login(result.first!)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isLoading = false
                        
                        if result.first?.guidToken == nil && result.first?.guidToken == ""{
                            self.showError(USER_NAME_OR_PASSWORD_ERROR)
                        }
                    }
                    return
                }
                
            } else {
                print("Failure! \(response!)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.isLoading = false
                
                self.showNetworkError()
            }

           })
        
        task.resume()
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "بروز خظا",
            message: "بروز خطا در برقراری ارتباط با سرور...لطفا دوباره سعی کنید",
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "تایید", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func showError(msg : String?) {
        let alert = UIAlertController(
            title: "بروز خظا",
            message: msg,
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "تایید", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func parseDictionary(json: JSON) -> [AuthenticationModel] {
        print("data! \(json)")
        var loginResults = [AuthenticationModel]()
        
        
        
        for (_, subJson): (String, JSON) in json{
            
            let loginResult :AuthenticationModel? = AuthenticationModel()
            
            
            loginResult?.userFullName = subJson["userFullName"].stringValue
            loginResult?.guidToken = subJson["GuidToken"].stringValue
            loginResult?.appVersion = subJson["AppVersion"].stringValue
            loginResult?.personId = subJson["PersonId"].int64Value
            
            
            if let result = loginResult {
                loginResults.append(result)
            }
            
        }
        
        
        return loginResults
    }
    
    func fetchAndSetResult(){
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appdelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do{
            let result = try context.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                self.user = result.first as? User
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }

    
    func saveNewUser(authenticationObj : AuthenticationModel){
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        
        let user = User(entity : entity!,insertIntoManagedObjectContext : context)
        
        
        user.setValue(Int(authenticationObj.personId!), forKey: "personid")
        user.setValue(authenticationObj.userFullName, forKey: "userfullname")
        user.setValue(authenticationObj.guidToken, forKey: "guidtoken")
        user.setValue(authenticationObj.appVersion, forKey: "appversion")
        
        
        
        context.insertObject(user)
    
    
    do{
        try context.save()
    } catch {
        print("error")
    }

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
    
    func Login(auth : AuthenticationModel){

      deleteUser()
      saveNewUser(auth)
        let currentUser = User()
        currentUser.setValue(auth.appVersion, forKey: "appversion")
        currentUser.setValue(auth.guidToken, forKey: "guidtoken")
        currentUser.setValue(Int(auth.personId!), forKey: "personid")
        currentUser.setValue(auth.userFullName, forKey: "userfullname")
        
      performSegueWithIdentifier("LoginSegue", sender: currentUser)

    }
    
    func CheckLoginNecessary(){
        fetchAndSetResult()
        if self.user != nil {
            
            performSegueWithIdentifier("LoginSegue", sender: self.user)
            
        }
    }


}
