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
var walletCoins: [WalletEntry] = defaults.object(forKey:"wallet") as? [WalletEntry] ?? [WalletEntry]()
