//
//  CoinsTableViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class CoinsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let coinsURL: String = "https://api.coinmarketcap.com/v1/ticker/?limit=0"
    var filteredEntries: [CoinEntry] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Bitcoin"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    
        SwiftSpinner.show(duration: 1.5, title: "Downloading Data...")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Pull Coin Data
        self.updateData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.nameLabel.text = self.filteredEntries[indexPath.row].name
        cell.symbolLabel.text = self.filteredEntries[indexPath.row].symbol
        cell.valueLabel.text = self.filteredEntries[indexPath.row].priceUSD.formatUSD()
        
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
    
    func updateData() {
        // Pull Coin Data
        Alamofire.request(coinsURL).responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    entries.append(coin)
                }
            }
            
            self.filteredEntries = entries
            // Update Table Views
            self.tableView.reloadData()
        }
    }

    @IBAction func updateFeed(_ sender: Any) {
        // Provide using with loading spinner
        SwiftSpinner.show(duration: 1.5, title: "Updating Data...")
        
        // Clear entries array
        entries.removeAll()
        
        // update data
        self.updateData()
    }
}
