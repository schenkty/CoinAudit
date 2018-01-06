//
//  AlertEntry.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/6/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import Foundation

//{"id":"3","coin":"Bitcoin","symbol":"BTC","below":"40000","below_currency":"USD","above":"","above_currency":"","unique_id":"7efc0637-ca6d-4f63-8b84-9bf18e7f805c"}

struct AlertEntry {
    var id: String
    let coin: String
    let symbol: String
    let below: String
    let belowCurrency: String
    let above: String
    let aboveCurrency: String
    var action: AlertActions = .False
}

extension AlertEntry {
    struct Key {
        static let id: String = "id"
        static let coin: String = "coin"
        static let symbol: String = "symbol"
        static let below: String = "below"
        static let belowCurrency: String = "below_currency"
        static let above: String = "above"
        static let aboveCurrency: String = "above_currency"
    }
    
    init?(json: [String : AnyObject]) {
        
        if let id = json[Key.id] as? String,
            let coin = json[Key.coin] as? String,
            let symbol = json[Key.symbol] as? String,
            let below = json[Key.below] as? String,
            let belowCurrency = json[Key.belowCurrency] as? String,
            let above = json[Key.above] as? String,
            let aboveCurrency = json[Key.aboveCurrency] as? String {
            self.id = id
            self.coin = coin
            self.symbol = symbol
            self.below = below
            self.belowCurrency = belowCurrency
            self.above = above
            self.aboveCurrency = aboveCurrency
        } else {
            self.id = ""
            self.coin = "Failed"
            self.symbol = "Failed"
            self.below = ""
            self.belowCurrency = ""
            self.above = ""
            self.aboveCurrency = ""
        }
        
        var action: AlertActions = .False
        
        if below != "" && belowCurrency == "USD" {
            action = .BelowUSD
        } else if below != "" && belowCurrency == "BTC" {
            action = .BelowBTC
        } else if above != "" && aboveCurrency == "USD" {
            action = .AboveUSD
        } else if above != "" && aboveCurrency == "BTC" {
            action = .AboveBTC
        } else {
            action = .False
        }
        
        self.action = action
    }
}
