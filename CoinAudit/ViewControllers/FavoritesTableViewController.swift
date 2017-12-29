//
//  FavoritesTableViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.allowsSelectionDuringEditing = true
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Action to delete data
            favorites = favorites.sorted()
            // remove
            favorites.remove(at: indexPath.row)
            defaults.set(favorites, forKey: "favorites")
            let cell = tableView.cellForRow(at: indexPath) as! FavCell
            print("Deleted: \(cell.nameLabel.text!) from favorites")
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
