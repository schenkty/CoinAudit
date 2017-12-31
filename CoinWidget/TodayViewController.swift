//
//  TodayViewController.swift
//  CoinWidget
//
//  Created by Ty Schenk on 12/31/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var favoritesTableView: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    
    var updating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        favoritesTableView.delegate = self
    
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if widgetValue == "wallet" {
            loadWallet()
            if walletCoins.count == 0 {
                print("No Wallet Found")
                self.errorLabel.text = "Please add coins to your wallet in CoinAudit"
                self.errorLabel.isHidden = false
            } else {
                print("Found \(walletCoins.count) Coins from Wallet")
                self.errorLabel.isHidden = true
            }
        } else {
            favorites = defaults.object(forKey: "favorites") as? [String] ?? [String]()
            if favorites.count == 0 {
                print("No Favorites Found")
                self.errorLabel.text = "Please add a favorite in CoinAudit"
                self.errorLabel.isHidden = false
            } else {
                print("Found \(favorites.count) Favorites")
                self.errorLabel.isHidden = true
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        self.favoritesTableView.reloadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if widgetValue == "wallet" {
            return walletCoins.count
        } else {
            return favorites.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if updating == true { return }
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteCell
        
        if let selectionIndexPath = self.favoritesTableView.indexPathForSelectedRow {
            self.favoritesTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        self.favoritesTableView.reloadData()
        if extensionContext?.widgetActiveDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: (44 * favoritesTableView.numberOfRows(inSection: 0)) + 8)
        } else {
            preferredContentSize = CGSize(width: 0, height: 118)
        }
        
        if widgetValue == "wallet" {
            print("open wallet")
        } else {
            print("open favorite coin")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavoriteCell
        // Configure the cell...
        var id = ""
        
        // Pull Coin Data
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        
        switch widgetValue {
        case "wallet":
            // sort wallet
            walletCoins = walletCoins.sorted(by: { $0.id < $1.id })
            // pull id
            id = walletCoins[indexPath.row].id
            
            Alamofire.request("https://api.coinmarketcap.com/v1/ticker/\(id)/").responseJSON { response in
                for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                    if let coin = CoinEntry.init(json: coinJSON) {
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
                        
                        self.loadingIndicator.stopAnimating()
                        self.updating = false
                    }
                }
            }
            print("can't load wallet")
        default:
            favorites = favorites.sorted()
            id = favorites[indexPath.row]
            
            Alamofire.request("https://api.coinmarketcap.com/v1/ticker/\(id)/").responseJSON { response in
                for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                    if let coin = CoinEntry.init(json: coinJSON) {
                        cell.nameLabel.text = coin.name
                        cell.symbolLabel.text = coin.symbol
                        cell.valueLabel.text = coin.priceUSD.formatUSD()
                        
                        self.loadingIndicator.stopAnimating()
                        self.updating = false
                    }
                }
            }
        }
        
        if let selectionIndexPath = self.favoritesTableView.indexPathForSelectedRow {
            self.favoritesTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        return cell
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: (44 * favoritesTableView.numberOfRows(inSection: 0)) + 8)
        } else {
            preferredContentSize = CGSize(width: 0, height: 118)
        }
    }

}
