//
//  FeedEntry.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/27/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation
import Money

/*
 sample api ref
 
 {
 "id": "bitcoin",
 "name": "Bitcoin",
 "symbol": "BTC",
 "rank": "1",
 "price_usd": "14919.4",
 "price_btc": "1.0",
 "24h_volume_usd": "12775600000.0",
 "market_cap_usd": "250154698755",
 "available_supply": "16767075.0",
 "total_supply": "16767075.0",
 "max_supply": "21000000.0",
 "percent_change_1h": "1.34",
 "percent_change_24h": "-10.08",
 "percent_change_7d": "-11.76",
 "last_updated": "1514436260"
 },
*/

struct CoinEntry {
    let id: String
    let name: String
    let symbol: String
    let rank: String
    var priceUSD: USD
    let priceBTC: String
    var volumeUSD: USD
    var marketCapUSD: USD
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
        static let title = "title"
        static let timestamp = "timestamp"
        static let imageURL = "image_url"
        static let description = "description"
    }
    
    init?(json: [String : AnyObject]) {
        guard let title = json[Key.title] as? String,
            let timestamp = json[Key.timestamp] as? String,
            let imageURL = json[Key.imageURL] as? String,
            let description = json[Key.description] as? String else { return nil }
        
        self.title = title
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.description = description
    }
}
