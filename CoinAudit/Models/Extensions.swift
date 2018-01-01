//
//  Extensions.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func formatUSD() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        guard Double(self) != nil else {
            return ""
        }
        
        return formatter.string(from: NSNumber(value: Double(self)!))!
    }
    
    func formatDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: Double(self)!))!
    }
}

extension UIViewController {
    // allows for simple handling of UIAlerts
    func showAlert(title: String, message: String? = nil, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UITextField{
    func addDoneButtonToKeyboard(myAction:Selector?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
