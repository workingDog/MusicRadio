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
    
    private static let defaultfavouriteColor = Color.teal.opacity(0.7)
    //Color(red: 0.161, green: 0.161, blue: 0.137) // Charcoal
    private static let defaultnetColor = Color(red: 0.216, green: 0.435, blue: 0.439) // Teal
    private static let defaultstarColor = Color(red: 0.694, green: 0.541, blue: 0.329) // Brass
    private static let defaultequaliserColor = Color(red: 0.216, green: 0.435, blue: 0.439) // Teal
    private static let defaultbackColor = Color(red: 0.953, green: 0.922, blue: 0.859) // Ivory
    private static let defaultstationBackColor = Color(red: 1.0, green: 0.976, blue: 0.929) // Cream
    private static let defaultcountryBackColor = Color(red: 0.976, green: 0.957, blue: 0.914) // Light cream
    private static let defaulttoolsColor = Color.gray.opacity(0.3)
    //Color(red: 0.157, green: 0.337, blue: 0.341) // Dark teal
    private static let defaultborderColor = Color(red: 0.839, green: 0.776, blue: 0.659) // Brass beige
    
    var favouriteColor = ColorsModel.defaultfavouriteColor
    var netColor = ColorsModel.defaultnetColor
    var starColor = ColorsModel.defaultstarColor
    var equaliserColor = ColorsModel.defaultequaliserColor
    var backColor = ColorsModel.defaultbackColor
    var stationBackColor = ColorsModel.defaultstationBackColor
    var countryBackColor = ColorsModel.defaultcountryBackColor
    var toolsColor = ColorsModel.defaulttoolsColor
    var borderColor = ColorsModel.defaultborderColor
    
    // keys for UserDefaults
    static let keyFavouriteColor: String = "favouriteColor"
    static let keyNetColor: String = "netColor"
    static let keyStarColor: String = "starColor"
    static let keyEqualiserColor: String = "equaliserColor"
    static let keyBackColor: String = "backColor"
    static let keyStationBackColor: String = "stationBackColor"
    static let keyCountryBackColor: String = "countryBackColor"
    static let keyToolsColor: String = "toolsColor"
    static let keyBorderColor: String = "borderColor"

    // store settings in UserDefaults
    public func storeSettings() {
        saveColor(favouriteColor, key: ColorsModel.keyFavouriteColor)
        saveColor(netColor, key: ColorsModel.keyNetColor)
        saveColor(starColor, key: ColorsModel.keyStarColor)
        saveColor(equaliserColor, key: ColorsModel.keyEqualiserColor)
        saveColor(backColor, key: ColorsModel.keyBackColor)
        saveColor(stationBackColor, key: ColorsModel.keyStationBackColor)
        saveColor(countryBackColor, key: ColorsModel.keyCountryBackColor)
        saveColor(toolsColor, key: ColorsModel.keyToolsColor)
        saveColor(borderColor, key: ColorsModel.keyBorderColor)
    }
    
    // retrieve settings from UserDefaults
    public func retrieveSettings() {
        favouriteColor = retrieveColorFor(ColorsModel.keyFavouriteColor)
            ?? ColorsModel.defaultfavouriteColor
        
        netColor = retrieveColorFor(ColorsModel.keyNetColor)
            ?? ColorsModel.defaultnetColor
        
        starColor = retrieveColorFor(ColorsModel.keyStarColor)
            ?? ColorsModel.defaultstarColor
        
        equaliserColor = retrieveColorFor(ColorsModel.keyEqualiserColor)
            ?? ColorsModel.defaultequaliserColor
        
        backColor = retrieveColorFor(ColorsModel.keyBackColor)
            ?? ColorsModel.defaultbackColor
        
        stationBackColor = retrieveColorFor(ColorsModel.keyStationBackColor)
            ?? ColorsModel.defaultstationBackColor
        
        countryBackColor = retrieveColorFor(ColorsModel.keyCountryBackColor)
            ?? ColorsModel.defaultcountryBackColor
        
        toolsColor = retrieveColorFor(ColorsModel.keyToolsColor)
            ?? ColorsModel.defaulttoolsColor
        
        borderColor = retrieveColorFor(ColorsModel.keyBorderColor)
            ?? ColorsModel.defaultborderColor
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
