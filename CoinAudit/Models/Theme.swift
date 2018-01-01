//
//  Theme.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/1/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import Foundation
import UIKit

// themeValue
// light
// dark

func textColor() -> UIColor {
    switch themeValue {
    case "dark":
        return .white
    default:
        return .black
    }
}

func itemsColor() -> UIColor {
    switch themeValue {
    case "dark":
        return .white
    default:
        return .blue
    }
}

func viewsColor() -> UIColor {
    switch themeValue {
    case "dark":
        return .white
    default:
        return .black
    }
}
