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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearData(_ sender: Any) {
        favorites.removeAll()
        walletCoins.removeAll()
        saveWallet()
        saveFavorites()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
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
}
