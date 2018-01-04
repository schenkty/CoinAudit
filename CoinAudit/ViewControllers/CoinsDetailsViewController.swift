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
    @IBOutlet var PercentChangeLabels: [UILabel]!
    
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
            favButton.setTitle("Remove Favorite", for: .normal)
        } else {
            self.favorited = false
            favButton.backgroundColor = UIColor.gray
            favButton.setTitle("Favorite", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if entries.count != 0 {
            self.formatData(coin: entries.first(where: {$0.id == id})!)
            self.formatPercents(coin: entries.first(where: {$0.id == id})!)
            updateTheme()
        }
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
            saveFavoriteSettings()
            print("Deleted: \(id) from favorites")
        } else {
            favorited = true
            favButton.backgroundColor = UIColor(hexString: "D65465")
            favButton.setTitle("Favorited", for: .normal)
            // save coin id to array
            favorites.append(id)
            favorites = favorites.sorted()
            saveFavoriteSettings()
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
            percent1Label.textColor = UIColor(hexString: "63DB37")
            percent1Label.text = "\(percent1)%"
        } else if (percent1 == 0.0) {
            // do zero stuff
            percent1Label.textColor = UIColor(hexString: "63DB37")
            percent1Label.text = "\(percent1)%"
        } else {
            // do negative stuff
            percent1Label.textColor = UIColor(hexString: "FF483E")
            percent1Label.text = "\(percent1)%"
        }
        
        if (percent24 > 0.0) {
            // do positive stuff
            percent24Label.textColor = UIColor(hexString: "63DB37")
            percent24Label.text = "\(percent24)%"
        } else if (percent24 == 0.0) {
            // do zero stuff
            percent24Label.textColor = UIColor(hexString: "63DB37")
            percent24Label.text = "\(percent24)%"
        } else {
            // do negative stuff
            percent24Label.textColor = UIColor(hexString: "FF483E")
            percent24Label.text = "\(percent24)%"
        }
        
        if (percent7 > 0.0) {
            // do positive stuff
            percent7Label.textColor = UIColor(hexString: "63DB37")
            percent7Label.text = "\(percent7)%"
        } else if (percent7 == 0.0) {
            // do zero stuff
            percent7Label.textColor = UIColor(hexString: "63DB37")
            percent7Label.text = "\(percent7)%"
        } else {
            // do negative stuff
            percent7Label.textColor = UIColor(hexString: "FF483E")
            percent7Label.text = "\(percent7)%"
        }
    }
    
    @objc func updateCoin() {
        if Connectivity.isConnectedToInternet {
            let name = self.navigationController?.navigationBar.topItem?.title
            
            SwiftSpinner.show(duration: 1.0, title: "Updating \(name!)...")
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        } else {
            showAlert(title: "No internet connection")
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = storyboard.instantiateViewController(withIdentifier: "main")
        self.present(mainController, animated: true, completion: nil)
    }
    
    func updateTheme() {
        switch themeValue {
        case "dark":
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            marketCapLabel.textColor = UIColor.white
            volumeLabel.textColor = UIColor.white
            circulatingSupplyLabel.textColor = UIColor.white
            maxSupplyLabel.textColor = UIColor.white
            priceUSDLabel.textColor = UIColor.white
            priceBTCLabel.textColor = UIColor.white
            for item in PercentChangeLabels {
                item.textColor = UIColor.white
            }
        default:
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.white
            self.navBar.tintColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            
            marketCapLabel.textColor = UIColor.black
            volumeLabel.textColor = UIColor.black
            circulatingSupplyLabel.textColor = UIColor.black
            maxSupplyLabel.textColor = UIColor.black
            priceUSDLabel.textColor = UIColor.black
            priceBTCLabel.textColor = UIColor.black
            for item in PercentChangeLabels {
                item.textColor = UIColor.black
            }
        }
    }
    
}
