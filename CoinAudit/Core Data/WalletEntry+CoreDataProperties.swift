//
//  WalletEntry+CoreDataProperties.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/2/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import Foundation
import CoreData


extension WalletEntry {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletEntry> {
        return NSFetchRequest<WalletEntry>(entityName: "WalletEntry")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var value: String?
    
}
