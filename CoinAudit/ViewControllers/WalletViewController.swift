//
//  WalletViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter
import Alamofire
import SwiftSpinner
import GoogleMobileAds
import Localize_Swift

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var bitcoinLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var walletTableView: UITableView!
    @IBOutlet var walletValueTotalLabel: UILabel!
    @IBOutlet var adView: GADBannerView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    @IBOutlet var walletTotalView: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var walletPercent: UILabel!
    
    var managedObjectContext = getContext()
    var walletTotal: Double = 0.0
    var bitcoinTotal: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Ad View
        if showAd == "Yes" {
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        } else if showAd == "No" {
        } else {
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        }
        
        walletValue = defaults.string(forKey: "CoinAuditWalletMode") ?? "Value"
        walletEntryValue = defaults.string(forKey: "CoinAuditWalletEntry") ?? "WalletEntry1"
        
        walletTableView.delegate = self
        walletTableView.dataSource = self
        walletTableView.allowsSelectionDuringEditing = true
        
        // reload view observer
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
    
        let updateButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(updateCoins))
        updateButton.image = #imageLiteral(resourceName: "refresh")
        self.navigationItem.leftBarButtonItem = updateButton
        
        self.calculateWallet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
        
        if showAd == "Yes" {
            adView.isHidden = false
            tableViewBottom.constant = 50.0
        } else if showAd == "No" {
            adView.isHidden = true
            tableViewBottom.constant = 0.0
        } else {
            adView.isHidden = false
            tableViewBottom.constant = 50.0
        }
        
        if let selectionIndexPath = self.walletTableView.indexPathForSelectedRow {
            self.walletTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        if holdWalletEntry {
            holdWalletEntry = false
        } else {
            switch walletEntryValue {
            case "WalletEntry1":
                self.navigationItem.title = "Wallet 1".localized()
            case "WalletEntry2":
                self.navigationItem.title = "Wallet 2".localized()
            case "WalletEntry3":
                self.navigationItem.title = "Wallet 3".localized()
            case "WalletEntry4":
                self.navigationItem.title = "Wallet 4".localized()
            case "WalletEntry5":
                self.navigationItem.title = "Wallet 5".localized()
            default:
                walletEntryValue = "WalletEntry1"
                self.navigationItem.title = "Wallet 1".localized()
            }
        }
        
        if entries.count != 0 {
            updateList()
        } else {
            walletPercent.isHidden = true
            SweetAlert().showAlert("Coin Data Not  Found".localized(), subTitle: "Please check your internet connection".localized(), style: AlertStyle.none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        holdWalletEntry = true
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if walletEntries.count != 0 && entries.count != 0 {
            return walletEntries.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Action to delete data
            let cell = tableView.cellForRow(at: indexPath) as! WalletCell
        
            // get object using indexPath.row and delete
            let coin = walletEntries[indexPath.row]
            managedObjectContext.delete(coin)
            
            do {
                // try to save to CoreData
                try managedObjectContext.save()
                
                // remove from walletCoins
                walletEntries.remove(at: indexPath.row)
                
                // cleanup
                print("Deleted \(cell.nameLabel.text!) from wallet")
                self.walletTableView.deleteRows(at: [indexPath], with: .automatic)
                calculateWallet()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath) as! WalletCell
        // Configure the cell...
        
        // pull coin data from entries array
        guard let coinData = entries.first(where: { $0.id == walletEntries[indexPath.row].value(forKey: "id") as! String }) else {
            cell.nameLabel.text = "Unknown"
            cell.symbolLabel.text = "Unk"
            cell.valueLabel.text = "0.0"
            return cell
        }
        
        var coins: [WalletEntry] = []
        let data = walletEntries[indexPath.row].value(forKey: "data")
        coins = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [WalletEntry]
        
        cell.nameLabel.text = coinData.name
        cell.symbolLabel.text = coinData.symbol
        
        // pull coin data from entries array
        var percentCost: Double = 0.0
        var percentValue: Double = 0.0
        var coinCost: Double = 0.0
        var coinValue: Double = 0.0
        
        var amount = 0.0
        var entryValue  = ""
        
        for item in coins {
            var amount = 0.0
            var cost = 0.0
            if item.amount == "" {
                amount = 0.0
            } else {
                amount = Double(item.amount)!
            }
            
            if item.cost == "" {
                cost = 0.0
            } else {
                cost = Double(item.cost)!
            }
            
            let calcCost = (amount * cost)
            let calcValue = (amount * Double(coinData.priceUSD)!)
            
            percentValue = percentValue + calcValue
            percentCost = percentCost + calcCost
        }
    
        if priceFormat == "USD" {
            for item in coins {
                var amount = 0.0
                var cost = 0.0
                if item.amount == "" {
                    amount = 0.0
                } else {
                    amount = Double(item.amount)!
                }
                
                if item.cost == "" {
                    cost = 0.0
                } else {
                    cost = Double(item.cost)!
                }
                
                let calcCost = (amount * cost)
                let calcValue = (amount * Double(coinData.priceUSD)!)
                
                coinValue = coinValue + calcValue
                coinCost = coinCost + calcCost
            }
            entryValue = "\(coinValue)".formatUSD()
        } else {
            for item in coins {
                var amount = 0.0
                var cost = 0.0
                if item.amount == "" {
                    amount = 0.0
                } else {
                    amount = Double(item.amount)!
                }
                
                if item.cost == "" {
                    cost = 0.0
                } else {
                    cost = Double(item.cost)!
                }
                
                let calcCost = (amount * cost)
                let calcValue = (amount * Double(coinData.priceBTC)!)
                
                coinValue = coinValue + calcValue
                coinCost = coinCost + calcCost
            }
            entryValue = "\(coinValue) BTC"
        }
        
        let total = (percentValue - percentCost)

        if walletValue == "volume" {
            for item in coins {
                amount = amount + Double(item.amount)!
            }
            
            if total > 0 {
                // Profit or gain
                // Gain % = (gain / Cost Price × 100)%
                let gain = (percentValue) - (percentCost)
                let gainPercent = "\(gain / percentValue * 100)".formatDecimal()
        
                cell.valueLabel.text = "\(amount)"
                cell.percentLabel.text = "+\(gainPercent)%"
                cell.percentLabel.textColor = UIColor(hexString: "63DB37")
            } else if total < 0 {
                // Loss
                // Loss % = (loss/ Cost Price × 100)%
                let loss = (coinCost) - (percentValue)
                let lossPercent = "\(loss / percentCost * 100)".formatDecimal()
                
                cell.valueLabel.text = "\(amount)"
                cell.percentLabel.text = "-\(lossPercent)%"
                cell.percentLabel.textColor = UIColor(hexString: "FF483E")
            } else {
                cell.valueLabel.text = "Volume: \(amount)".localized()
                cell.percentLabel.text = ""
            }
        } else if walletValue == "value" {
            if total > 0 {
                // Profit or gain
                // Gain % = (gain / Cost Price × 100)%
                let gain = (percentValue) - (percentCost)
                let gainPercent = "\(gain / percentValue * 100)".formatDecimal()

                cell.valueLabel.text = "\(entryValue)"
                cell.percentLabel.text = "+\(gainPercent)%"
                cell.percentLabel.textColor = UIColor(hexString: "63DB37")
            } else if total < 0 {
                // Loss
                // Loss % = (loss/ Cost Price × 100)%
                let loss = (percentCost) - (percentValue)
                let lossPercent = "\(loss / percentCost * 100)".formatDecimal()

                cell.valueLabel.text = "\(entryValue)"
                cell.percentLabel.text = "-\(lossPercent)%"
                cell.percentLabel.textColor = UIColor(hexString: "FF483E")
            } else {
                cell.valueLabel.text = "Value: \(coinValue)".localized()
                cell.percentLabel.text = ""
            }
        } else {
            print("Wallet Format not found. Using Default Format")
            if total > 0 {
                // Profit or gain
                // Gain % = (gain / Cost Price × 100)%
                let gain = (percentValue) - (percentCost)
                let gainPercent = "\(gain / percentValue * 100)".formatDecimal()

                cell.valueLabel.text = "\(entryValue)"
                cell.percentLabel.text = "+\(gainPercent)%"
                cell.percentLabel.textColor = UIColor(hexString: "63DB37")
            } else if total < 0 {
                // Loss
                // Loss % = (loss/ Cost Price × 100)%
                let loss = (percentCost) - (percentValue)
                let lossPercent = "\(loss / percentCost * 100)".formatDecimal()
                
                cell.valueLabel.text = "\(entryValue)"
                cell.percentLabel.text = "-\(lossPercent)%"
                cell.percentLabel.textColor = UIColor(hexString: "FF483E")
            } else {
                cell.valueLabel.text = "Value: \(coinValue)".localized()
                cell.percentLabel.text = ""
            }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addWallet") as! AddWalletViewController
        // sort wallet
        let coin = walletEntries[indexPath.row]

        controller.managedObjectContext = managedObjectContext
        controller.coinID = coin.objectID
        controller.name = coin.value(forKey: "name") as! String
        
        self.show(controller, sender: self)
    }
    
    @IBAction func addCoin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addWallet") as! AddWalletViewController
        controller.managedObjectContext = managedObjectContext
        
        self.show(controller, sender: self)
    }
    
    func calculateWallet() {
        var coinCost: Double = 0.0
        var newValue: Double = 0.0
        // zero out totals
        walletTotal = 0.0
        bitcoinTotal = 0.0
        
        for localCoin in walletEntries {
            guard let id = localCoin.value(forKey: "id") else { return }
            guard let coin = entries.first(where: {$0.id == "\(id)"}) else { return }
            guard let value = Double(localCoin.value(forKey: "value") as! String) else { return }
            self.walletTotal = self.walletTotal + (Double(coin.priceUSD)! * value)
            self.bitcoinTotal = self.bitcoinTotal + (Double(coin.priceBTC)! * value)
        }
        
        for item in walletEntries {
            var tempCosts: [WalletEntry] = []
            let data = item.value(forKey: "data")
            tempCosts = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [WalletEntry]
            guard let coinData = entries.first(where: { $0.name == item.value(forKey: "name") as! String }) else {
                print("coinData not found")
                return
            }
            
            for item in tempCosts {
                var amount = 0.0
                var cost = 0.0
                if item.amount == "" {
                    amount = 0.0
                } else {
                    amount = Double(item.amount)!
                }
                
                if item.cost == "" {
                    cost = 0.0
                } else {
                    cost = Double(item.cost)!
                }
                
                let calcCost = (amount * cost)
                let calcValue = (amount * Double(coinData.priceUSD)!)
                
                newValue = newValue + calcValue
                coinCost = coinCost + calcCost
            }
        }
        
        let total = (newValue - coinCost)
        
        if total > 0 {
            var attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.black]
            switch themeValue {
            case "dark":
                attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.white]
            default:
                attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.black]
            }
            // Profit or gain
            // Gain % = (gain / Cost Price × 100)%
            let gain = (newValue) - (coinCost)
            let gainPercent = "\(gain / newValue * 100)".formatDecimal()
            
            let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor(hexString: "63DB37")]
            let attributedString1 = NSMutableAttributedString(string:"Total Gain: ".localized(), attributes:attrs1)
            let attributedString2 = NSMutableAttributedString(string:"+\(gainPercent)%", attributes:attrs2)
            attributedString1.append(attributedString2)
            walletPercent.attributedText = attributedString1
        } else if total < 0 {
            
            var attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.black]
            switch themeValue {
            case "dark":
                attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.white]
            default:
                attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.black]
            }
            // Loss
            // Loss % = (loss/ Cost Price × 100)%
            let loss = (coinCost) - (newValue)
            let lossPercent = "\(loss / coinCost * 100)".formatDecimal()
            
            let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor(hexString: "FF483E")]
            let attributedString1 = NSMutableAttributedString(string:"Total Lost: ".localized(), attributes:attrs1)
            let attributedString2 = NSMutableAttributedString(string:"-\(lossPercent)%", attributes:attrs2)
            attributedString1.append(attributedString2)
            walletPercent.attributedText = attributedString1
        } else {
            switch themeValue {
            case "dark":
                walletPercent.textColor = UIColor.white
            default:
                walletPercent.textColor = UIColor.black
            }
        }
        
        // format wallet total label to currency
        let text = "\(walletTotal)".formatUSD()
        totalLabel.text = "\(text)"
        bitcoinLabel.text = "\(bitcoinTotal) BTC"
    }
    
    // MARK: Update CoreData Wallet
    @objc func updateList() {
        if showAd == "Yes" {
            adView.isHidden = false
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: walletEntryValue)
        
        do {
            let fetchedCoin = try managedObjectContext.fetch(fetchRequest)
            
            // reset wallet array
            walletEntries.removeAll()
            
            // add newly fetched coins to wallet
            for object in fetchedCoin {
                walletEntries.append(object as! NSManagedObject)
            }
            self.walletTableView.reloadData()
            if walletEntries.count == 0 {
                walletPercent.isHidden = true
            } else {
                walletPercent.isHidden = false
            }
            calculateWallet()
        } catch {
            fatalError("Failed to fetch coins: \(error)")
        }
    }
    
    @objc func updateCoins() {
        if Connectivity.isConnectedToInternet {
            SwiftSpinner.show(duration: 1.5, title: "Updating Data...".localized())
            pullData()
        } else {
            SweetAlert().showAlert("No internet connection".localized())
        }
    }
    
    @IBAction func previousWallet() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in })
        
        switch walletEntryValue {
        case "WalletEntry1":
            walletEntryValue = "WalletEntry5"
            self.navigationItem.title = "Wallet 5".localized()
            pageControl.currentPage = 4
        case "WalletEntry2":
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1".localized()
            pageControl.currentPage = 0
        case "WalletEntry3":
            walletEntryValue = "WalletEntry2"
            self.navigationItem.title = "Wallet 2".localized()
            pageControl.currentPage = 1
        case "WalletEntry4":
            walletEntryValue = "WalletEntry3"
            self.navigationItem.title = "Wallet 3".localized()
            pageControl.currentPage = 2
        case "WalletEntry5":
            walletEntryValue = "WalletEntry4"
            self.navigationItem.title = "Wallet 4".localized()
            pageControl.currentPage = 3
        default:
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1".localized()
            pageControl.currentPage = 0
        }
        
        managedObjectContext = getContext()
        saveWalletSettings()
        updateList()
    }
    
    @IBAction func nextWallet() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in })
        
        switch walletEntryValue {
        case "WalletEntry1":
            walletEntryValue = "WalletEntry2"
            self.navigationItem.title = "Wallet 2".localized()
            pageControl.currentPage = 1
        case "WalletEntry2":
            walletEntryValue = "WalletEntry3"
            self.navigationItem.title = "Wallet 3".localized()
            pageControl.currentPage = 2
        case "WalletEntry3":
            walletEntryValue = "WalletEntry4"
            self.navigationItem.title = "Wallet 4".localized()
            pageControl.currentPage = 3
        case "WalletEntry4":
            walletEntryValue = "WalletEntry5"
            self.navigationItem.title = "Wallet 5".localized()
            pageControl.currentPage = 4
        case "WalletEntry5":
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1".localized()
            pageControl.currentPage = 0
        default:
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1".localized()
            pageControl.currentPage = 0
        }
        
        managedObjectContext = getContext()
        saveWalletSettings()
        updateList()
    }
    
    func updateTheme() {
        // Theme Drawing code
        switch themeValue {
        case "dark":
            self.view.backgroundColor = UIColor.black
            bitcoinLabel.textColor = UIColor.white
            totalLabel.textColor = UIColor.white
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            walletValueTotalLabel.textColor = UIColor.white
            self.walletTableView.backgroundColor = UIColor.black
            walletTotalView.backgroundColor = UIColor.black
        default:
            walletTotalView.backgroundColor = UIColor.white
            self.walletTableView.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.white
            bitcoinLabel.textColor = UIColor.black
            totalLabel.textColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            walletValueTotalLabel.textColor = UIColor.black
        }
    }
}
