//
//  Data.swift
//  CoinWidget
//
//  Created by Ty Schenk on 12/31/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

let defaults = UserDefaults(suiteName: "group.coinaudit.data")!

var favorites: [String] = []
var walletCoins: [WalletEntry] = []
var widgetValue: String = defaults.object(forKey: "widget") as? String ?? String()
var walletValue: String = defaults.object(forKey: "walletMode") as? String ?? String()

func loadWallet() {
    if let walletData = defaults.data(forKey: "wallet"),
        let walletItems = NSKeyedUnarchiver.unarchiveObject(with: walletData) as? [WalletEntry] {
        walletCoins = walletItems
        print("Wallet loaded")
    } else {
        print("Failed: Can not load Wallet")
    }
}
