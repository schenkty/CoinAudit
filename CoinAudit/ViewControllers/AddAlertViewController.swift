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

class AddAlertViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var nameTextField: SearchTextField!
    @IBOutlet var aboveTextField: UITextField!
    @IBOutlet var belowTextField: UITextField!
    @IBOutlet var aboveSelector: UISegmentedControl!
    @IBOutlet var belowSelector: UISegmentedControl!
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var submitButton: UIButton!
    
    var names: [SearchTextFieldItem] = []
    var new: Bool = true
    var alertID: String = ""
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup names for text field
        for item in entries {
            let name = SearchTextFieldItem(title: item.name)
            names.append(name)
        }

        nameTextField.filterItems(names)
        nameTextField.inlineMode = true
        nameTextField.startSuggestingInmediately = true
        nameTextField.delegate = self
        aboveTextField.delegate = self
        belowTextField.delegate = self
        nameTextField.addDoneButtonToKeyboard(myAction:  #selector(self.nameTextField.resignFirstResponder))
        belowTextField.addDoneButtonToKeyboard(myAction:  #selector(self.belowTextField.resignFirstResponder))
        aboveTextField.addDoneButtonToKeyboard(myAction:  #selector(self.aboveTextField.resignFirstResponder))
        
        
        if new {
            self.navigationItem.title = "New Alert"
            submitButton.backgroundColor = UIColor(hexString: "029C00")
            submitButton.setTitle("Add", for: .normal)
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
            
            self.navigationItem.title = "\(alert.coin) Alert"
            submitButton.backgroundColor = UIColor(hexString: "029C00")
            submitButton.setTitle("Update Alert", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
    }

    func submitAlert() {
        var coin: String = ""
        var symbol: String = ""
        var below: String = ""
        var belowCurrency: String = ""
        var above: String = ""
        var aboveCurrency: String = ""
        
        guard let id = notificationID else {
            showAlert(title: "Alerts Disabled", message: "Please allow notifications in your device settings and restart CoinAudit", style: .alert)
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
                    showAlert(title: "Alert Failed", message: "Please Enter an amount for above or below fields", style: .alert)
                    return
                }
            
                // add to server
                Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/add.php?id=\(id)&coin=\(coin)&symbol=\(symbol)&below=\(below)&below_currency=\(belowCurrency)&above=\(above)&above_currency=\(aboveCurrency)")
                
                newAlertData = true
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlert(title: "No internet connection. Alert could not be added")
            }
        } else {
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
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
            showAlert(title: "Alerts Disabled", message: "Please allow notifications in your device settings and restart CoinAudit", style: .alert)
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
                    showAlert(title: "Alert Failed", message: "Please Enter an amount for above or below fields", style: .alert)
                    return
                }
    
                // add to server
                Alamofire.request("https://www.tyschenk.com/coinaudit/alerts/update.php?id=\(id)&coin=\(coin)&symbol=\(symbol)&below=\(below)&below_currency=\(belowCurrency)&above=\(above)&above_currency=\(aboveCurrency)")
                
                newAlertData = false
                let action = alerts[index].action
                alerts[index] = AlertEntry(id: id, coin: coin, symbol: symbol, below: below, belowCurrency: belowCurrency, above: above, aboveCurrency: aboveCurrency, action: action)
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlert(title: "No internet connection. Alert could not be added")
            }
        } else {
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
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
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.aboveSelector.tintColor = UIColor.white
            self.belowSelector.tintColor = UIColor.white
            self.nameTextField.backgroundColor = UIColor.white
            self.belowTextField.backgroundColor = UIColor.white
            self.aboveTextField.backgroundColor = UIColor.white
            for item in textLabels {
                item.textColor = UIColor.white
            }
        default:
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.nameTextField.backgroundColor = UIColor.white
            self.belowTextField.backgroundColor = UIColor.white
            self.aboveTextField.backgroundColor = UIColor.white
            self.aboveSelector.tintColor = UIColor(hexString: "017AFF")
            self.belowSelector.tintColor = UIColor(hexString: "017AFF")
            for item in textLabels {
                item.textColor = UIColor.black
            }
        }
    }
}
