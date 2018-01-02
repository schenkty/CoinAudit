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
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var devButton: UIButton!
    @IBOutlet var clearDataButton: UIButton!
    @IBOutlet var poweredByButton: UIButton!
    
    
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
        updateTheme()
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
        updateTheme()
    }
    
    @IBAction func walletMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            walletValue = "volume"
        } else {
            walletValue = "value"
        }
        saveWallet()
    }
    
    func updateTheme() {
        switch themeValue {
        case "dark":
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            devButton.titleLabel?.textColor = UIColor.white
            clearDataButton.titleLabel?.textColor = UIColor.white
            poweredByButton.titleLabel?.textColor = UIColor.white
            walletSelector.tintColor = UIColor.white
            themeSelector.tintColor = UIColor.white
            for item in textLabels {
                item.textColor = UIColor.white
            }
        default:
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            devButton.titleLabel?.textColor = UIColor(hexString: "017AFF")
            clearDataButton.titleLabel?.textColor = UIColor(hexString: "017AFF")
            poweredByButton.titleLabel?.textColor = UIColor(hexString: "017AFF")
            walletSelector.tintColor = UIColor(hexString: "017AFF")
            themeSelector.tintColor = UIColor(hexString: "017AFF")
            for item in textLabels {
                item.textColor = UIColor.black
            }
        }
    }
}
