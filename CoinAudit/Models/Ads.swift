//
//  Ads.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/3/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import Foundation

// AdMob App ID
struct GoogleAd {
    // release ID
    static let appID: String = "ca-app-pub-8616771915576403/4256958375"
}

// MARK: Remove Force String before Release
// Yes = Show ads
// No = Hide ads
var showAd: String = defaults.string(forKey: "CAAds") ?? "Yes"

func saveAdsSettings() {
    defaults.set(showAd, forKey: "CAAds")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadViews"), object: nil)
}
