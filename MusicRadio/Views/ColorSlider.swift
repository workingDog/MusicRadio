//
//  ColorSlider.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/11.
//
import Foundation
import SwiftUI

/**
 * The color slider view
 */
public struct ColorSlider: View {
    @Environment(ColorModel.self) var colorModel

    public var body: some View {
        Slider(value: Binding<Double>(
            get: { colorModel.value },
            set: { updateModel($0) }),
            in: colorModel.colorRange, step: 1)
        .onAppear {
            updateModel(colorModel.value)
        }
    }
    
    public func updateModel(_ value: Double) {
        colorModel.value = value
        colorModel.updatePalette()
    }
    
}
