//
//  SettingsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI
import SwiftData


struct SettingsView: View {
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    
    @Binding var showSettings: Bool
    
    var body: some View {
        @Bindable var selector = selector
        @Bindable var colorsModel = colorsModel
        
        NavigationStack {
            ZStack {
                AppBackground().ignoresSafeArea()
                
                VStack(spacing: 10) {
                    
                    Text("Color Settings").font(.largeTitle).padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 20) {

                            HStack {
                                Text("Countries back ")
                                Image(systemName: "backpack.fill")
                                    .font(.title)
                                    .foregroundStyle(colorsModel.countryBackColor)
                                    .overlay {
                                        ColorPicker("", selection: $colorsModel.countryBackColor)
                                            .labelsHidden()
                                            .colorMultiply(.clear)
                                    }
                                Spacer()
                            }
                            
                            HStack {
                                Text("Stations back ")
                                Image(systemName: "backpack.fill")
                                    .font(.title)
                                    .foregroundStyle(colorsModel.stationBackColor)
                                    .overlay {
                                        ColorPicker("", selection: $colorsModel.stationBackColor)
                                            .labelsHidden()
                                            .colorMultiply(.clear)
                                    }
                                Spacer()
                            }
                            
                            HStack {
                                Text("Equaliser ")
                                Image(systemName: "chart.bar.fill")
                                    .font(.title)
                                    .foregroundStyle(colorsModel.equaliserColor)
                                    .overlay {
                                        ColorPicker("", selection: $colorsModel.equaliserColor)
                                            .labelsHidden()
                                            .colorMultiply(.clear)
                                    }
                                Spacer()
                            }
                            
                            HStack {
                                Text("Favourite ")
                                Image(systemName: "heart.fill")
                                    .font(.title)
                                    .foregroundStyle(colorsModel.favouriteColor)
                                    .overlay {
                                        ColorPicker("", selection: $colorsModel.favouriteColor)
                                            .labelsHidden()
                                            .colorMultiply(.clear)
                                    }
                                Spacer()
                            }
                            
                            HStack {
                                Text("Home ")
                                Image(systemName: "house.fill")
                                    .font(.title)
                                    .foregroundStyle(colorsModel.netColor)
                                    .overlay {
                                        ColorPicker("", selection: $colorsModel.netColor)
                                            .labelsHidden()
                                            .colorMultiply(.clear)
                                    }
                                Spacer()
                            }
                            
                            HStack {
                                Text("Tools back ")
                                Image(systemName: "pad.header")
                                    .font(.title)
                                    .foregroundStyle(colorsModel.toolsColor)
                                    .overlay {
                                        ColorPicker("", selection: $colorsModel.toolsColor)
                                            .labelsHidden()
                                            .colorMultiply(.clear)
                                    }
                                Spacer()
                            }
                            
                        }.padding(10)
                    }
                    
                    Spacer()
                }
                .padding(10)
                
            }
            .onDisappear {
                selector.storeSettings()
                colorsModel.storeSettings()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        showSettings = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SoundEqualizerControl()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NewStationView()
                    } label: {
                        Image(systemName: "radio")
                    }
                }
            }
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
        .background(AppBackground())
        .clipShape(Capsule())
        .contentShape(Rectangle())
    }
}
