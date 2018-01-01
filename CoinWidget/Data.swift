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
var widgetValue: String = ""
var walletValue: String = ""

func loadWallet() {
    if let walletData = defaults.data(forKey: "wallet") {
        walletCoins = (NSKeyedUnarchiver.unarchiveObject(with: walletData) as! [WalletEntry])
        print("Wallet loaded")
    } else {
        print("Failed: Can not load Wallet")
    }
}