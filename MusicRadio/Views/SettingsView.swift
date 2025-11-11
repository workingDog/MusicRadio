//
//  SettingsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Selector.self) var selector
    @Environment(ColorModel.self) var colorModel

    
    var body: some View {
        @Bindable var selector = selector
        @Bindable var colorModel = colorModel
        ZStack {
            colorModel.gradient.ignoresSafeArea()

            VStack {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                
                Text("Settings").font(.largeTitle)
                
                HStack {
                    Text("Top-rated stations to show ")
                    CompactStepper(value: $selector.topCount, range: 10...100, step: 10)
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Divider()

                VStack(spacing: 20) {
                    Text("Background color").bold()
                    HStack{
                        Text("Palette ")
                        Toggle("", isOn: $colorModel.grayScale).labelsHidden()
                        Spacer()
                    }
                    ColorSlider()
                        .accentColor(.clear)
                        .frame(width: 333, height: 40)
                        .background(colorModel.colorGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 1).foregroundColor(.black))
                    
                    Slider(value: $colorModel.opacity, in: 0...1)
                        .tint(colorModel.color)
                        .frame(width: 333, height: 40)
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                Spacer()
                
            }
        }
        .onChange(of: colorModel.grayScale) {
            colorModel.updatePalette()
        }
        .onDisappear {
            selector.storeSettings()
            colorModel.storeSettings()
        }
    }
    
}

struct CompactStepper: View {
    @Environment(ColorModel.self) var colorModel
    
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if value > range.lowerBound { value -= step }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
            }.buttonStyle(BorderlessButtonStyle()) // <-- important
            
            Text("Top \(value)")
                .font(.headline)
                .frame(minWidth: 70, alignment: .center)
            
            Button(action: {
                if value < range.upperBound { value += step }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }.buttonStyle(BorderlessButtonStyle()) // <-- important
        }
        .padding(6)
        .background(colorModel.gradient)
        .clipShape(Capsule())
        .contentShape(Rectangle())
    }
}
