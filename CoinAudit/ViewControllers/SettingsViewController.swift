//
//  SettingsViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var walletSelector: UISegmentedControl!
    @IBOutlet var widgetSelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if widgetValue == "favorites" {
            widgetSelector.selectedSegmentIndex = 0
        } else if widgetValue == "wallet" {
            widgetSelector.selectedSegmentIndex = 1
        } else {
            widgetSelector.selectedSegmentIndex = 0
        }
        
        if walletValue == "volume" {
            walletSelector.selectedSegmentIndex = 0
        } else if walletValue == "value" {
            walletSelector.selectedSegmentIndex = 1
        } else {
            walletSelector.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func clearData(_ sender: Any) {
        favorites.removeAll()
        walletCoins.removeAll()
        saveWallet()
        saveFavorites()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoinAuditReload"), object: nil)
        showAlert(title: "Data removed")
    }
    
    @IBAction func developerButton(_ sender: Any) {
        if let link = URL(string: "https://tyschenk.com") {
            UIApplication.shared.open(link)
        }
    }
    
    @IBAction func poweredButton(_ sender: Any) {
        if let link = URL(string: "https://coinmarketcap.com") {
            UIApplication.shared.open(link)
        }
    }
    
    @IBAction func widgetMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            widgetValue = "favorites"
            saveWidgetMode()
        } else {
            widgetValue = "wallet"
            saveWidgetMode()
        }
    }
    
    @IBAction func walletMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            walletValue = "volume"
            saveWallet()
        } else {
            walletValue = "value"
            saveWallet()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoinAuditReload"), object: nil)
    }
}
