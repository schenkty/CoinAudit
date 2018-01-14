//
//  AddAlertViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/7/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire
import SearchTextField
import GoogleMobileAds
import Localize_Swift
import SwiftTheme

class AddAlertViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var nameTextField: SearchTextField!
    @IBOutlet var aboveTextField: UITextField!
    @IBOutlet var belowTextField: UITextField!
    @IBOutlet var aboveSelector: UISegmentedControl!
    @IBOutlet var belowSelector: UISegmentedControl!
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var adView: GADBannerView!
    
    var names: [SearchTextFieldItem] = []
    var new: Bool = true
    var alertID: String = ""
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Ad View
        if showAd == "Yes" {
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        } else if showAd == "No" {
        } else {
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        }
        
        // setup names for text field
        for item in entries {
            let name = SearchTextFieldItem(title: item.name)
            names.append(name)
        }

        nameTextField.filterItems(names)
        nameTextField.inlineMode = false
        nameTextField.startSuggestingInmediately = true
        nameTextField.theme.font = UIFont.systemFont(ofSize: 15)
        nameTextField.theme.cellHeight = 40
        
        nameTextField.delegate = self
        aboveTextField.delegate = self
        belowTextField.delegate = self
        nameTextField.addDoneButtonToKeyboard(myAction:  #selector(self.nameTextField.resignFirstResponder))
        belowTextField.addDoneButtonToKeyboard(myAction:  #selector(self.belowTextField.resignFirstResponder))
        aboveTextField.addDoneButtonToKeyboard(myAction:  #selector(self.aboveTextField.resignFirstResponder))
        
        if new {
            self.navigationItem.title = "New Alert".localized()
            submitButton.backgroundColor = UIColor(hexString: "029C00")
            submitButton.setTitle("Add".localized(), for: .normal)
        } else {
            let alert = alerts[index]
            nameTextField.text = alert.coin
            
            if alert.above != "" {
                aboveTextField.text = alert.above
            } else {
                aboveTextField.text = alert.above
            }
            
            if alert.below != "" {
                belowTextField.text = alert.below
            } else {
                belowTextField.text = alert.below
            }
            
            if alert.aboveCurrency != "" {
                switch alert.aboveCurrency {
                case "USD":
                    aboveSelector.selectedSegmentIndex = 0
                case "BTC":
                    aboveSelector.selectedSegmentIndex = 1
                default:
                    aboveSelector.selectedSegmentIndex = 0
                }
            }
            
            if alert.belowCurrency != "" {
                switch alert.belowCurrency {
                case "USD":
                    belowSelector.selectedSegmentIndex = 0
                case "BTC":
                    belowSelector.selectedSegmentIndex = 1
                default:
                    belowSelector.selectedSegmentIndex = 0
                }
            }
            
            self.navigationItem.title = "\(alert.coin) Alert".localized()
            submitButton.backgroundColor = UIColor(hexString: "029C00")
            submitButton.setTitle("Update Alert".localized(), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
        
        if showAd == "Yes" {
            adView.isHidden = false
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
        }
    }

    func submitAlert() {
        var coin: String = ""
        var symbol: String = ""
        var below: String = ""
        var belowCurrency: String = ""
        var above: String = ""
        var aboveCurrency: String = ""
        
        guard let id = notificationID else {
            SweetAlert().showAlert("Alerts Disabled".localized(), subTitle: "Please allow notifications in your device settings and restart CoinAudit".localized(), style: AlertStyle.none)
            return
        }
        
        // make sure id is there
        if id == "" {
            return
        }
        
        if names.contains(where: {$0.title == nameTextField.text!}) {
            if Connectivity.isConnectedToInternet {
                // pull coin data from entries array using provided name
                guard let coinData = entries.first(where: {$0.name == nameTextField.text!}) else { return }
                symbol = coinData.symbol
                coin = coinData.name
                
                // if below value is setup then set the belowCurrency
                if belowTextField.text! != "" {
                    if belowSelector.selectedSegmentIndex == 0 {
                        belowCurrency = "USD"
                    } else {
                        belowCurrency = "BTC"
                    }
                    below = belowTextField.text!.replacingOccurrences(of: "$", with: "")
                }
                
                // if above value is setup then set the aboveCurrency
                if aboveTextField.text! != "" {
                    if aboveSelector.selectedSegmentIndex == 0 {
                        aboveCurrency = "USD"
                    } else {
                        aboveCurrency = "BTC"
                    }
                    above = aboveTextField.text!.replacingOccurrences(of: "$", with: "")
                }
                
                // name sure there is atleast one value setup
                if belowTextField.text! == "" && aboveTextField.text! == "" {
                    
                    SweetAlert().showAlert("Alert Failed".localized(), subTitle: "Please enter an amount for above or below fields".localized(), style: AlertStyle.none)
                    return
                }
            
                // add to server
                Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/add.php?id=\(id)&coin=\(coin)&symbol=\(symbol)&below=\(below)&below_currency=\(belowCurrency)&above=\(above)&above_currency=\(aboveCurrency)")
                
                newAlertData = true
                var action: AlertActions = .False
                
                if above != "" && below != "" {
                    action = .Both
                } else if above != "" {
                    action = .Above
                } else if below != "" {
                    action = .Below
                } else {
                    action = .False
                }
                
                alerts.append(AlertEntry(id: id, coin: coin, symbol: symbol, below: below, belowCurrency: belowCurrency, above: above, aboveCurrency: aboveCurrency, action: action))
                self.navigationController?.popViewController(animated: true)
            } else {
                SweetAlert().showAlert("No internet connection. Alert could not be added".localized())
            }
        } else {
            SweetAlert().showAlert("Invalid Name".localized(), subTitle: "Enter Valid Coin Name".localized(), style: AlertStyle.none)
        }
    }
    
    func editAlert() {
        var coin: String = ""
        var symbol: String = ""
        var below: String = ""
        var belowCurrency: String = ""
        var above: String = ""
        var aboveCurrency: String = ""
        
        guard let id = notificationID else {
            SweetAlert().showAlert("Alerts Disabled".localized(), subTitle: "Please allow notifications in your device settings and restart CoinAudit".localized(), style: AlertStyle.none)
            return
        }
        
        // make sure id is there
        if id == "" {
            return
        }
        
        if names.contains(where: {$0.title == nameTextField.text!}) {
            if Connectivity.isConnectedToInternet {
                // pull coin data from entries array using provided name
                guard let coinData = entries.first(where: {$0.name == nameTextField.text!}) else {
                    return
                }
                
                symbol = coinData.symbol
                coin = coinData.name
                
                // if below value is setup then set the belowCurrency
                if belowTextField.text! != "" {
                    if belowSelector.selectedSegmentIndex == 0 {
                        belowCurrency = "USD"
                    } else {
                        belowCurrency = "BTC"
                    }
                    below = belowTextField.text!.replacingOccurrences(of: "$", with: "")
                }
                
                // if above value is setup then set the aboveCurrency
                if aboveTextField.text! != "" {
                    if aboveSelector.selectedSegmentIndex == 0 {
                        aboveCurrency = "USD"
                    } else {
                        aboveCurrency = "BTC"
                    }
                    above = aboveTextField.text!.replacingOccurrences(of: "$", with: "")
                }
                
                // name sure there is atlease one value setup
                if belowTextField.text! == "" && aboveTextField.text! == "" {
                    SweetAlert().showAlert("Alert Failed".localized(), subTitle: "Please enter an amount for above or below fields".localized(), style: AlertStyle.none)
                    return
                }
    
                // add to server
                Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/update.php?id=\(id)&coin=\(coin)&symbol=\(symbol)&below=\(below)&below_currency=\(belowCurrency)&above=\(above)&above_currency=\(aboveCurrency)")
                
                newAlertData = false
                let action = alerts[index].action
                alerts[index] = AlertEntry(id: id, coin: coin, symbol: symbol, below: below, belowCurrency: belowCurrency, above: above, aboveCurrency: aboveCurrency, action: action)
                self.navigationController?.popViewController(animated: true)
            } else {
                SweetAlert().showAlert("No internet connection. Alert could not be added".localized())
            }
        } else {
            SweetAlert().showAlert("Invalid Name".localized(), subTitle: "Enter Valid Coin Name".localized(), style: AlertStyle.none)
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        if new == true {
            submitAlert()
        } else {
            editAlert()
        }
    }
    
    func updateTheme() {
        switch themeValue {
        case "dark":
            self.nameTextField.theme.fontColor = UIColor.white
            self.nameTextField.theme.bgColor = UIColor.black
        default:
            self.nameTextField.theme.fontColor = UIColor.black
            self.nameTextField.theme.bgColor = UIColor.white
        }
        self.tabBarController?.tabBar.theme_barTintColor = ["#000", "#FFF"]
        self.tabBarController?.tabBar.theme_tintColor = ["#FFF", "#000"]
        self.view.theme_backgroundColor = ["#000", "#FFF"]
        self.navigationItem.leftBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationItem.rightBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_barTintColor = ["#000", "#FFF"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_titleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
        self.navigationController?.navigationBar.theme_largeTitleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
        
        self.aboveSelector.theme_tintColor = ["#FFF", "#000"]
        self.belowSelector.theme_tintColor = ["#FFF", "#000"]
        self.nameTextField.theme_backgroundColor = ["#000", "#FFF"]
        self.belowTextField.theme_backgroundColor = ["#000", "#FFF"]
        self.aboveTextField.theme_backgroundColor = ["#000", "#FFF"]
        self.nameTextField.theme_textColor = ["#FFF", "#000"]
        self.belowTextField.theme_textColor = ["#FFF", "#000"]
        self.aboveTextField.theme_textColor = ["#FFF", "#000"]
        self.nameTextField.layer.theme_borderColor = ["#FFF", "#000"]
        self.belowTextField.layer.theme_borderColor = ["#FFF", "#000"]
        self.aboveTextField.layer.theme_borderColor = ["#FFF", "#000"]
        self.nameTextField.layer.borderWidth = 1.0
        self.belowTextField.layer.borderWidth = 1.0
        self.aboveTextField.layer.borderWidth = 1.0
        self.belowTextField.attributedPlaceholder = NSAttributedString(string:"$0.00", attributes:[NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        self.aboveTextField.attributedPlaceholder = NSAttributedString(string:"$0.00", attributes:[NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        self.nameTextField.theme.placeholderColor = UIColor.lightGray
        
        for item in textLabels {
            item.theme_textColor = ["#FFF", "#000"]
        }
    }
}
