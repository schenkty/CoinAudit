//
//  FavoritesTableViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire

class FavoritesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favorites = defaults.object(forKey:"favorites") as? [String] ?? [String]()
        favorites = favorites.sorted()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
        favorites = favorites.sorted()
        controller.id = favorites[indexPath.row]
        self.show(controller, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavCell
        favorites = favorites.sorted()
        let coin = entries.first(where: {$0.id == favorites[indexPath.row]})
    
        cell.nameLabel.text = coin!.name
        cell.symbolLabel.text = coin!.symbol
        cell.valueLabel.text = coin!.priceUSD.formatUSD()

        return cell
    }

}
