//
//  SettingsViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {

    let managedObjectContext = getContext()
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var walletSelector: UISegmentedControl!
    @IBOutlet var widgetSelector: UISegmentedControl!
    @IBOutlet var themeSelector: UISegmentedControl!
    @IBOutlet var widgetPercentSelector: UISegmentedControl!
    @IBOutlet var walletModeView: UIStackView!
    @IBOutlet var widgetModeView: UIStackView!
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var devButton: UIButton!
    @IBOutlet var clearDataButton: UIButton!
    @IBOutlet var poweredByButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        walletValue = defaults.object(forKey: "CoinAuditWalletMode") as? String ?? String()
        widgetPercent = defaults.object(forKey: "CoinAuditWidgetPercent") as? String ?? String()
        widgetValue = defaults.object(forKey: "CoinAuditWidget") as? String ?? String()
        
        // force disable widget mode changes
        widgetModeView.isHidden = true
        widgetValue = "favorites"
        saveWidgetSettings()
        
        if widgetValue == "favorites" {
            widgetSelector.selectedSegmentIndex = 0
        } else if widgetValue == "wallet" {
            widgetSelector.selectedSegmentIndex = 1
        } else {
            widgetSelector.selectedSegmentIndex = 0
        }
        
        if widgetPercent == "1h" {
            widgetPercentSelector.selectedSegmentIndex = 0
        } else if widgetPercent == "24h" {
            widgetPercentSelector.selectedSegmentIndex = 1
        } else {
            widgetPercentSelector.selectedSegmentIndex = 0
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
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
        versionLabel.text = "Version \(appVersion)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
    }
    
    @IBAction func clearData(_ sender: Any) {
        favorites.removeAll()
        var allCoins  = [WalletEntry]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WalletEntry")
        
        do {
            try allCoins = managedObjectContext.fetch(fetchRequest) as! [WalletEntry]
        } catch {
            print("error. could not delete")
        }
        
        for coin in allCoins {
            managedObjectContext.delete(coin)
        }
       
        do {
            try managedObjectContext.save()
            walletCoins.removeAll()
            print("All coins have been deleted from the wallet")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
        saveFavoriteSettings()
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
        saveWidgetSettings()
    }
    
    
    @IBAction func themeMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            themeValue = "light"
        } else {
            themeValue = "dark"
        }
        saveThemeSettings()
        updateTheme()
    }
    
    @IBAction func walletMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            walletValue = "volume"
        } else {
            walletValue = "value"
        }
        saveWalletSettings()
    }
    
    @IBAction func widgetPercentMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            widgetPercent = "1h"
        } else {
            widgetPercent = "24h"
        }
        saveWidgetSettings()
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
            self.walletSelector.tintColor = UIColor.white
            self.themeSelector.tintColor = UIColor.white
            self.widgetPercentSelector.tintColor = UIColor.white
            self.walletSelector.tintColor = UIColor.white
            for item in self.textLabels {
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
            self.walletSelector.tintColor = UIColor(hexString: "017AFF")
            self.themeSelector.tintColor = UIColor(hexString: "017AFF")
            self.widgetPercentSelector.tintColor = UIColor(hexString: "017AFF")
            self.walletSelector.tintColor = UIColor(hexString: "017AFF")
            for item in self.textLabels {
                item.textColor = UIColor.black
            }
        }
    }
}
