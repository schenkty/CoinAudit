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
    
    var names: [SearchTextFieldItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "New Entry"
        
        valueTexField.addDoneButtonToKeyboard(myAction: #selector(self.valueTexField.resignFirstResponder))
        
        for item in entries {
            let name = SearchTextFieldItem(title: item.name)
            names.append(name)
        }
        
        nameTextField.filterItems(names)
        nameTextField.inlineMode = true
        nameTextField.startSuggestingInmediately = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButton(_ sender: Any) {
        if names.contains(where: {$0.title == nameTextField.text}) {
            print("Coin: \(nameTextField.text!) is Valid")
        } else {
            print("Coin: \(nameTextField.text!) is not Valid")
            showAlert(title: "Invalid Name", message: "Enter Valid Coin Name", style: .alert)
        }
    }
    /*
 // save coin id to array
 favorites.append(id)
 favorites = favorites.sorted()
 defaults.set(favorites, forKey: "favorites")
 print("Added: \(id) from favorites")
 */

}
