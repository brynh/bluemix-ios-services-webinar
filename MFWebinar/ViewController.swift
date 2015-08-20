//
//  ViewControllerTableViewController.swift
//  MFWebinar
//
//  Created by Rhys Short on 19/08/2015.
//  Copyright (c) 2015 IBM. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

import UIKit
import CloudantToolkit

struct Route {
    let name : String
    let crag : String
    
    init(revision:CDTDocumentRevision){
        self.name   = revision.body()["name"] as! String;
        self.crag   = revision.body()["crag"] as! String;
        
    }
}

class ViewController : UITableViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var routes:Dictionary<String,Array<Route>> = Dictionary<String,Array<Route>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.spinner.startAnimating()
        self.spinner.hidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("reloadData"), name: "DataSetupComplete", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.routes.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let routesArray = [String](self.routes.keys)
        let crag = routesArray[section];
        if let routeByCrag = self.routes[crag] {
            return routeByCrag.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("RouteCell", forIndexPath: indexPath)
        let routesArray = [String](self.routes.keys)
        let crag = routesArray[indexPath.section];
        if let routes = self.routes[crag]{
        
            let route = routes[indexPath.row]
            
            cell.textLabel?.text = route.name
            cell.detailTextLabel?.text = route.crag
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let routesArray = [String](self.routes.keys)
        return routesArray[section] as String
    }

    
    func getStore() -> CDTStore? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.store
    }
    
    func reloadData() {
        let query = CDTCloudantQuery(cloudantQuery: ["documentType":"route"])
        var model:Dictionary<String,Array<Route>> = Dictionary()
        
        if let store = self.getStore() {
            store.performQuery(query, completionHandler: { (results, error) -> Void in
                if let _ = error {
                    NSLog("Error: %@",error)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.spinner.startAnimating()
                        self.spinner.hidden = true
                    })
                }
                if let _ = results {
                    for result in results {
                        let route = Route(revision: result as! CDTDocumentRevision)
                        if let modelRoute = model[route.crag]{
                            let newModelRoute = [route] + modelRoute
                            model[route.crag] = newModelRoute
                        } else {
                            model[route.crag] = [route]
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.spinner.startAnimating()
                        self.spinner.hidden = true
                        self.routes = model
                        self.tableView.reloadData()
                    })
                }
            }) //end of block

        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
