//
//  FavoritesViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import NotificationCenter
import GoogleMobileAds
import Localize_Swift
import SwiftTheme

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var favTableView: UITableView!
    @IBOutlet var adView: GADBannerView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        favTableView.delegate = self
        favTableView.dataSource = self
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        
        if let selectionIndexPath = self.favTableView.indexPathForSelectedRow {
            self.favTableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
        
        self.favTableView.allowsSelectionDuringEditing = true
        favorites = defaults.object(forKey:"CoinAuditFavorites") as? [String] ?? [String]()
        favorites = favorites.sorted()
        self.favTableView.reloadData()
        updateTheme()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorites.count != 0 && entries.count != 0 {
            return favorites.count
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
            favorites = favorites.sorted()
            // remove
            favorites.remove(at: indexPath.row)
            defaults.set(favorites, forKey: "CoinAuditFavorites")
            let cell = tableView.cellForRow(at: indexPath) as! FavCell
            print("Deleted: \(cell.nameLabel.text!) from favorites")
            self.favTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
        favorites = favorites.sorted()
        controller.id = favorites[indexPath.row]
        self.show(controller, sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavCell
        favorites = favorites.sorted()
        guard let coin = entries.first(where: {$0.id == favorites[indexPath.row]}) else {
            cell.nameLabel.text = "Unknown"
            cell.symbolLabel.text = "Unk"
            cell.valueLabel.text = "0.0".formatUSD()
            return cell
        }
    
        cell.nameLabel.text = coin.name
        cell.symbolLabel.text = coin.symbol
        
        cell.rankLabel.text = "\(coin.rank)."
        
        if priceFormat == "USD" {
            cell.valueLabel.text = coin.priceUSD.formatUSD()
        } else {
            cell.valueLabel.text = "\(coin.priceBTC) BTC"
        }
        
        // Theme Drawing code
        switch themeValue {
        case "dark":
            cell.backgroundColor = UIColor.black
            cell.nameLabel.textColor = UIColor.white
            cell.symbolLabel.textColor = UIColor.white
            cell.valueLabel.textColor = UIColor.white
            cell.rankLabel.textColor = UIColor.white
        default:
            cell.backgroundColor = UIColor.white
            cell.nameLabel.textColor = UIColor.black
            cell.symbolLabel.textColor = UIColor.black
            cell.valueLabel.textColor = UIColor.black
            cell.rankLabel.textColor = UIColor.black
        }

        return cell
    }
    
    @objc func updateList() {
        if showAd == "Yes" {
            adView.isHidden = false
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
        }
        self.favTableView.reloadData()
    }
    
    @IBAction func updateCoins(_ sender: Any) {
        if Connectivity.isConnectedToInternet {
            SwiftSpinner.show(duration: 1.5, title: "Updating Data...".localized())
            pullData()
        } else {
            SweetAlert().showAlert("No internet connection".localized())
        }
    }
    
    func updateTheme() {
        self.tabBarController?.tabBar.theme_barTintColor = ["#000", "#FFF"]
        self.tabBarController?.tabBar.theme_tintColor = ["#FFF", "#000"]
        self.view.theme_backgroundColor = ["#000", "#FFF"]
        self.favTableView.theme_backgroundColor = ["#000", "#FFF"]
        self.navigationItem.leftBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationItem.rightBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_barTintColor = ["#000", "#FFF"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        
        self.navigationController?.navigationBar.theme_titleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
        self.navigationController?.navigationBar.theme_largeTitleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
    }

}
