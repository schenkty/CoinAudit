//
//  FavoritesViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import NotificationCenter
import GoogleMobileAds

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var favTableView: UITableView!
    @IBOutlet var adView: GADBannerView!
    
    override func viewWillAppear(_ animated: Bool) {
        favTableView.delegate = self
        favTableView.dataSource = self
        
        // MARK: Ad View
        adView.adUnitID = GoogleAd.appID
        adView.rootViewController = self
        adView.load(GADRequest())
        
        if showAd == "Yes" {
            adView.isHidden = false
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
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
        cell.valueLabel.text = coin.priceUSD.formatUSD()
        cell.rankLabel.text = "\(coin.rank)."
        
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
        }
    }

}
