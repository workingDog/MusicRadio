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
    var theme: ThemeKeys = .Blue
    var themeColor: Color = .teal
    var opa = 0.3
    
    static let keyThemeColor: String = "themeColor"
    static let keyOpa: String = "opa"
    
    var gradient: LinearGradient {
        switch theme {
            case .Blue: themeColor = Color.teal
            case .Green: themeColor = Color.mint
            case .Pink: themeColor = Color.pink
            case .Yellow: themeColor = Color.yellow
            case .Orange: themeColor = Color.orange
            case .Gray: themeColor = Color(.systemGray)
        }
        return LinearGradient(gradient: Gradient(colors: [themeColor, themeColor.opacity(opa)]), startPoint: .top, endPoint: .bottom)
    }
    
    func storeSettings() {
        UserDefaults.standard.set(self.opa, forKey: Looks.keyOpa)
        UserDefaults.standard.set(self.theme.rawValue, forKey: Looks.keyThemeColor)
    }
    
    func retrieveSettings() {
        self.opa = UserDefaults.standard.double(forKey: Looks.keyOpa)
        let xtheme = UserDefaults.standard.string(forKey: Looks.keyThemeColor) ?? ThemeKeys.Blue.rawValue
        self.theme = ThemeKeys(rawValue: xtheme) ?? .Blue
    }

}

enum ThemeKeys: String, CaseIterable, Identifiable {
    case Blue, Green, Pink, Yellow, Orange, Gray
    
    var id: String { rawValue }
}
