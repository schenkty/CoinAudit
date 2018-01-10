//
//  AddWalletViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/29/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import CoreData
import SearchTextField
import GoogleMobileAds

class AddWalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet var nameTextField: SearchTextField!
    @IBOutlet var adView: GADBannerView!
    @IBOutlet var walletTableView: UITableView!
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    
    var name: String = ""
    var value: String = ""
    var coinID: NSManagedObjectID!
    var new: Bool = false
    var names: [SearchTextFieldItem] = []
    var coins: [WalletEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        holdWalletEntry = true
        walletTableView.delegate = self
        walletTableView.dataSource = self
        walletTableView.allowsSelectionDuringEditing = true
        
        // new entry button
        let newButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(addCoin))
        newButton.image = #imageLiteral(resourceName: "plus")
        self.navigationItem.rightBarButtonItem = newButton
        
        // MARK: Ad View
        if showAd == "Yes" {
            adView.isHidden = false
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
            adView.adUnitID = GoogleAd.appID
            adView.rootViewController = self
            adView.load(GADRequest())
        }
        
        if name == "Unknown" {
            self.navigationController?.popViewController(animated: true)
        } else if name != "" {
            new = false
            // pull coin index using provided name
            self.navigationItem.title = "\(name) Entry"
            
            // core data
            let coin = managedObjectContext.object(with: coinID)
            let data = coin.value(forKey: "data")
            coins = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [WalletEntry]
            
            walletTableView.reloadData()
            calculateValue()
        } else {
            new = true
            self.navigationItem.title = "New Entry"
        }
        
        for item in entries {
            let name = SearchTextFieldItem(title: item.name)
            names.append(name)
        }
        
        nameTextField.text = name
        nameTextField.filterItems(names)
        nameTextField.inlineMode = true
        nameTextField.startSuggestingInmediately = true
        nameTextField.addDoneButtonToKeyboard(myAction:  #selector(self.nameTextField.resignFirstResponder))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if showAd == "Yes" {
            adView.isHidden = false
            tableViewBottom.constant = 50.0
        } else if showAd == "No" {
            adView.isHidden = true
            tableViewBottom.constant = 0.0
        } else {
            adView.isHidden = false
            tableViewBottom.constant = 50.0
        }
        
        self.walletTableView.reloadData()
        updateTheme()
        calculateValue()
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Action to delete data
            let cell = tableView.cellForRow(at: indexPath) as! WalletValueCell
            var newValue: Double = 0.0
            
            // remove from coins
            coins.remove(at: indexPath.row)
            let coin = managedObjectContext.object(with: coinID)
            
            let data = NSKeyedArchiver.archivedData(withRootObject: coins)
            
            for item in coins {
                let amount = Double(item.amount)!
                newValue = newValue + amount
            }
            
            value = "\(newValue)"
            
            if value == "" {
                value = "0.0"
            }
            
            coin.setValue(data, forKey: "data")
            coin.setValue(value, forKey: "value")
            
            do {
                // try to save to CoreData
                try managedObjectContext.save()
                // cleanup
                print("Deleted \(cell.amountLabel.text!) coins from your wallet")
                calculateValue()
                self.walletTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletValueCell", for: indexPath) as! WalletValueCell
        // Configure the cell...
        
        // pull coin data from entries array
        guard let coinData = entries.first(where: { $0.name == name }) else {
            cell.amountLabel.text = "0.0"
            cell.valueLabel.text = "0.00".formatUSD()
            return cell
        }
        
        let coin = coins[indexPath.row]
        
        cell.amountLabel.text = "\(coinData.name): \(coin.amount)"
        
        let coinCost: Double = (Double(coin.amount)! * Double(coin.cost)!)
        var newValue: Double = (Double(coin.amount)! * Double(coinData.priceUSD)!)
        
        let total = (newValue - coinCost)
        
        if total > 0 {
            // Profit or gain
            // Gain % = (gain / Cost Price × 100)%
            let gain = (newValue) - (coinCost)
            let percent = "\(gain / newValue * 100)".formatDecimal()
            
            cell.percentLabel.text = "+\(percent)%"
            cell.percentLabel.textColor = UIColor(hexString: "63DB37")
        } else if total < 0 {
            // Loss
            // Loss % = (loss/ Cost Price × 100)%
            let loss = (coinCost) - (newValue)
            let percent = "\(loss / coinCost * 100)".formatDecimal()
            
            cell.percentLabel.text = "-\(percent)%"
            cell.percentLabel.textColor = UIColor(hexString: "FF483E")
        }
        
        if priceFormat == "USD" {
            newValue = (Double(coin.amount)! * Double(coinData.priceUSD)!)
            cell.valueLabel.text = "\(newValue)".formatUSD()
        } else {
            newValue = (Double(coin.amount)! * Double(coinData.priceBTC)!)
            cell.valueLabel.text = "\(newValue) BTC"
        }
        
        // Theme Drawing code
        switch themeValue {
        case "dark":
            cell.backgroundColor = UIColor.black
            cell.amountLabel.textColor = UIColor.white
            cell.valueLabel.textColor = UIColor.white
        default:
            cell.backgroundColor = UIColor.white
            cell.amountLabel.textColor = UIColor.black
            cell.valueLabel.textColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect row
        self.walletTableView.deselectRow(at: indexPath, animated: true)
        
        // make sure this is an update not new save
        let tempNew = new
        new = false
        
        // setup alert controller
        let alert = UIAlertController(title: "Edit Coin", message: "Please edit the coin amount and price", preferredStyle: UIAlertControllerStyle.alert)
        
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let amountTextField = alert.textFields![0] as UITextField
            let costTextField = alert.textFields![1] as UITextField
            
            let cost = costTextField.text!.replacingOccurrences(of: "$", with: "")
            let amount = amountTextField.text!
            
            if cost == "" {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                SweetAlert().showAlert("Cost Missing", subTitle: "Can not add coin data without a coin cost", style: AlertStyle.error)
                return
            }
            
            if amount == "" {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                SweetAlert().showAlert("Amount Missing", subTitle: "Can not add coin data without a coin amount", style: AlertStyle.error)
                return
            }
            
            self.coins[indexPath.row].amount = amount
            self.coins[indexPath.row].cost = cost
            
            print("Coin Updated. Amount: \(amount) @ \(cost) each")
            self.saveButton()
            self.new = tempNew
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            return
        }
        
        alert.addTextField { (amountTextField) in
            amountTextField.placeholder = "Amount 0.00"
            amountTextField.keyboardType = .decimalPad
            amountTextField.text = self.coins[indexPath.row].amount
            
            let heightConstraint = NSLayoutConstraint(item: amountTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            amountTextField.addConstraint(heightConstraint)
        }
        
        alert.addTextField { (costTextField) in
            costTextField.placeholder = "Cost: $0.00"
            costTextField.keyboardType = .decimalPad
            costTextField.text = "$\(self.coins[indexPath.row].cost)"
            
            let heightConstraint = NSLayoutConstraint(item: costTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            costTextField.addConstraint(heightConstraint)
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addCoin() {
        var cost = "0.00"
        var amount = "0.0"
        
        if self.nameTextField.text! == "" {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            SweetAlert().showAlert("Name Missing", subTitle: "Can not add coin data without a coin name", style: AlertStyle.error)
            return
        }
        
        let alert = UIAlertController(title: "Add Coin", message: "Please add the coin amount and price when purchased", preferredStyle: UIAlertControllerStyle.alert)
        
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let amountTextField = alert.textFields![0] as UITextField
            let costTextField = alert.textFields![1] as UITextField
        
            cost = costTextField.text!
            amount = amountTextField.text!
            
            if cost == "" {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                SweetAlert().showAlert("Cost Missing", subTitle: "Can not add coin data without a coin cost", style: AlertStyle.error)
                return
            }
            
            if amount == "" {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                SweetAlert().showAlert("Amount Missing", subTitle: "Can not add coin data without a coin amount", style: AlertStyle.error)
                return
            }
            
            self.coins.append(WalletEntry(cost: cost, amount: amount))
            print("Coin Added. Amount: \(amount) @ \(cost) each")
            self.saveButton()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            UIApplication.shared.sendAction("resignFirstResponder", to:nil, from:nil, for:nil)
            return
        }
        
        alert.addTextField { (amountTextField) in
            amountTextField.placeholder = "Amount 0.00"
            amountTextField.keyboardType = .decimalPad
            
            let heightConstraint = NSLayoutConstraint(item: amountTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            amountTextField.addConstraint(heightConstraint)
        }
        
        alert.addTextField { (costTextField) in
            costTextField.placeholder = "Cost: 0.00"
            costTextField.keyboardType = .decimalPad
            
            let heightConstraint = NSLayoutConstraint(item: costTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            costTextField.addConstraint(heightConstraint)
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveButton() {
        name = nameTextField.text!
        if name != "" {
            if new {
                saveCoin(name: name)
            } else {
                updateCoin(name: name)
            }
        }
    }
    
    func updateCoin(name: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: coins)

        var newValue: Double = 0.0
        
        for item in coins {
            let amount = Double(item.amount)!
            newValue = newValue + amount
        }
        
        if names.contains(where: {$0.title == name}) {
            let id = entries.first(where: {$0.name == name})!.id
            
            // update coin in walletCoins array
            let coin = managedObjectContext.object(with: coinID)
            
            value = "\(newValue)"
            
            if value == "" {
                value = "0.0"
            }

            coin.setValue(id, forKey: "id")
            coin.setValue(name, forKey: "name")
            coin.setValue(value, forKey: "value")
            coin.setValue(data, forKey: "data")
            
            do{
                try managedObjectContext.save()
                print("\(name) Coin Updated")
                calculateValue()
                walletTableView.reloadData()
                new = false
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        } else {
            print("Coin: \(name) is not Valid")
            SweetAlert().showAlert("Invalid Name", subTitle: "Enter Valid Coin Name", style: AlertStyle.none)
        }
    }
    
    func saveCoin(name: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: coins)
        
        var newValue: Double = 0.0
        
        for item in coins {
            let amount = Double(item.amount)!
            newValue = newValue + amount
        }
        
        value = "\(newValue)"
        
        if value == "" {
            value = "0.0"
        }
        
        if names.contains(where: {$0.title == name}) {
            // pull coin info using provided name
            let id = entries.first(where: {$0.name == name})!.id
            
            // update coin in walletCoins array
            let walletData = NSEntityDescription.insertNewObject(forEntityName: walletEntryValue, into: managedObjectContext)
            
            walletData.setValue(id, forKey: "id")
            walletData.setValue(name, forKey: "name")
            walletData.setValue(value, forKey: "value")
            walletData.setValue(data, forKey: "data")
            
            do {
                try managedObjectContext.save()
                calculateValue()
                walletTableView.reloadData()
                new = false
                coinID = walletData.objectID
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
        } else {
            SweetAlert().showAlert("Invalid Name", subTitle: "Enter Valid Coin Name", style: AlertStyle.none)
        }
    }
    
    func calculateValue() {
        // pull coin data from entries array
        guard let coinData = entries.first(where: { $0.name == name }) else { return }
        var coinCost: Double = 0.0
        var newValue: Double = 0.0
        var amount: Double = 0.0
        
        for item in coins {
            let newAmount = Double(item.amount)!
            let cost = Double(item.cost)!
            
            let calcCost = (newAmount * cost)
            let calcValue = (newAmount * Double(coinData.priceUSD)!)
            
            newValue = newValue + calcValue
            coinCost = coinCost + calcCost
            amount = amount + newAmount
        }
        
        let total = (newValue - coinCost)
        
        if priceFormat == "USD" {
            let entryValue = (amount * Double(coinData.priceUSD)!)
            valueLabel.text = "\(entryValue)".formatUSD()
        } else {
            let entryValue = (amount * Double(coinData.priceBTC)!)
            valueLabel.text = "\(entryValue) BTC"
        }
        
        if total > 0 {
            // Profit or gain
            // Gain % = (gain / Cost Price × 100)%
            let gain = (newValue) - (coinCost)
            let gainPercent = "\(gain / newValue * 100)".formatDecimal()

            percentLabel.text = "+ \(gainPercent)%"
            percentLabel.textColor = UIColor(hexString: "63DB37")
        } else if total < 0 {
            // Loss
            // Loss % = (loss/ Cost Price × 100)%
            let loss = (coinCost) - (newValue)
            let lossPercent = "\(loss / coinCost * 100)".formatDecimal()

            percentLabel.text = "- \(lossPercent)%"
            percentLabel.textColor = UIColor(hexString: "FF483E")
        }
    }
    
    func updateTheme() {
        switch themeValue {
        case "dark":
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            self.walletTableView.backgroundColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            nameTextField.backgroundColor = UIColor.white
            valueLabel.textColor = UIColor.white
            for item in textLabels {
                item.textColor = UIColor.white
            }
        default:
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.white
            self.walletTableView.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.black
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            nameTextField.backgroundColor = UIColor.white
            valueLabel.textColor = UIColor.black
            
            for item in textLabels {
                item.textColor = UIColor.black
            }
        }
    }
}
