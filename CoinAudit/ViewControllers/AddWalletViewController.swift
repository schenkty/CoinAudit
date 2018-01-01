//
//  AddWalletViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import SearchTextField

class AddWalletViewController: UIViewController {

    @IBOutlet var nameTextField: SearchTextField!
    @IBOutlet var valueTexField: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var name: String = ""
    var value: String = ""
    var new: Bool = false
    
    var names: [SearchTextFieldItem] = []
    // pull coin index using provided name
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        valueTexField.addDoneButtonToKeyboard(myAction: #selector(self.valueTexField.resignFirstResponder))
        
        if name == "Unknown" {
            self.navigationController?.popViewController(animated: true)
        } else if name != "" {
            new = false
            // pull coin index using provided name
            saveButton.setTitle("Update", for: .normal)
            self.navigationItem.title = "\(name) Entry"
            index = walletCoins.index(where: {$0.name == name})!
            value = walletCoins[index].value
        } else {
            new = true
            saveButton.setTitle("Add", for: .normal)
            self.navigationItem.title = "New Entry"
        }
        
        for item in entries {
            let name = SearchTextFieldItem(title: item.name)
            names.append(name)
        }
        
        nameTextField.text = name
        valueTexField.text = value
        nameTextField.filterItems(names)
        nameTextField.inlineMode = true
        nameTextField.startSuggestingInmediately = true
    }
    
    @IBAction func addButton(_ sender: Any) {
        name = nameTextField.text!
        value = valueTexField.text!
        
        if new {
            saveCoin(name: name, value: value)
            self.navigationController?.popViewController(animated: true)
        } else {
            updateCoin(name: name, value: value)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateCoin(name: String, value: String) {
        if names.contains(where: {$0.title == name}) {
            let id = entries.first(where: {$0.name == name})!.id
            
            // update coin in walletCoins array
            walletCoins = walletCoins.sorted(by: { $0.id < $1.id })
            walletCoins[index] = WalletEntry(name: name, id: id, value: value)
            // save new version of walletCoins array
            saveWallet()
            
            print("\(name) Coin Updated")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        } else {
            print("Coin: \(name) is not Valid")
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
        }
    }
    
    func saveCoin(name: String, value: String) {
        if names.contains(where: {$0.title == name}) {
            // pull coin info using provided name
            let id = entries.first(where: {$0.name == name})!.id
            let newCoin: WalletEntry = WalletEntry(name: name, id: id, value: value)
            
            // add new coin to walletCoins array
            walletCoins.append(newCoin)
            walletCoins = walletCoins.sorted(by: { $0.id < $1.id })
            
            // save new version of walletCoins array
            saveWallet()
            
            print("\(name) Coin Saved")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
        } else {
            print("Coin: \(name) is not Valid")
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
        }
    }
}
