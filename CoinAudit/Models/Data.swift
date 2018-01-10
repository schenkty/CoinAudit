//
//  Data.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation
import NotificationCenter
import CoreData
import Alamofire

let defaults = UserDefaults(suiteName: "group.coinaudit.data")!
var alerts: [AlertEntry] = []
var entries: [CoinEntry] = []
var favorites: [String] = []
var widgetPercent: String = ""
var walletValue: String = ""
var holdWalletEntry: Bool = false
var walletEntryValue: String = "WalletEntry1"
var themeValue: String = defaults.object(forKey: "CoinAuditTheme") as? String ?? String()
var walletEntries: [NSManagedObject] = []
var notificationID: String? = defaults.object(forKey: "CoinAuditNotificationID") as? String ?? String()
var priceFormat: String? = defaults.object(forKey: "CoinAuditPriceFormat") as? String ?? "USD"

func saveFavoriteSettings() {
    defaults.set(favorites, forKey: "CoinAuditFavorites")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}

func saveWidgetSettings() {
    defaults.set(widgetPercent, forKey: "CoinAuditWidgetPercent")
}

func saveThemeSettings() {
    defaults.set(themeValue, forKey: "CoinAuditTheme")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}

func saveNotificationSettings() {
    defaults.set(notificationID, forKey: "CoinAuditNotificationID")
}

func saveWalletSettings() {
    defaults.set(walletValue, forKey: "CoinAuditWalletMode")
    defaults.set(walletValue, forKey: "CoinAuditWalletEntry")
}

func savePriceSettings() {
    defaults.set(priceFormat, forKey: "CoinAuditPriceFormat")
}

// MARK: Check Network
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

func pullData() {
    // Clear entries array
    entries.removeAll()
    
    // Pull Coin Data
    Alamofire.request("https://api.coinmarketcap.com/v1/ticker/?limit=0").responseJSON { response in
        for coinJSON in (response.result.value as? [[String : AnyObject]])! {
            if let coin = CoinEntry.init(json: coinJSON) {
                entries.append(coin)
            }
        }
    }
}

// MARK: Get Core Data Context
func getContext () -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}
