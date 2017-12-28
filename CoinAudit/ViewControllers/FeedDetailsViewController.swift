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
    
    
    var favorited: Bool = false
    var coin = CoinEntry.init(id: "bitcoin", name: "Bitcoin", symbol: "BTC", rank: "1", priceUSD: "0.0", priceBTC: "1", volumeUSD: "0", marketCapUSD: "0", availableSupply: "0", totalSupply: "0", maxSupply: "0", percentChange1: "0", percentChange24: "0", percentChange7: "0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Data from coin
        nameLabel.text = coin.name
        marketCapLabel.text = "Market Cap: \(coin.marketCapUSD)"
        volumeLabel.text = "Volume (24h): \(coin.volumeUSD)"
        circulatingSupplyLabel.text = "Circulating Supply: \(coin.availableSupply)"
        maxSupplyLabel.text = "Max Supply: \(coin.maxSupply)"
        priceUSDLabel.text = "Price USD: \(coin.priceUSD)"
        priceBTCLabel.text = "Price BTC: \(coin.priceBTC)"
        
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
}
