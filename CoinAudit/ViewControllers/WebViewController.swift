//
//  WebViewController.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/8/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit
import WebKit
import SwiftTheme
import Localize_Swift
import SwiftSpinner

class WebViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading", animated: true)
        webView.load(URLRequest(url: URL(string: url)!))
        SwiftSpinner.hide()
        self.navigationItem.title = "Web".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTheme()
    }
    
    func updateTheme() {
        self.tabBarController?.tabBar.theme_barTintColor = ["#000", "#FFF"]
        self.tabBarController?.tabBar.theme_tintColor =  ["#FFF", "#000"]
        self.view.theme_backgroundColor = ["#000", "#FFF"]
        self.navigationItem.leftBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationItem.rightBarButtonItem?.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_barTintColor = ["#000", "#FFF"]
        self.navigationController?.navigationBar.theme_tintColor = ["#FFF", "#000"]
        self.navigationController?.navigationBar.theme_titleTextAttributes = [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
        self.navigationController?.navigationBar.theme_largeTitleTextAttributes =  [[NSAttributedStringKey.foregroundColor.rawValue : UIColor.white], [NSAttributedStringKey.foregroundColor.rawValue : UIColor.black]]
    }
}
