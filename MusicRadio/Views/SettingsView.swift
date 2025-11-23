//
//  SettingsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct SettingsView: View {
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    
    @Binding var showSettings: Bool
    
    var body: some View {
        @Bindable var selector = selector
        @Bindable var colorsModel = colorsModel
        
        ZStack {
            colorsModel.gradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Button("Done") {
                    showSettings = false
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                
                Text("Settings").font(.largeTitle)

                HStack {
                    Text("Top-rated stations to show   ")
                    CompactStepper(value: $selector.topCount, range: 10...100, step: 10)
                    Spacer()
                }
                .padding(.top, 20)

                HStack {
                    Text("Countries back color ")
                    Image(systemName: "backpack.fill")
                        .font(.title)
                        .foregroundStyle(colorsModel.countryBackColor)
                    ColorPicker("", selection: $colorsModel.countryBackColor)
                        .labelsHidden()
                    Spacer()
                }
                
                HStack {
                    Text("Stations back color ")
                    Image(systemName: "backpack.fill")
                        .font(.title)
                        .foregroundStyle(colorsModel.stationBackColor)
                    ColorPicker("", selection: $colorsModel.stationBackColor)
                        .labelsHidden()
                    Spacer()
                }
                
                HStack {
                    Text("Background color ")
                    Image(systemName: "backpack.fill")
                        .font(.title)
                        .foregroundStyle(colorsModel.backColor)
                    ColorPicker("", selection: $colorsModel.backColor)
                        .labelsHidden()
                    Spacer()
                }
                
                HStack {
                    Text("Equaliser Color    ")
                    Image(systemName: "chart.bar.fill")
                        .font(.title)
                        .foregroundStyle(colorsModel.equaliserColor)
                    ColorPicker("", selection: $colorsModel.equaliserColor)
                        .labelsHidden()
                    Spacer()
                }

                HStack {
                    Text("Favourite Color ")
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundStyle(colorsModel.favouriteColor)
                    ColorPicker("", selection: $colorsModel.favouriteColor)
                        .labelsHidden()
                    Spacer()
                }
                HStack {
                    Text("Network Color ")
                    Image(systemName: "network")
                        .font(.title)
                        .foregroundStyle(colorsModel.netColor)
                    ColorPicker("", selection: $colorsModel.netColor)
                        .labelsHidden()
                    Spacer()
                }
                HStack {
                    Text("Star Color    ")
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(colorsModel.starColor)
                    ColorPicker("", selection: $colorsModel.starColor)
                        .labelsHidden()
                    Spacer()
                }
                
                HStack {
                    Text("Station select sound  ")
                    Image(systemName: "hand.tap.fill")
                        .font(.title)
                        .foregroundStyle(selector.pingSound ? Color.accentColor : .black)
                    Toggle("", isOn: $selector.pingSound)
                    Spacer()
                }.fixedSize()
                
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
            }.buttonStyle(.borderless) // <-- important
            
            Text("Top \(value)")
                .font(.headline)
                .frame(minWidth: 70, alignment: .center)
            
            Button(action: {
                if value < range.upperBound { value += step }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }.buttonStyle(.borderless) // <-- important
        }
        .padding(6)
        .background(colorsModel.backColor)
        .clipShape(Capsule())
        .contentShape(Rectangle())
    }
}
