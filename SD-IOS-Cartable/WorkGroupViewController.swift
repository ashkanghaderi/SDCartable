//
//  WorkGroupViewController.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/24/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import UIKit

class WorkGroupViewController: UIViewController {

    @IBOutlet weak var WorkGroupTable: UITableView!
    
    struct WorkGroupTableViewCellIdentifiers {
        static let WorkGroupTableCell = "WorkGroupTableCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
        
    }
    

    var workGroups : [WorkGroupModel] = [WorkGroupModel]()
    
    var isLoading = false
    var isSearchMode = false
    
    var dataTask2: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (WorkGroupTable != nil) {
            var cellNib = UINib(nibName: WorkGroupTableViewCellIdentifiers.WorkGroupTableCell, bundle: nil)
            WorkGroupTable.registerNib(cellNib, forCellReuseIdentifier: WorkGroupTableViewCellIdentifiers.WorkGroupTableCell)
            
            cellNib = UINib(nibName: WorkGroupTableViewCellIdentifiers.nothingFoundCell, bundle: nil)
            WorkGroupTable.registerNib(cellNib, forCellReuseIdentifier: WorkGroupTableViewCellIdentifiers.nothingFoundCell)
            
            cellNib = UINib(nibName: WorkGroupTableViewCellIdentifiers.loadingCell, bundle: nil)
            WorkGroupTable.registerNib(cellNib, forCellReuseIdentifier: WorkGroupTableViewCellIdentifiers.loadingCell)
            
            
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        WorkGroupTable.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0,
            right: 0)
        LoginOperation(GenerateLoginParameters(),url: WORK_GROUP_URL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func GenerateLoginParameters() -> Dictionary<String, AnyObject> {
        let personId = NSUserDefaults.standardUserDefaults().valueForKey("PersonId")?.stringValue
        let token = NSUserDefaults.standardUserDefaults().valueForKey("GuidToken") as? String
        return  ["loginPersonId":"\(personId!)","userToken":"\(token!)"]
    }
    
    func LoginOperation(params : Dictionary<String, AnyObject>, url : String) {
        isLoading = true
        WorkGroupTable.reloadData()
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
                    
                    let result : [WorkGroupModel] = self.parseDictionary(receivedJSON)
                    
                    self.isLoading = false
                    self.workGroups = result
                    
                    self.WorkGroupTable.reloadData()
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
    
    func parseDictionary(json: JSON) -> [WorkGroupModel] {
        print("data! \(json)")
        var worksResults = [WorkGroupModel]()
        
        let resultRoot = json["ListResult"]
        
        for (_, subJson): (String, JSON) in resultRoot{
            
            let wResult :WorkGroupModel? = WorkGroupModel()
            
            
            wResult?.workGroupId = subJson["WorkGroupId"].intValue
            wResult?.workGroupTitle = subJson["WorkGroupTitle"].stringValue
            
            
            
            if let result = wResult {
                worksResults.append(result)
            }
            
        }
        
        
        return worksResults
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

extension WorkGroupViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            if isLoading {
                return 1
            }  else if workGroups.count == 0 {
                return 1
            }  else {
                return workGroups.count
            }
    }
    
        
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if isLoading {
                let cell = tableView.dequeueReusableCellWithIdentifier(WorkGroupTableViewCellIdentifiers.loadingCell, forIndexPath:indexPath)
                
                WorkGroupTable.rowHeight = 90
                
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
                
            } else if workGroups.count == 0 {
                
                WorkGroupTable.rowHeight = 60
                
                return tableView.dequeueReusableCellWithIdentifier(WorkGroupTableViewCellIdentifiers.nothingFoundCell,forIndexPath: indexPath)
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(WorkGroupTableViewCellIdentifiers.WorkGroupTableCell,forIndexPath: indexPath) as! WorkGroupTableViewCell
                
                WorkGroupTable.rowHeight = 70
                
                let workGroup : WorkGroupModel
                
                workGroup = workGroups[indexPath.row]
                
                
                cell.Configuration(workGroup)
                
                return cell
            }
    }
    
}

extension WorkGroupViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if workGroups.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}