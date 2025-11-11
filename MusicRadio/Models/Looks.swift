//
//  Looks.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI


@Observable
class Looks {
    var theme: ThemeKeys = .Blueish
    var themeColor: Color = .teal
    var opa = 0.3
    
    static let keyThemeColor: String = "themeColor"
    static let keyOpa: String = "opa"
    
    var gradient: LinearGradient {
        switch theme {
            case .Blueish: themeColor = Color.teal
            case .Greenish: themeColor = Color.mint
            case .Pinkish: themeColor = Color.pink
            case .Yellowish: themeColor = Color.yellow
            case .Orangy: themeColor = Color.orange
            case .Grayish: themeColor = Color(.systemGray)
        }
        return LinearGradient(gradient: Gradient(colors: [themeColor, themeColor.opacity(opa)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    func storeSettings() {
        UserDefaults.standard.set(self.opa, forKey: Looks.keyOpa)
        UserDefaults.standard.set(self.theme.rawValue, forKey: Looks.keyThemeColor)
    }
    
    func retrieveSettings() {
        self.opa = UserDefaults.standard.double(forKey: Looks.keyOpa)
        let xtheme = UserDefaults.standard.string(forKey: Looks.keyThemeColor) ?? ThemeKeys.Blueish.rawValue
        self.theme = ThemeKeys(rawValue: xtheme) ?? .Blueish
    }

}

enum ThemeKeys: String, CaseIterable, Identifiable {
    case Blueish, Greenish, Pinkish, Yellowish, Orangy, Grayish
    
    var id: String { rawValue }
}
