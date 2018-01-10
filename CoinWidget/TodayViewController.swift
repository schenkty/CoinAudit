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
    
    @IBOutlet var widgetTableView: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    
    var updating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        if Connectivity.isConnectedToInternet {
            widgetTableView.delegate = self
            
            themeValue = defaults.object(forKey: "CoinAuditTheme") as? String ?? String()
            favorites = defaults.object(forKey: "CoinAuditFavorites") as? [String] ?? [String]()
            widgetPercent = defaults.object(forKey: "CoinAuditWidgetPercent") as? String ?? String()
            priceFormat = defaults.object(forKey: "CoinAuditPriceFormat") as? String ?? "USD"
            
            if favorites.count == 0 {
                print("No Favorites Found")
                self.errorLabel.text = "Please add a favorite in CoinAudit"
                self.errorLabel.isHidden = false
                updating = false
                loadingIndicator.stopAnimating()
            } else {
                print("Found \(favorites.count) Favorites")
                self.errorLabel.isHidden = true
                self.widgetTableView.reloadData()
            }
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            self.errorLabel.isHidden = false
            self.errorLabel.text = "Can not load CoinAudit. No Internet"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
        self.widgetTableView.reloadData()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        themeValue = defaults.object(forKey: "CoinAuditTheme") as? String ?? String()

        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorites.count != 0 && Connectivity.isConnectedToInternet {
            return favorites.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if updating == true { return }
        favorites = favorites.sorted()
        
        if let selectionIndexPath = self.widgetTableView.indexPathForSelectedRow {
            self.widgetTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        self.widgetTableView.reloadData()
        if extensionContext?.widgetActiveDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: (44 * widgetTableView.numberOfRows(inSection: 0)))
        } else {
            preferredContentSize = CGSize(width: 0, height: 88)
        }
        
        if let url = URL(string: "coinaudit://\(favorites[indexPath.row])") {
            self.extensionContext?.open(url, completionHandler: {success in print("url complete: \(success)")})
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! WidgetCell
        // Configure the cell...
        var id = ""
        
        switch themeValue {
        case "dark":
            cell.nameLabel.textColor = UIColor.white
            cell.symbolLabel.textColor = UIColor.white
            cell.valueLabel.textColor = UIColor.white
        default:
            cell.nameLabel.textColor = UIColor.black
            cell.symbolLabel.textColor = UIColor.black
            cell.valueLabel.textColor = UIColor.black
        }
        
        // Pull Coin Data
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        
        self.updating = true
        
        favorites = favorites.sorted()
        id = favorites[indexPath.row]
        var percent = 0.0
        
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/\(id)/").responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    cell.nameLabel.text = coin.name
                    cell.symbolLabel.text = coin.symbol
                    
                    if priceFormat == "USD" {
                        cell.valueLabel.text = coin.priceUSD.formatUSD()
                    } else {
                        cell.valueLabel.text = "\(coin.priceBTC) BTC"
                    }
                    
                    // handle for 1 hour and 24 hour percent modes
                    if widgetPercent == "1h" {
                        if coin.percentChange1 != "unknown" {
                            percent = Double(coin.percentChange1)!
                        } else {
                            percent = 0.0
                        }
                    } else if widgetPercent == "24h" {
                        if coin.percentChange24 != "unknown" {
                            percent = Double(coin.percentChange24)!
                        } else {
                            percent = 0.0
                        }
                    } else {
                        if coin.percentChange24 != "unknown" {
                            percent = Double(coin.percentChange24)!
                        } else {
                            percent = 0.0
                        }
                    }
                    if (percent > 0.0) {
                        // do positive stuff
                        cell.percentLabel.backgroundColor = UIColor(hexString: "63DB37")
                        cell.percentLabel.text = "\(percent)%"
                    } else if (percent == 0.0) {
                        // do zero stuff
                        cell.percentLabel.backgroundColor = UIColor(hexString: "63DB37")
                        cell.percentLabel.text = "\(percent)%"
                    } else {
                        // do negative stuff
                        cell.percentLabel.backgroundColor = UIColor(hexString: "FF483E")
                        cell.percentLabel.text = "\(percent)%"
                    }
                    
                    self.loadingIndicator.stopAnimating()
                    self.updating = false
                }
            }
        }
        
        if let selectionIndexPath = self.widgetTableView.indexPathForSelectedRow {
            self.widgetTableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        return cell
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: (44 * widgetTableView.numberOfRows(inSection: 0)) + 8)
        } else {
            preferredContentSize = CGSize(width: 0, height: 118)
        }
    }
    
    func updateTheme() {
        // Theme Drawing code
        switch themeValue {
        case "dark":
            self.view.backgroundColor = UIColor.black
        default:
            self.view.backgroundColor = UIColor.clear
        }
    }
}
