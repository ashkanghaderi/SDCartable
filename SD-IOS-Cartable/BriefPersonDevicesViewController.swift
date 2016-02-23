//
//  BriefPersonDevicesViewController.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/2/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import UIKit

class BriefPersonDevicesViewController: UIViewController {

    
    struct PersonDeviceTableViewCellIdentifiers {
        static let PersonDeviceTableCell = "PersonDeviceTableCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
        
    }
    
    @IBOutlet weak var personDeviceTable: UITableView!
    
    var personDevices : [PersonDevicesModel] = [PersonDevicesModel]()
    
    var isLoading = false
    var isSearchMode = false
    
    var dataTask2: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (personDeviceTable != nil) {
            var cellNib = UINib(nibName: PersonDeviceTableViewCellIdentifiers.PersonDeviceTableCell, bundle: nil)
            personDeviceTable.registerNib(cellNib, forCellReuseIdentifier: PersonDeviceTableViewCellIdentifiers.PersonDeviceTableCell)
            
            cellNib = UINib(nibName: PersonDeviceTableViewCellIdentifiers.nothingFoundCell, bundle: nil)
            personDeviceTable.registerNib(cellNib, forCellReuseIdentifier: PersonDeviceTableViewCellIdentifiers.nothingFoundCell)
            
            cellNib = UINib(nibName: PersonDeviceTableViewCellIdentifiers.loadingCell, bundle: nil)
            personDeviceTable.registerNib(cellNib, forCellReuseIdentifier: PersonDeviceTableViewCellIdentifiers.loadingCell)
            
            personDeviceTable.rowHeight = 70
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        LoginOperation(GenerateLoginParameters(),url: PERSON_DEVICES_URL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func GenerateLoginParameters() -> Dictionary<String, AnyObject> {
        let personId = NSUserDefaults.standardUserDefaults().valueForKey("PersonId") as? String
        let token = NSUserDefaults.standardUserDefaults().valueForKey("GuidToken") as? String
        return  ["loginPersonId":"\(personId!)","userToken":"\(token!)"]
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
                    
                    let result : [PersonDevicesModel] = self.parseDictionary(receivedJSON)
                    
                    self.personDevices = result
                    
                    self.personDeviceTable.reloadData()
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
    
    func parseDictionary(json: JSON) -> [PersonDevicesModel] {
        print("data! \(json)")
        var loginResults = [PersonDevicesModel]()
        
        let resultRoot = json["ListResult"]
        
        for (_, subJson): (String, JSON) in resultRoot{
            
            let loginResult :PersonDevicesModel? = PersonDevicesModel()
            
            
            loginResult?.deviceAliasName = subJson["DeviceAliasName"].stringValue
            loginResult?.failureDescription = subJson["FailureDescription"].stringValue
            loginResult?.qcSerial = subJson["QcSerial"].stringValue
            
            
            
            if let result = loginResult {
                loginResults.append(result)
            }
            
        }
        
        
        return loginResults
    }
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    
}

extension BriefPersonDevicesViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            if isLoading {
                return 1
            }  else if personDevices.count == 0 {
                return 1
            } else if isSearchMode {
                return personDevices.count
            } else {
                return personDevices.count
            }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        label.text = "تجهیزات در اختیار کارشناس"
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Right
        return label
    }
    
    
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if isLoading {
                let cell = tableView.dequeueReusableCellWithIdentifier(PersonDeviceTableViewCellIdentifiers.loadingCell, forIndexPath:indexPath)
                
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
                
            } else if personDevices.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier(PersonDeviceTableViewCellIdentifiers.nothingFoundCell,forIndexPath: indexPath)
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(PersonDeviceTableViewCellIdentifiers.PersonDeviceTableCell,forIndexPath: indexPath) as! BriefPersonTableViewCell
                
                let personDevice : PersonDevicesModel

                personDevice = personDevices[indexPath.row]
               
                
                cell.configuration(personDevice)
                
                return cell
            }
    }
    
}

extension BriefPersonDevicesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if personDevices.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}
