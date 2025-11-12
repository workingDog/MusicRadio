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
    @Environment(ColorsModel.self) var colorsModel
    
    var body: some View {
        @Bindable var selector = selector
        @Bindable var colorsModel = colorsModel
        
        ZStack {
            colorsModel.gradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
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
                
                HStack {
                    Text("Background color ")
                    Image(systemName: "app.background.dotted")
                        .foregroundStyle(colorsModel.backColor)
                    ColorPicker("", selection: $colorsModel.backColor, supportsOpacity: true)
                        .labelsHidden()
                        .fixedSize()
                        .frame(width: 66, height: 30)
                    Spacer()
                }
                HStack {
                    Text("Favourite Color ")
                    Image(systemName: "heart.fill")
                        .foregroundStyle(colorsModel.favouriteColor)
                    ColorPicker("", selection: $colorsModel.favouriteColor, supportsOpacity: false)
                        .labelsHidden()
                        .fixedSize()
                        .frame(width: 66, height: 30)
                    Spacer()
                }
                HStack {
                    Text("Globe Color   ")
                    Image(systemName: "network")
                        .foregroundStyle(colorsModel.netColor)
                    ColorPicker("", selection: $colorsModel.netColor, supportsOpacity: false)
                        .labelsHidden()
                        .fixedSize()
                        .frame(width: 66, height: 30)
                    Spacer()
                }
                HStack {
                    Text("Star Color    ")
                    Image(systemName: "star.fill")
                        .foregroundStyle(colorsModel.starColor)
                    ColorPicker("", selection: $colorsModel.starColor, supportsOpacity: false)
                        .labelsHidden()
                        .fixedSize()
                        .frame(width: 66, height: 30)
                    Spacer()
                }
                
                Spacer()
            }
            .padding(12)
        }
        .onDisappear {
            selector.storeSettings()
            colorsModel.storeSettings()
        }
    }
    
}

struct CompactStepper: View {
    @Environment(ColorsModel.self) var colorsModel
    
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
        .background(colorsModel.gradient)
        .clipShape(Capsule())
        .contentShape(Rectangle())
    }
}
