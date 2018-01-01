//
//  CoinsDetailsViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftSpinner
import Alamofire

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
    @IBOutlet var navBar: UINavigationBar!
    
    var favorited: Bool = false
    var id: String = ""
    var mode: String = "normal"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if mode == "url" {
            navBar.isHidden = false
        } else {
            navBar.isHidden = true
        }
        
        
        let updateButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(updateCoin))
        updateButton.image = #imageLiteral(resourceName: "refresh")
        self.navigationItem.rightBarButtonItem = updateButton

        if favorites.contains(id) {
            self.favorited = true
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
        } else {
            self.favorited = false
            favButton.backgroundColor = .black
            favButton.setTitle("Favorite", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.formatData(coin: entries.first(where: {$0.id == id})!)
        self.formatPercents(coin: entries.first(where: {$0.id == id})!)
    }

    @IBAction func favoriteButton(_ sender: Any) {
        if favorited == true {
            favorited = false
            favButton.backgroundColor = .black
            favButton.setTitle("Favorite", for: .normal)
            // remove
            if let index = favorites.index(of: id) {
                favorites.remove(at: index)
            }
            saveFavorites()
            print("Deleted: \(id) from favorites")
        } else {
            favorited = true
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
            // save coin id to array
            favorites.append(id)
            favorites = favorites.sorted()
            saveFavorites()
            print("Added: \(id) from favorites")
        }
    }
    
    func formatData(coin: CoinEntry) {
        // set name of coin
        //nameLabel.text = coin.name
        self.navigationItem.title = coin.name
        
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
        var percent1 = 0.0
        var percent24 = 0.0
        var percent7 = 0.0
        
        if coin.percentChange1 != "unknown" {
            percent1 = Double(coin.percentChange1)!
        } else {
            percent1 = 0.0
        }
        
        if coin.percentChange24 != "unknown" {
            percent24 = Double(coin.percentChange24)!
        } else {
            percent24 = 0.0
        }
        
        if coin.percentChange7 != "unknown" {
            percent7 = Double(coin.percentChange7)!
        } else {
            percent7 = 0.0
        }
        
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
    
    @objc func updateCoin() {
        SwiftSpinner.show(duration: 1.0, title: "Updating \(nameLabel.text!)...")
        // Pull Coin Data
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/\(id)/").responseJSON { response in
            for coinJSON in (response.result.value as? [[String : AnyObject]])! {
                if let coin = CoinEntry.init(json: coinJSON) {
                    let index = entries.index(where: {$0.id == self.id})
                    entries[index!] = coin
                    self.formatData(coin: coin)
                    self.formatPercents(coin: coin)
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoinAuditReload"), object: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = storyboard.instantiateViewController(withIdentifier: "main")
        self.present(mainController, animated: true, completion: nil)
    }
    
}
