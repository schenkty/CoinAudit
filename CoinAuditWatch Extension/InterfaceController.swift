//
//  InterfaceController.swift
//  CoinAuditWatch Extension
//
//  Created by Ty Schenk on 1/3/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var coinTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

class CoinTableCell: NSObject {
    @IBOutlet var coinNameLabel: WKInterfaceLabel!
    
    
    
    
    
}




