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

class CoinsFeedController: UITableViewController, UISearchResultsUpdating {
    
    let coinsURL: String = "https://api.coinmarketcap.com/v1/ticker/?limit=0"
    var filteredEntries: [CoinEntry] = []
    var searchActive: Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
    
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Coin Name"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
        
        if Connectivity.isConnectedToInternet {
            self.updateData()
        } else {
            showAlert(title: "No internet connection")
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
            showAlert(title: "No internet connection")
        }
    }
    
    func updateData() {
        favorites = defaults.object(forKey:"CoinAuditFavorites") as? [String] ?? [String]()
        favorites = favorites.sorted()
        // Provide using with loading spinner
        SwiftSpinner.show("Downloading Data...", animated: true)
        // Pull Coin Data
        Alamofire.request(coinsURL).responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    entries.append(coin)
                }
            }
            
            self.filteredEntries = entries
            // Update Table Views
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
            SwiftSpinner.hide()
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
    }
}
