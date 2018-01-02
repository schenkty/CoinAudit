//
//  AppDelegate.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/27/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL {
            let sourceApp = launchOptions![UIApplicationLaunchOptionsKey.sourceApplication] as? String
            let annotation = launchOptions![UIApplicationLaunchOptionsKey.annotation]
            self.application(application: application, open: url, sourceApplication: sourceApp, annotation: annotation!)
        }
        
        return true
    }
    
    func application(application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "coinaudit" {
            //TODO: Fix code for loading while app is closed
            print("loading: \(url)")
            
            var urlPath: String = url.path
            let urlHost: String = url.host!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if(urlHost != "coin") {
                print("Host is not correct")
                return false
            }
            
            if(urlPath != "") {
                urlPath.remove(at: urlPath.startIndex)
    
                let coinController = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
                coinController.id = urlPath
                coinController.mode = "url"
                self.window?.rootViewController = coinController
            }
            
            self.window?.makeKeyAndVisible()
            return true
        } else {
            return false
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoinAuditReload"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoinAuditReload"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

