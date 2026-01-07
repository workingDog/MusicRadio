//
//  ColorsModel.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/12.
//
import Foundation
import SwiftUI


@MainActor
@Observable
class ColorsModel {
    
    var favouriteColor = Color.teal
    var netColor = Color.blue
    var starColor = Color.orange
    var equaliserColor = Color.accentColor
    var backColor = Color.mint.opacity(0.4)
    var stationBackColor = Color.white.opacity(0.4)
    var countryBackColor = Color.teal.opacity(0.4)
    
    // keys for UserDefaults
    static let keyFavouriteColor: String = "favouriteColor"
    static let keyNetColor: String = "netColor"
    static let keyStarColor: String = "starColor"
    static let keyEqualiserColor: String = "equaliserColor"
    static let keyBackColor: String = "backColor"
    static let keyStationBackColor: String = "stationBackColor"
    static let keyCountryBackColor: String = "countryBackColor"
    
    // convenience color gradient
    public var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [backColor.opacity(1), backColor.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
    }
    
    // store settings in UserDefaults
    public func storeSettings() {
        saveColor(favouriteColor, key: ColorsModel.keyFavouriteColor)
        saveColor(netColor, key: ColorsModel.keyNetColor)
        saveColor(starColor, key: ColorsModel.keyStarColor)
        saveColor(equaliserColor, key: ColorsModel.keyEqualiserColor)
        saveColor(backColor, key: ColorsModel.keyBackColor)
        saveColor(stationBackColor, key: ColorsModel.keyStationBackColor)
        saveColor(countryBackColor, key: ColorsModel.keyCountryBackColor)
    }
    
    // retrieve settings from UserDefaults
    public func retrieveSettings() {
        
        let fav = retrieveColorFor(ColorsModel.keyFavouriteColor)
        let net = retrieveColorFor(ColorsModel.keyNetColor)
        let star = retrieveColorFor(ColorsModel.keyStarColor)
        let equ = retrieveColorFor(ColorsModel.keyEqualiserColor)
        let back = retrieveColorFor(ColorsModel.keyBackColor)
        let sback = retrieveColorFor(ColorsModel.keyStationBackColor)
        let cback = retrieveColorFor(ColorsModel.keyCountryBackColor)
        
        self.favouriteColor = (fav != nil) ? fav! : Color.teal
        self.netColor = (net != nil) ? net! : Color.blue
        self.starColor = (star != nil) ? star! : Color.orange
        self.equaliserColor = (equ != nil) ? equ! : Color.accentColor
        self.backColor = (back != nil) ? back! : Color.mint.opacity(0.4)
        self.stationBackColor = (sback != nil) ? sback! : Color.white.opacity(0.4)
        self.countryBackColor = (cback != nil) ? cback! : Color.teal.opacity(0.4)
    }
    
    func saveColor(_ color: Color, key: String) {
        guard let rgba = color.rgba() else { return }
        
        UserDefaults.standard.set(
            [rgba.r, rgba.g, rgba.b, rgba.a],
            forKey: key
        )
    }
    
    func retrieveColorFor(_ key: String) -> Color? {
        guard let values = UserDefaults.standard.array(forKey: key) as? [Double],
              values.count == 4 else { return nil }
        
        return Color(.sRGB,
                     red: values[0],
                     green: values[1],
                     blue: values[2],
                     opacity: values[3]
        )
    }
    
}

extension Color {
    
    func rgba() -> (r: Double, g: Double, b: Double, a: Double)? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        
        return (Double(r), Double(g), Double(b), Double(a))
    }
}
