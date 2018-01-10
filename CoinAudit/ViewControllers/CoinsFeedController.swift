//
//  CoinsFeedController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftSpinner
import OneSignal
import GoogleMobileAds
import Localize_Swift

class CoinsFeedController: UITableViewController, UISearchResultsUpdating, GADInterstitialDelegate {
    
    let coinsURL: String = "https://api.coinmarketcap.com/v1/ticker/?limit=0"
    var filteredEntries: [CoinEntry] = []
    var searchActive: Bool = false
    var alertsLoaded: Bool = false
    var entriesLoaded: Bool = false
    var interstitial: GADInterstitial!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAd = "No"
        saveAdsSettings()
        if showAd == "No" {
            print("Ads Unlocked")
        } else {
            interstitial = createAndLoadInterstitial()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Coin Name"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
        
        if Connectivity.isConnectedToInternet {
            self.updateData()
        } else {
            SweetAlert().showAlert("No internet connection")
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-8616771915576403/1551329017")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func displayAds() {
        if showAd == "Yes" {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
        // Update Coin Data
        self.updateList()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell

        // Configure the cell...
        let coin = self.filteredEntries[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
        controller.id = self.filteredEntries[indexPath.row].id
        
        self.show(controller, sender: self)
    }

    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredEntries = entries
        } else {
            // Filter the results
            filteredEntries = entries.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        
        self.tableView.reloadData()
    }
    
    @objc func updateList() {
        // update data
        self.tableView.reloadData()
    }
    
    @IBAction func updateButton(_ sender: Any) {
        if Connectivity.isConnectedToInternet {
            self.updateData()
        } else {
            SweetAlert().showAlert("No internet connection")
        }
    }
    
    func updateData() {
        // reset alert and entries array
        alerts.removeAll()
        entries.removeAll()
        
        // load favorites
        favorites = defaults.object(forKey:"CoinAuditFavorites") as? [String] ?? [String]()
        favorites = favorites.sorted()
        
        
        // Provide loading spinner
        SwiftSpinner.show("Downloading Data...", animated: true)
        
        // Pull Coin Data
        Alamofire.request(coinsURL).responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    entries.append(coin)
                }
            }
            self.entriesLoaded = true
            self.filteredEntries = entries
            
            if self.alertsLoaded && self.entriesLoaded {
                SwiftSpinner.hide()
            }
            
            // Update Table Views
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        }
        
        // MARK: Download Alert data
        // get id of user
        guard let id = notificationID else { return }
        
        // Pull Alert Data
        Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/get.php?id=\(id)").responseJSON { response in
            for alertJSON in (response.result.value as? [[String : AnyObject]])! {
                if let alert = AlertEntry.init(json: alertJSON) {
                    // do something here
                    alerts.append(alert)
                }
            }
            self.alertsLoaded = true
            if self.alertsLoaded && self.entriesLoaded {
                SwiftSpinner.hide()
            }
        }
        
        // give ad a few seconds to load ad
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.displayAds()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch themeValue {
        case "dark":
            return .lightContent
        default:
            return .default
        }
    }
    
    @objc func updateTheme() {
        switch themeValue {
        case "dark":
            // TextField Color Customization
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
            
            // Theme Color
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.tableView.backgroundColor = UIColor.black
            self.view.backgroundColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        default:
            // TextField Color Customization
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black]
            // Theme Color
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.tableView.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.white
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
        }
        UIApplication.shared.statusBarStyle = preferredStatusBarStyle
    }
}
