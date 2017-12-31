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
        
        if favorites.count == 0 {
            print("No Favorites Found")
            self.errorLabel.isHidden = false
        } else {
            print("Found \(favorites.count) Favorites")
            self.errorLabel.isHidden = true
        }
    }
    
    func viewWillAppear(_ animated: Bool) {
        loadWallet()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if widgetValue == "favorites" {
            return favorites.count
        } else if widgetValue == "wallet" {
            return walletCoins.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if updating == true { return }
        
        favorites = favorites.sorted()
        let id = favorites[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteCell
        
        // Pull Coin Data
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        
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
        
        if let selectionIndexPath = self.favoritesTableView.indexPathForSelectedRow {
            self.favoritesTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavoriteCell
        // Configure the cell...
        favorites = favorites.sorted()
        let id = favorites[indexPath.row]
        
        // Pull Coin Data
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false

        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/\(id)/").responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    cell.nameLabel.text = coin.name
                    cell.symbolLabel.text = coin.symbol
                    cell.valueLabel.text = coin.priceUSD.formatUSD()
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
        
        if let selectionIndexPath = self.favoritesTableView.indexPathForSelectedRow {
            self.favoritesTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        return cell
    }
}
