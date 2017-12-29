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
        coins = defaults.object(forKey:"Coins") as? [String] ?? [String]()
        coins = coins.sorted()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedDetails") as! CoinsDetailsViewController
        coins = coins.sorted()
        controller.id = coins[indexPath.row]
        self.show(controller, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavCell
        coins = coins.sorted()
        let coin = entries.first(where: {$0.id == coins[indexPath.row]})
    
        cell.nameLabel.text = coin!.name
        cell.symbolLabel.text = coin!.symbol
        cell.valueLabel.text = coin!.priceUSD.formatUSD()

        return cell
    }

}
