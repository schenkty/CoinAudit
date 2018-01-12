//
//  CoinEntry.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/27/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

struct CoinEntry {
    var id: String
    let name: String
    let symbol: String
    let rank: String
    let priceUSD: String
    let priceBTC: String
    let volumeUSD: String
    let marketCapUSD: String
    let availableSupply: String
    let totalSupply: String
    let maxSupply: String
    let percentChange1: String
    let percentChange24: String
    let percentChange7: String
    let lastUpdated: String
}

extension CoinEntry {
    struct Key {
        static let id = "id"
        static let name = "name"
        static let symbol = "symbol"
        static let rank = "rank"
        static let price_usd = "price_usd"
        static let price_btc = "price_btc"
        static let volume_usd = "24h_volume_usd"
        static let market_cap_usd = "market_cap_usd"
        static let available_supply = "available_supply"
        static let total_supply = "total_supply"
        static let max_supply = "max_supply"
        static let percent_change_1h = "percent_change_1h"
        static let percent_change_24h = "percent_change_24h"
        static let percent_change_7d = "percent_change_7d"
        static let last_updated = "last_updated"
    }
    

    init?(json: [String : AnyObject]) {
        
        if let id = json[Key.id] as? String,
            let name = json[Key.name] as? String,
            let symbol = json[Key.symbol] as? String,
            let rank = json[Key.rank] as? String, let lastUpdated = json[Key.last_updated] {
            
            self.id = id
            self.name = name
            self.symbol = symbol
            self.rank = rank
            self.lastUpdated = "\(lastUpdated)"
        } else {
            self.id = "bitcoin"
            self.name = "Bitcoin"
            self.symbol = "BTC"
            self.rank = "1"
            self.lastUpdated = "unknown"
        }
        
        var priceUSD = json[Key.price_usd] as? String
        var priceBTC = json[Key.price_btc] as? String
        var volumeUSD = json[Key.volume_usd] as? String
        var availableSupply = json[Key.available_supply] as? String
        var marketCapUSD = json[Key.market_cap_usd] as? String
        var maxSupply = json[Key.max_supply] as? String
        var percentChange1 = json[Key.percent_change_1h] as? String
        var percentChange24 = json[Key.percent_change_24h] as? String
        var percentChange7 = json[Key.percent_change_7d] as? String
        var totalSupply = json[Key.total_supply] as? String

        if priceUSD == nil {
            priceUSD = "unknown"
        }
        
        if volumeUSD == nil {
            volumeUSD = "unknown"
        }
        
        if priceBTC == nil {
            priceBTC = "unknown"
        }
        
        if availableSupply == nil {
            availableSupply = "unknown"
        }
        
        if marketCapUSD == nil {
            marketCapUSD = "unknown"
        }
        
        if maxSupply == nil {
            maxSupply = "unknown"
        }
        
        if percentChange1 == nil {
            percentChange1 = "unknown"
        }
        
        if percentChange24 == nil {
            percentChange24 = "unknown"
        }
        
        if percentChange7 == nil {
            percentChange7 = "unknown"
        }
        
        if totalSupply == nil {
            totalSupply = "unknown"
        }
            
        self.priceUSD = priceUSD!
        self.priceBTC = priceBTC!
        self.volumeUSD = volumeUSD!
        self.marketCapUSD = marketCapUSD!
        self.availableSupply = availableSupply!
        self.totalSupply = totalSupply!
        self.maxSupply = maxSupply!
        self.percentChange1 = percentChange1!
        self.percentChange24 = percentChange24!
        self.percentChange7 = percentChange7!
    }
}
