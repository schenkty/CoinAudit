//
//  Data.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard
var entries: [CoinEntry] = []
var favorites: [String] = defaults.object(forKey:"favorites") as? [String] ?? [String]()
var walletCoins: [WalletEntry] = []


func saveWallet() {
    let encodedWallet = NSKeyedArchiver.archivedData(withRootObject: walletCoins)
    defaults.set(encodedWallet, forKey: "wallet")
}

func loadWallet() {
    if let walletData = defaults.data(forKey: "wallet"),
        let walletItems = NSKeyedUnarchiver.unarchiveObject(with: walletData) as? [WalletEntry] {
        walletCoins = walletItems
        print("Wallet loaded")
    } else {
        print("There is an issue loading wallet")
    }
}
