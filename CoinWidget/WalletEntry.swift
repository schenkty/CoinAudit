//
//  WalletEntry.swift
//  CoinWidget
//
//  Created by Ty Schenk on 12/31/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

class WalletEntry: NSObject, NSCoding {
    var cost: String
    var amount: String
    
    init(cost: String, amount: String) {
        self.cost = cost
        self.amount = amount
    }
    
    required init(coder decoder: NSCoder) {
        self.cost = decoder.decodeObject(forKey: "cost") as? String ?? ""
        self.amount = decoder.decodeObject(forKey: "amount") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(cost, forKey: "cost")
        coder.encode(amount, forKey: "amount")
    }
}
