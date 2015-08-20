//
//  AppDelegate.swift
//  MFWebinar
//
//  Created by Rhys Short on 18/08/2015.
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
import IMFCore
import CloudantToolkit
import IMFData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var store: CDTStore?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // initialize SDK with IBM Bluemix application ID and route 
        // replace this line with the code shown in Step 3 of the existing project AMA set up guide
        IMFClient.sharedInstance().initializeWithBackendRoute("Your IBM Bluemix Route", backendGUID: "Your GUID")
        IMFGoogleAuthenticationHandler.sharedInstance().registerWithDefaultDelegate()
        
        
        let manager = IMFDataManager.sharedInstance()
        let name = "routes";
        
        //create the remote store
        manager.remoteStore(name, completionHandler: { (store, error) -> Void in
            if let actualError = error {
                NSLog("Error creating store: %@", actualError)
            }
            
            if let datastore = store {
                self.store = datastore
                self.store?.createIndexWithName("documentType", fields: ["documentType"], completionHandler: { (error) -> Void in
                    if let actualError = error {
                        NSLog("error occured creating index", actualError)
                    } else {
                        
                        //do some permissions 
                        manager.setCurrentUserPermissions(DB_ACCESS_GROUP_MEMBERS, forStoreName: name, completionHander: { (success, error) -> Void in
                            if(success){
                                NSNotificationCenter.defaultCenter().postNotificationName("DataSetupComplete", object: nil)
                            } else {
                                NSLog("Error setting permissions %@",error)
                            }
                        })
                    }
                    
                })
                
            }
            
        })
        
        
        
        
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        IMFGoogleAuthenticationHandler.sharedInstance().handleDidBecomeActive()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
  
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let shouldHandleGoogleURL = GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        IMFGoogleAuthenticationHandler.sharedInstance().handleOpenURL(shouldHandleGoogleURL)
        return shouldHandleGoogleURL
    }





}
