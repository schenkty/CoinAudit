//
//  Data.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

let defaults = UserDefaults(suiteName: "group.coinaudit.data")!
var entries: [CoinEntry] = []
var favorites: [String] = defaults.object(forKey:"favorites") as? [String] ?? [String]()
var widgetValue: String = defaults.object(forKey: "widget") as? String ?? "favorites"
var walletValue: String = defaults.object(forKey: "walletMode") as? String ?? "volume"
var walletCoins: [WalletEntry] = []


func saveFavorites() {
    defaults.set(favorites, forKey: "favorites")
}

func saveWidgetMode() {
    defaults.set(widgetValue, forKey: "widget")
}

func saveWallet() {
    let encodedWallet = NSKeyedArchiver.archivedData(withRootObject: walletCoins)
    defaults.set(encodedWallet, forKey: "wallet")
    defaults.set(walletValue, forKey: "walletMode")
}

func loadWallet() {
    if let walletData = defaults.data(forKey: "wallet") {
        walletCoins = NSKeyedUnarchiver.unarchiveObject(with: walletData) as! [WalletEntry]
        print("Wallet loaded")
    } else {
        print("Failed: Can not load Wallet")
    }
}
