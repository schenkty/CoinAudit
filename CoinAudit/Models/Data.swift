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

let defaults = UserDefaults(suiteName: "group.coinaudit.data")!
var entries: [CoinEntry] = []
var favorites: [String] = []
var widgetValue: String = ""
var widgetPercent: String = ""
var walletValue: String = ""
var themeValue: String = defaults.object(forKey: "CoinAuditTheme") as? String ?? String()
var walletCoins: [NSManagedObject] = []


func saveFavoriteSettings() {
    defaults.set(favorites, forKey: "CoinAuditFavorites")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}

func saveWidgetSettings() {
    defaults.set(widgetValue, forKey: "CoinAuditWidget")
    defaults.set(widgetPercent, forKey: "CoinAuditWidgetPercent")
}

func saveThemeSettings() {
    defaults.set(themeValue, forKey: "CoinAuditTheme")
    print("Theme saved: \(themeValue)")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}

func saveWalletSettings() {
    defaults.set(walletValue, forKey: "CoinAuditWalletMode")
}


// MARK: Get Core Data Context
func getContext () -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}
