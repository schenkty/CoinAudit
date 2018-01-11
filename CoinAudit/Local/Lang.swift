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
        case "he":
            Localize.setCurrentLanguage(languageCode)
        case "ar":
            Localize.setCurrentLanguage(languageCode)
        case "el":
            Localize.setCurrentLanguage(languageCode)
        case "ja":
            Localize.setCurrentLanguage(languageCode)
        case "uk":
            Localize.setCurrentLanguage(languageCode)
        case "nb":
            Localize.setCurrentLanguage(languageCode)
        case "zh-Hant":
            Localize.setCurrentLanguage(languageCode)
        case "es":
            Localize.setCurrentLanguage(languageCode)
        case "da":
            Localize.setCurrentLanguage(languageCode)
        case "es-419":
            Localize.setCurrentLanguage(languageCode)
        case "zh-Hans":
            Localize.setCurrentLanguage(languageCode)
        case "it":
            Localize.setCurrentLanguage(languageCode)
        case "sk":
            Localize.setCurrentLanguage(languageCode)
        case "ms":
            Localize.setCurrentLanguage(languageCode)
        case "sv":
            Localize.setCurrentLanguage(languageCode)
        case "cs":
            Localize.setCurrentLanguage(languageCode)
        case "ko":
            Localize.setCurrentLanguage(languageCode)
        case "hu":
            Localize.setCurrentLanguage(languageCode)
        case "tr":
            Localize.setCurrentLanguage(languageCode)
        case "pl":
            Localize.setCurrentLanguage(languageCode)
        case "vi":
            Localize.setCurrentLanguage(languageCode)
        case "ru":
            Localize.setCurrentLanguage(languageCode)
        case "pt-PT":
            Localize.setCurrentLanguage(languageCode)
        case "fr":
            Localize.setCurrentLanguage(languageCode)
        case "pt-BR":
            Localize.setCurrentLanguage(languageCode)
        case "fi":
            Localize.setCurrentLanguage(languageCode)
        case "id":
            Localize.setCurrentLanguage(languageCode)
        case "nl":
            Localize.setCurrentLanguage(languageCode)
        case "th":
            Localize.setCurrentLanguage(languageCode)
        case "ro":
            Localize.setCurrentLanguage(languageCode)
        case "hr":
            Localize.setCurrentLanguage(languageCode)
        case "hi":
            Localize.setCurrentLanguage(languageCode)
        case "ca":
            Localize.setCurrentLanguage(languageCode)
        case "en":
            Localize.setCurrentLanguage(languageCode)
        default:
            Localize.setCurrentLanguage("en")
            print("default")
        }
    }
}
