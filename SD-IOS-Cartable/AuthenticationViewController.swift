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
        userNameTxt.text = ""
        passwordTxt.text = ""
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
        
    }
    
    
    func GenerateJsonString() -> String{
        
        return  "{\"network\" : \"Normal\",\"username\":\"\(userNameTxt.text!)\",\"password\":\"\(passwordTxt.text!)\",\"softwareName\":\"IOS-ServiceDesk\",\"softwareVersion\":\"110\",\"deviceOs\":\"IOS\",\"osVersion\":\"\(UIDevice.currentDevice().systemVersion)\",\"deviceModel\":\"\(UIDevice.currentDevice().model)\",\"deviceSerial\":\"\((UIDevice.currentDevice().identifierForVendor?.UUIDString)!)\"}"
    }
    
    
    func GenerateLoginParameters() -> Dictionary<String, AnyObject> {
        return  ["network":"Normal","username":"\(userNameTxt.text!)","password":"\(passwordTxt.text!)","softwareName":"IOS-ServiceDesk","softwareVersion":"110","deviceOs":"IOS","deviceModel":"\(UIDevice.currentDevice().model)","deviceSerial":"\(String((UIDevice.currentDevice().identifierForVendor?.UUIDString)!))"]
    }
    
    
    func LoginOperation(params : Dictionary<String, AnyObject>, url : String) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
            let paramObj = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            
            let jsonStr = NSString(data: paramObj, encoding: NSUTF8StringEncoding)
            print("Sent JSON: \(jsonStr!)")
            
            request.HTTPBody =  paramObj
        } catch {
            //handle error. Probably return or mark function as throws
            print(error)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                print("parse JSON: \(data)")
                
                if let data = data, receivedJSON : JSON = JSON(data: data) {
                    
                    let result : [AuthenticationModel] = self.parseDictionary(receivedJSON)
                    
                    if result.first?.guidToken != nil && result.first?.guidToken != ""{
                        self.Login(result.first!)
                    }
                }
                
            })
          }
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
        
        let resultRoot = json["ListResult"]
        
        for (_, subJson): (String, JSON) in resultRoot{
            
            let loginResult :AuthenticationModel? = AuthenticationModel()
            
            
            loginResult?.userFullName = subJson["UserFullName"].stringValue
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
        NSUserDefaults.standardUserDefaults().setObject(auth.userFullName, forKey: "UserFullName")
        NSUserDefaults.standardUserDefaults().setObject(auth.guidToken, forKey: "GuidToken")
        NSUserDefaults.standardUserDefaults().setObject(Int(auth.personId!), forKey: "PersonId")
        NSUserDefaults.standardUserDefaults().setObject(auth.appVersion, forKey: "AppVersion")
        performSegueWithIdentifier("LoginSegue", sender: nil)

    }
    
    func CheckLoginNecessary(){
        fetchAndSetResult()
        if self.user != nil {
        let userName = self.user?.valueForKey("userfullname") as? String
        if userName != nil && userName != "" {
            
            performSegueWithIdentifier("LoginSegue", sender: self.user)
            
            }
        }
    }


}
