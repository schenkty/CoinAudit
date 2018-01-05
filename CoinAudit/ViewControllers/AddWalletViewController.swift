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

class AddWalletViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet var nameTextField: SearchTextField!
    @IBOutlet var valueTexField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var textLabels: [UILabel]!
    @IBOutlet var investmentTextField: UITextField!
    @IBOutlet var adView: GADBannerView!
    
    var name: String = ""
    var value: String = ""
    var start: String = ""
    var coinID: NSManagedObjectID!
    var new: Bool = false
    var indexValue: Int = Int()
    var names: [SearchTextFieldItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        holdWalletEntry = true
        
        valueTexField.addDoneButtonToKeyboard(myAction: #selector(self.valueTexField.resignFirstResponder))
        
        // MARK: Ad View
        adView.adUnitID = GoogleAd.appID
        adView.rootViewController = self
        adView.load(GADRequest())
        
        if showAd == "Yes" {
            adView.isHidden = false
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
        }
        
        if name == "Unknown" {
            self.navigationController?.popViewController(animated: true)
        } else if name != "" && value != "" {
            new = false
            // pull coin index using provided name
            saveButton.setTitle("Update", for: .normal)
            self.navigationItem.title = "\(name) Entry"
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
    
    override func viewWillAppear(_ animated: Bool) {
        if showAd == "Yes" {
            adView.isHidden = false
        } else if showAd == "No" {
            adView.isHidden = true
        } else {
            adView.isHidden = false
        }
        
        updateTheme()
    }
    
    @IBAction func addButton(_ sender: Any) {
        name = nameTextField.text!
        value = valueTexField.text!
        start = investmentTextField.text!
        
        if new {
            saveCoin(name: name, value: value, start: start)
            self.navigationController?.popViewController(animated: true)
        } else {
            updateCoin(name: name, value: value, start: start)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateCoin(name: String, value: String, start: String) {
        if names.contains(where: {$0.title == name}) {
            let id = entries.first(where: {$0.name == name})!.id
            
            //update coin in walletCoins array
            let coin = managedObjectContext.object(with: coinID)

            coin.setValue(id, forKey: "id")
            coin.setValue(name, forKey: "name")
            coin.setValue(value, forKey: "value")
            coin.setValue(start, forKey: "startValue")
            
            do{
                try managedObjectContext.save()
                print("\(name) Coin Updated")
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        } else {
            print("Coin: \(name) is not Valid")
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
        }
    }
    
    func saveCoin(name: String, value: String, start: String) {
        if names.contains(where: {$0.title == name}) {
            // pull coin info using provided name
            let id = entries.first(where: {$0.name == name})!.id
            
            // update coin in walletCoins array
            let walletData = NSEntityDescription.insertNewObject(forEntityName: walletEntryValue, into: managedObjectContext)
            
            walletData.setValue(id, forKey: "id")
            walletData.setValue(name, forKey: "name")
            walletData.setValue(value, forKey: "value")
            walletData.setValue(start, forKey: "startValue")
            
            do {
                try managedObjectContext.save()
                print("\(name) Coin Saved")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
            } catch let error as NSError  {
                print("Coin: \(name) could not save")
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
        } else {
            print("Coin: \(name) is not Valid")
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
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
            nameTextField.backgroundColor = UIColor.white
            valueTexField.backgroundColor = UIColor.white
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
            nameTextField.backgroundColor = UIColor.white
            valueTexField.backgroundColor = UIColor.white
            for item in textLabels {
                item.textColor = UIColor.black
            }
        }
    }
}
