//
//  WalletViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import NotificationCenter

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var walletTableView: UITableView!
    
    var walletTotal: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        walletTableView.delegate = self
        
        let updateButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(updateCoins))
        updateButton.image = #imageLiteral(resourceName: "refresh")
        self.navigationItem.leftBarButtonItem = updateButton

        // DEBUG ENTRIES
        //walletCoins.append(WalletEntry(name: "Bitcoin", id: "bitcoin", value: 0.25))
        //walletCoins.append(WalletEntry(name: "RaiBlocks", id: "raiblocks", value: 480.0))
        //walletCoins.append(WalletEntry(name: "Ethereum", id: "ethereum", value: 700.0))
        
        self.calculateWallet()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath) as! WalletCell
        // Configure the cell...
        walletCoins = walletCoins.sorted(by: { $0.id < $1.id })
        //walletCoins.sorted(by: walletCoins[indexPath.row].name)
        let coin = entries.first(where: {$0.id == walletCoins[indexPath.row].id})
        
        cell.nameLabel.text = coin?.name
        cell.symbolLabel.text = coin?.symbol
        cell.valueLabel.text = "\(walletCoins[indexPath.row].value)"
        
        return cell
    }
    
    @IBAction func addCoin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addWallet") as! AddWalletViewController
        
        self.show(controller, sender: self)
    }
    
    func calculateWallet() {
        walletTotal = 0.0
        for localCoin in walletCoins {
            print("Calculating: \(localCoin.name)")
            
            let coin = entries.first(where: {$0.id == localCoin.id})
            self.walletTotal = self.walletTotal + (Double(coin!.priceUSD)! * localCoin.value)
        }
        // format wallet total label to currency
        totalLabel.text = "\(walletTotal)".formatUSD()
    }
    
    @objc func updateCoins() {
        SwiftSpinner.show(duration: 1.5, title: "Updating Data...")
        
        // Clear entries array
        entries.removeAll()
        
        // Pull Coin Data
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/?limit=0").responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    entries.append(coin)
                }
            }
            
            // Update data
            self.calculateWallet()
            self.walletTableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
        }
    }
    
}
