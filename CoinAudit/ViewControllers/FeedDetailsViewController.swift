//
//  FeedDetailsViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit

class FeedDetailsViewController: UIViewController {

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
    var coin = CoinEntry.init(id: "bitcoin", name: "Bitcoin", symbol: "BTC", rank: "1", priceUSD: "0.0", priceBTC: "1", volumeUSD: "0", marketCapUSD: "0", availableSupply: "0", totalSupply: "0", maxSupply: "0", percentChange1: "0", percentChange24: "0", percentChange7: "0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Data from coin
        formatData()
        formatPercents()
        
        // Set Fav Button
        if favorited == true {
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
        }
        
    }

    @IBAction func favoriteButton(_ sender: Any) {
        if favorited == true {
            favorited = false
            favButton.backgroundColor = .black
            favButton.setTitle("Favorite", for: .normal)
            
        } else {
            favorited = true
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
        }
    }
    
    
    func formatData() {
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
    
    func formatPercents() {
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
