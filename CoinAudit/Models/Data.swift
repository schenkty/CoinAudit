//
//  Data.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation
import NotificationCenter

let defaults = UserDefaults(suiteName: "group.coinaudit.data")!
var entries: [CoinEntry] = []
var favorites: [String] = []
var widgetValue: String = defaults.object(forKey: "CoinAuditWidget") as? String ?? String()
var walletValue: String = defaults.object(forKey: "CoinAuditWalletMode") as? String ?? String()
var themeValue: String = defaults.object(forKey: "CoinAuditTheme") as? String ?? String()
var walletCoins: [WalletEntry] = []


func saveFavorites() {
    defaults.set(favorites, forKey: "CoinAuditFavorites")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}

func saveWidgetMode() {
    defaults.set(widgetValue, forKey: "CoinAuditWidget")
}

func saveTheme() {
    defaults.set(themeValue, forKey: "CoinAuditTheme")
    print("Theme saved: \(themeValue)")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}

func saveWallet() {
    let encodedWallet = NSKeyedArchiver.archivedData(withRootObject: walletCoins)
    defaults.set(encodedWallet, forKey: "CoinAuditWallet")
    defaults.set(walletValue, forKey: "CoinAuditWalletMode")
}

func loadWallet() {
    if let walletData = defaults.data(forKey: "CoinAuditWallet") {
        walletCoins = NSKeyedUnarchiver.unarchiveObject(with: walletData) as! [WalletEntry]
        print("Wallet loaded. \(walletCoins.count) coins Found")
    } else {
        print("Failed: Can not load Wallet")
    }
}
