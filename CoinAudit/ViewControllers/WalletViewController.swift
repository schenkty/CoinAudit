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
    
    @IBOutlet var bitcoinLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var walletTableView: UITableView!
    
    var walletTotal: Double = 0.0
    var bitcoinTotal: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let selectionIndexPath = self.walletTableView.indexPathForSelectedRow {
            self.walletTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        walletTableView.delegate = self
        self.walletTableView.allowsSelectionDuringEditing = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        
        // load all
        loadWallet()
    
        let updateButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(updateCoins))
        updateButton.image = #imageLiteral(resourceName: "refresh")
        self.navigationItem.leftBarButtonItem = updateButton
        
        walletCoins = walletCoins.sorted(by: { $0.id < $1.id })
        self.calculateWallet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        walletCoins = walletCoins.sorted(by: { $0.id < $1.id })
        self.calculateWallet()
        self.walletTableView.reloadData()
        // Theme Drawing code
        switch themeValue {
        case "dark":
            self.walletTableView.backgroundColor = UIColor.black
            self.view.backgroundColor = UIColor.black
            bitcoinLabel.textColor = UIColor.white
            totalLabel.textColor = UIColor.white
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        default:
            self.walletTableView.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.white
            bitcoinLabel.textColor = UIColor.black
            totalLabel.textColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletCoins.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Action to delete data
            let cell = tableView.cellForRow(at: indexPath) as! WalletCell
            
            // remove
            walletCoins.remove(at: indexPath.row)
            
            // save new version of walletCoins array
            saveWallet()
            print("Deleted \(cell.nameLabel.text!) from wallet")
            
            calculateWallet()
            self.walletTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath) as! WalletCell
        // Configure the cell...
        // sort wallet
        walletCoins = walletCoins.sorted(by: { $0.id < $1.id })

        // pull coin data from entries array
        guard let coin = entries.first(where: {$0.id == walletCoins[indexPath.row].id}) else {
            cell.nameLabel.text = "Unknown"
            cell.symbolLabel.text = "Unk"
            cell.valueLabel.text = "0.0"
            return cell
        }
        
        cell.nameLabel.text = coin.name
        cell.symbolLabel.text = coin.symbol
        
        if walletValue == "volume" {
            cell.valueLabel.text = "\(walletCoins[indexPath.row].value)"
        } else if walletValue == "value" {
            cell.valueLabel.text = "\(Double(walletCoins[indexPath.row].value)! * Double(coin.priceUSD)!)".formatUSD()
        } else {
            print("Wallet Format not found")
            cell.valueLabel.text = "\(walletCoins[indexPath.row].value)"
        }
        
        // Theme Drawing code
        switch themeValue {
        case "dark":
            cell.backgroundColor = UIColor.black
            cell.nameLabel.textColor = UIColor.white
            cell.symbolLabel.textColor = UIColor.white
            cell.valueLabel.textColor = UIColor.white
        default:
            cell.backgroundColor = UIColor.white
            cell.nameLabel.textColor = UIColor.black
            cell.symbolLabel.textColor = UIColor.black
            cell.valueLabel.textColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WalletCell
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addWallet") as! AddWalletViewController
        // sort wallet
        guard let name = cell.nameLabel.text else { return }
        
        controller.name = name
        self.show(controller, sender: self)
    }
    
    @IBAction func addCoin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addWallet") as! AddWalletViewController
        
        self.show(controller, sender: self)
    }
    
    func calculateWallet() {
        // zero out totals
        walletTotal = 0.0
        bitcoinTotal = 0.0
        
        for localCoin in walletCoins {
            print("Calculating: \(localCoin.name)")
            
            guard let coin = entries.first(where: {$0.id == localCoin.id}) else { return }
            guard let value = Double(localCoin.value) else { return }
            self.walletTotal = self.walletTotal + (Double(coin.priceUSD)! * value)
            self.bitcoinTotal = self.bitcoinTotal + (Double(coin.priceBTC)! * value)
        }
        
        // format wallet total label to currency
        let text = "\(walletTotal)".formatUSD()
        totalLabel.text = "\(text) USD"
        bitcoinLabel.text = "\(bitcoinTotal) BTC"
    }
    
    @objc func updateList() {
        self.walletTableView.reloadData()
        calculateWallet()
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        }
    }
}
