//
//  StartViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/3/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit
import Alamofire

class StartViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainView.backgroundColor = UIColor(hexString: "C0C0C0")
        self.retryButton()
    }
    
    @IBAction func retryButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feed")
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            self.present(controller, animated: true, completion: nil)
        } else {
            print("No! internet is not available")
            showAlert(title: "No connection")
        }
    }
}
