//
//  WalletEntry.swift
//  CoinWidget
//
//  Created by Ty Schenk on 12/31/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

class WalletEntry: NSObject, NSCoding {
    let name: String
    let id: String
    let value: String
    
    init(name: String, id: String, value: String) {
        self.name = name
        self.id = id
        self.value = value
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.id = decoder.decodeObject(forKey: "id") as? String ?? ""
        self.value = decoder.decodeObject(forKey: "value") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(id, forKey: "id")
        coder.encode(value, forKey: "value")
    }
}
