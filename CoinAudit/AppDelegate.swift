//
//  AppDelegate.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/27/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData
import GoogleMobileAds
import Flurry_iOS_SDK
import OneSignal
import SwiftyStoreKit
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: GoogleAd.appID)
        
        // Flurry Framework Setup
        let builder = FlurrySessionBuilder.init()
            .withAppVersion(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
            .withLogLevel(FlurryLogLevelAll)
            .withCrashReporting(true)
            .withSessionContinueSeconds(10)
        
        Flurry.startSession("VPXM6GR7BCDHRTQPP9TV", with: builder)
        Flurry.setSessionReportsOnCloseEnabled(true)
        Flurry.setSessionReportsOnPauseEnabled(true)
        
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: "https://c546fb9d179f422897867891de5033a5:82bcd7e141b84ed4b5430e5a41dd00ec@sentry.io/269381")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }
        
        // OneSignal Framework Setup
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "7d06cefc-2472-4450-9513-2e1e4edd3aa2",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        OneSignal.add(self as OSSubscriptionObserver)
        
        if notificationID != "" {
            print("Push ID: \(notificationID!)")
        } else {
            print("Push ID: Not Found")
        }
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                showAd = "No"
                print("Ads Unlocked")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        // Test whether the app's receipt exists.
        if let url = Bundle.main.appStoreReceiptURL, let _ = try? Data(contentsOf: url) {
            // The receipt exists. Do something.
            showAd = "No"
            print("Ads Unlocked")
        } else {
            // Validation fails. The receipt does not exist.
            showAd = "Yes"
            print("Ads Locked")
        }
    
        // Update Language
        setLang()
        
        return true
    }
    
    // OneSignal Push Notification delegate
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
            // get player ID
            notificationID = stateChanges.to.userId
            
            if notificationID != "" {
                print("Push ID: \(notificationID!)")
            } else {
                print("Push ID: Not Found")
            }
            saveNotificationSettings()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let id = url.host!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
        vc.id = id
        print(id)
        if themeValue == "dark" {
            vc.view.backgroundColor = UIColor.black
        } else {
            vc.view.backgroundColor = UIColor.white
        }

        vc.title = id
        vc.viewer = true
        let navController = UINavigationController(rootViewController: vc)
        
        self.window?.rootViewController?.present(navController, animated: true, completion: nil)
        return true
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
        self.saveContext()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

