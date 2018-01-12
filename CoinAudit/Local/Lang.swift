//
//  Lang.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/10/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import Foundation
import Localize_Swift

func setLang() {
    // Update Language
    if let languageCode = Locale.current.languageCode {
        switch languageCode {
        case "de":
            Localize.setCurrentLanguage(languageCode)
        case "ja":
            Localize.setCurrentLanguage(languageCode)
        case "es":
            Localize.setCurrentLanguage(languageCode)
        case "zh-Hans":
            Localize.setCurrentLanguage(languageCode)
        case "it":
            Localize.setCurrentLanguage(languageCode)
        case "ko":
            Localize.setCurrentLanguage(languageCode)
        case "fr":
            Localize.setCurrentLanguage(languageCode)
        case "pt-BR":
            Localize.setCurrentLanguage(languageCode)
        case "en":
            Localize.setCurrentLanguage(languageCode)
        default:
            Localize.setCurrentLanguage("en")
            print("default")
        }
    }
}
