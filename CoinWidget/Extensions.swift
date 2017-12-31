//
//  Extensions.swift
//  CoinWidget
//
//  Created by Ty Schenk on 12/31/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation

extension String {
    func formatUSD() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: Double(self)!))!
    }
    
    func formatDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: Double(self)!))!
    }
}
