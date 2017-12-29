//
//  CoinsDetailsViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class CoinsDetailsViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var marketCapLabel: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    @IBOutlet var circulatingSupplyLabel: UILabel!
    @IBOutlet var maxSupplyLabel: UILabel!
    @IBOutlet var priceUSDLabel: UILabel!
    @IBOutlet var priceBTCLabel: UILabel!
    @IBOutlet var favButton: UIButton!
    @IBOutlet var percent1Label: UILabel!
    @IBOutlet var percent24Label: UILabel!
    @IBOutlet var percent7Label: UILabel!
    
    var favorited: Bool = false
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show("Downloading Data...", animated: true)
        self.self.formatData(coin: entries.first(where: {$0.id == id})!)
        
        self.formatPercents(coin: entries.first(where: {$0.id == id})!)
        
        if coins.contains(id) {
            self.favorited = true
        }
    
        // Set Fav Button
        if favorited == true {
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
        }
        SwiftSpinner.hide()
    }

    @IBAction func favoriteButton(_ sender: Any) {
        if favorited == true {
            favorited = false
            favButton.backgroundColor = .black
            favButton.setTitle("Favorite", for: .normal)
            // remove
            if let index = coins.index(of: id) {
                coins.remove(at: index)
            }
            defaults.set(coins, forKey: "Coins")
        } else {
            favorited = true
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
            // save coin id to array
            coins.append(id)
            coins = coins.sorted()
            defaults.set(coins, forKey: "Coins")
        }
    }
    
    func formatData(coin: CoinEntry) {
        // set name of coin
        nameLabel.text = coin.name
        self.navigationItem.title = coin.symbol
        
        // format prices and set to labels
        priceUSDLabel.text = "Price USD: \(coin.priceUSD.formatUSD())"
        priceBTCLabel.text = "Price BTC: \(coin.priceBTC)"
        
        if coin.marketCapUSD != "unknown" {
            marketCapLabel.text = "Market Cap: \(coin.marketCapUSD.formatUSD())"
        } else {
            marketCapLabel.text = "Market Cap: \(coin.marketCapUSD)"
        }
        
        if coin.volumeUSD != "unknown" {
            volumeLabel.text = "Volume (24h): \(coin.volumeUSD.formatUSD())"
        } else {
            volumeLabel.text = "Volume (24h): \(coin.volumeUSD)"
        }
        
        if coin.availableSupply != "unknown" {
            circulatingSupplyLabel.text = "Circulating Supply: \(coin.availableSupply.formatUSD())"
        } else {
            circulatingSupplyLabel.text = "Circulating Supply: \(coin.availableSupply)"
        }
        
        if coin.maxSupply != "unknown" {
            maxSupplyLabel.text = "Max Supply: \(coin.maxSupply.formatDecimal())"
        } else {
            maxSupplyLabel.text = "Max Supply: \(coin.maxSupply)"
        }
    }
    
    func formatPercents(coin: CoinEntry) {
        let percent1 = Double(coin.percentChange1)!
        let percent24 = Double(coin.percentChange24)!
        let percent7 = Double(coin.percentChange7)!
        
        if (percent1 > 0.0) {
            // do positive stuff
            percent1Label.textColor = UIColor(hexString: "008F00")
            percent1Label.text = "\(percent1)%"
        } else if (percent1 == 0.0) {
            // do zero stuff
            percent1Label.text = "\(percent1)%"
        } else {
            // do negative stuff
            percent1Label.textColor = .red
            percent1Label.text = "\(percent1)%"
        }
        
        if (percent24 > 0.0) {
            // do positive stuff
            percent24Label.textColor = UIColor(hexString: "008F00")
            percent24Label.text = "\(percent24)%"
        } else if (percent24 == 0.0) {
            // do zero stuff
            percent24Label.text = "\(percent24)%"
        } else {
            // do negative stuff
            percent24Label.textColor = .red
            percent24Label.text = "\(percent24)%"
        }
        
        if (percent7 > 0.0) {
            // do positive stuff
            percent7Label.textColor = UIColor(hexString: "008F00")
            percent7Label.text = "\(percent7)%"
        } else if (percent7 == 0.0) {
            // do zero stuff
            percent7Label.text = "\(percent7)%"
        } else {
            // do negative stuff
            percent7Label.textColor = .red
            percent7Label.text = "\(percent7)%"
        }
    }
    
}
