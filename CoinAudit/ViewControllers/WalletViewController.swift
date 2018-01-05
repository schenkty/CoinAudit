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

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var bitcoinLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var walletTableView: UITableView!
    @IBOutlet var walletValueTotalLabel: UILabel!
    @IBOutlet var adView: GADBannerView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    @IBOutlet var walletTotalView: UIView!
    @IBOutlet var leftbutton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    
    var managedObjectContext = getContext()
    var walletTotal: Double = 0.0
    var bitcoinTotal: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        
        walletValue = defaults.string(forKey: "CoinAuditWalletMode")!
        walletEntryValue = defaults.string(forKey: "CoinAuditWalletEntry")!
        
        walletTableView.delegate = self
        self.walletTableView.allowsSelectionDuringEditing = true
        
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

        calculateWallet()
        
        if holdWalletEntry {
            holdWalletEntry = false
        } else {
            switch walletEntryValue {
            case "WalletEntry1":
                self.navigationItem.title = "Wallet 1"
            case "WalletEntry2":
                self.navigationItem.title = "Wallet 2"
            case "WalletEntry3":
                self.navigationItem.title = "Wallet 3"
            case "WalletEntry4":
                self.navigationItem.title = "Wallet 4"
            case "WalletEntry5":
                self.navigationItem.title = "Wallet 5"
            default:
                walletEntryValue = "WalletEntry1"
                self.navigationItem.title = "Wallet 1"
            }
        }
        
        if entries.count != 0 {
            updateList()
            updateTheme()
        } else {
            print("No coin entries")
            showAlert(title: "No Coins Found", message: "Please refresh the Coins Feed", style: .alert)
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
        if walletCoins.count != 0 && entries.count != 0 {
            return walletCoins.count
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
            let coin = walletCoins[indexPath.row]
            managedObjectContext.delete(coin)
            
            do {
                // try to save to CoreData
                try managedObjectContext.save()
                
                // remove from walletCoins
                walletCoins.remove(at: indexPath.row)
                
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
        guard let coin = entries.first(where: { $0.id == walletCoins[indexPath.row].value(forKey: "id") as! String }) else {
            cell.nameLabel.text = "Unknown"
            cell.symbolLabel.text = "Unk"
            cell.valueLabel.text = "0.0"
            return cell
        }
        
        cell.nameLabel.text = coin.name
        cell.symbolLabel.text = coin.symbol
        let value = walletCoins[indexPath.row].value(forKey: "value") as! String
        
        if walletValue == "volume" {
            cell.valueLabel.text = "\(value)"
        } else if walletValue == "value" {
            cell.valueLabel.text = "\(Double(value)! * Double(coin.priceUSD)!)".formatUSD()
        } else {
            print("Wallet Format not found. Using Default Format")
            cell.valueLabel.text = "\(value)"
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
        let coin = walletCoins[indexPath.row]

        controller.managedObjectContext = managedObjectContext
        controller.coinID = coin.objectID
        controller.name = coin.value(forKey: "name") as! String
        controller.value = coin.value(forKey: "value") as! String
        controller.start = coin.value(forKey: "startValue") as! String
        
        self.show(controller, sender: self)
    }
    
    @IBAction func addCoin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addWallet") as! AddWalletViewController
        controller.managedObjectContext = managedObjectContext
        
        self.show(controller, sender: self)
    }
    
    func calculateWallet() {
        updateTheme()
        // zero out totals
        walletTotal = 0.0
        bitcoinTotal = 0.0
        
        for localCoin in walletCoins {
            guard let id = localCoin.value(forKey: "id") else { return }
            guard let coin = entries.first(where: {$0.id == "\(id)"}) else { return }
            guard let value = Double(localCoin.value(forKey: "value") as! String) else { return }
            self.walletTotal = self.walletTotal + (Double(coin.priceUSD)! * value)
            self.bitcoinTotal = self.bitcoinTotal + (Double(coin.priceBTC)! * value)
        }
        
        // format wallet total label to currency
        let text = "\(walletTotal)".formatUSD()
        totalLabel.text = "\(text) USD"
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
            walletCoins.removeAll()
            
            // add newly fetched coins to wallet
            for object in fetchedCoin {
                walletCoins.append(object as! NSManagedObject)
            }
            self.walletTableView.reloadData()
            calculateWallet()
        } catch {
            fatalError("Failed to fetch coins: \(error)")
        }
    }
    
    @objc func updateCoins() {
        if Connectivity.isConnectedToInternet {
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
            }
        } else {
            showAlert(title: "No internet connection")
        }
    }
    
    @IBAction func previousWallet() {
        switch walletEntryValue {
        case "WalletEntry1":
            walletEntryValue = "WalletEntry5"
            self.navigationItem.title = "Wallet 5"
            pageControl.currentPage = 4
        case "WalletEntry2":
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1"
            pageControl.currentPage = 0
        case "WalletEntry3":
            walletEntryValue = "WalletEntry2"
            self.navigationItem.title = "Wallet 2"
            pageControl.currentPage = 1
        case "WalletEntry4":
            walletEntryValue = "WalletEntry3"
            self.navigationItem.title = "Wallet 3"
            pageControl.currentPage = 2
        case "WalletEntry5":
            walletEntryValue = "WalletEntry4"
            self.navigationItem.title = "Wallet 4"
            pageControl.currentPage = 3
        default:
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1"
            pageControl.currentPage = 0
        }
        
        managedObjectContext = getContext()
        saveWalletSettings()
        updateList()
    }
    
    @IBAction func nextWallet() {
        switch walletEntryValue {
        case "WalletEntry1":
            walletEntryValue = "WalletEntry2"
            self.navigationItem.title = "Wallet 2"
            pageControl.currentPage = 1
        case "WalletEntry2":
            walletEntryValue = "WalletEntry3"
            self.navigationItem.title = "Wallet 3"
            pageControl.currentPage = 2
        case "WalletEntry3":
            walletEntryValue = "WalletEntry4"
            self.navigationItem.title = "Wallet 4"
            pageControl.currentPage = 3
        case "WalletEntry4":
            walletEntryValue = "WalletEntry5"
            self.navigationItem.title = "Wallet 5"
            pageControl.currentPage = 4
        case "WalletEntry5":
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1"
            pageControl.currentPage = 0
        default:
            walletEntryValue = "WalletEntry1"
            self.navigationItem.title = "Wallet 1"
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
            leftbutton.tintColor = UIColor.white
            rightButton.tintColor = UIColor.white
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
            leftbutton.tintColor = UIColor.black
            rightButton.tintColor = UIColor.black
        }
    }
}
