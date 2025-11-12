//
//  ColorModel.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/11.
//
import Foundation
import SwiftUI

/**
 * the ColorSlider data model
 */
@MainActor
@Observable
public class ColorModel {
    
    // the slider value (0->nColors)
    public var value: Double = 0.0
    // the number of colors to display
    public var nColors: Int = 1
    // saturation setting
    public var saturation: Double = 1.0
    // brightness setting
    public var brightness: Double = 1.0
    // opacity setting
    public var opacity: Double = 0.5
    
    // the current color
    public var color = Color.white

    // grayscale or color palette
    public var grayScale = false
    
    // the thickness of the bar of each color in the slider.
    public var bandSize = 1
    
    // keys for UserDefaults
    static let keyValue: String = "Value"
    static let keyOpacity: String = "opacity"
    static let keyGrayScale: String = "grayScale"

    // default 100 colors, not gray scale
    public init(nColors: Int = 100, grayScale: Bool = false) {
        self.grayScale = grayScale
        self.nColors = nColors
        if grayScale {
            self.saturation = 0.0
        }
    }

    // the color array for the ColorSlider colorGradient
    public var colors: [Color] {
        guard nColors > 0 else { return [] }
        let delta: Double = 1/Double(nColors).rounded(.up)
        let hues: [Double] = Array(stride(from: delta, to: 1.0, by: delta))
        var colorSet = [Color]()
        for hue in hues {
            for _ in 0..<bandSize {
                colorSet.append(Color(hue: grayScale ? 0 : hue, saturation: saturation, brightness: grayScale ? hue : brightness))
            }
        }
        return whiteBlock + colorSet.reversed() + blackBlock
    }
    
    public var whiteBlock: [Color] {
         Array(repeating: Color.white, count: bandSize)
    }
    
    public var blackBlock: [Color] {
         Array(repeating: Color.black, count: bandSize)
    }
    
    // the internal color gradient for the background of the ColorSlider
    public var colorGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
    }

    // the slider color range of values
    public var colorRange: ClosedRange<Double> {
        let n = colors.count - 1
        return 0...(n > 0 ? Double(n) : 1.0)
    }
    
    // convenience color gradient that can be used in other Views
    public var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [color, color.opacity(opacity)]), startPoint: .top, endPoint: .bottom)
    }
    
    // store settings in UserDefaults
    public func storeSettings() {
        UserDefaults.standard.set(self.opacity, forKey: ColorModel.keyOpacity)
        UserDefaults.standard.set(self.value, forKey: ColorModel.keyValue)
        UserDefaults.standard.set(self.grayScale, forKey: ColorModel.keyGrayScale)
    }
    
    // retrieve settings from UserDefaults
    public func retrieveSettings() {
        self.opacity = UserDefaults.standard.double(forKey: ColorModel.keyOpacity)
        self.value = UserDefaults.standard.double(forKey: ColorModel.keyValue)
        self.grayScale = UserDefaults.standard.bool(forKey: ColorModel.keyGrayScale)
    }
    
    // update the model palette to grayscale or color
    public func updatePalette() {
        self.saturation = grayScale ? 0.0 : 1.0
        self.color = self.colors.isEmpty ? Color.clear : self.colors[Int(self.value)]
    }
    
}

