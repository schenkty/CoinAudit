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
    @IBOutlet var themeSelector: UISegmentedControl!
    @IBOutlet var walletModeView: UIStackView!
    @IBOutlet var widgetModeView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        widgetModeView.isHidden = true
        
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
        
        if themeValue == "light" {
            themeSelector.selectedSegmentIndex = 0
        } else if themeValue == "dark" {
            themeSelector.selectedSegmentIndex = 1
        } else {
            themeSelector.selectedSegmentIndex = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func clearData(_ sender: Any) {
        favorites.removeAll()
        walletCoins.removeAll()
        saveWallet()
        saveFavorites()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
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
        } else {
            widgetValue = "wallet"
        }
        saveWidgetMode()
    }
    
    
    @IBAction func themeMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            themeValue = "light"
        } else {
            themeValue = "dark"
        }
        saveTheme()
    }
    
    @IBAction func walletMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            walletValue = "volume"
        } else {
            walletValue = "value"
        }
        saveWallet()
    }
}
