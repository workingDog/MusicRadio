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
    @Environment(Looks.self) var looks
    
    var body: some View {
        @Bindable var selector = selector
        @Bindable var looks = looks
        ZStack {
            looks.gradient.ignoresSafeArea()
            
            VStack {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                
                Spacer()
                
                Text("Settings").font(.largeTitle)
                
                Spacer()
                
                Form {
                    Section("Top Stations") {
                        HStack {
                            Text("Top-rated stations to show ")
                            CompactStepper(value: $selector.topCount, range: 10...100, step: 10)
                        }
                    }
                    
                    Section("Colors") {
                        themePicker()
                        Slider(value: $looks.opa, in: 0...1)
                            .tint(looks.themeColor)
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
                .padding()
                
                Spacer()
                
            }
            
        }
        .onDisappear {
            selector.storeSettings()
            looks.storeSettings()
        }
    }
    
    @ViewBuilder
    func themePicker() -> some View {
        @Bindable var looks = looks
        Picker("", selection: $looks.theme) {
            ForEach(ThemeKeys.allCases) { theme in
                Text(theme.rawValue)
                    .tag(theme)
            }
        }
        .pickerStyle(.segmented)
        .padding(12)
        .background(Capsule().fill(looks.gradient))
        .labelsHidden()
        .clipShape(Capsule())
        .contentShape(Capsule())
    }
}

struct CompactStepper: View {
    @Environment(Looks.self) var looks
    
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
        .background(looks.gradient)
        .clipShape(Capsule())
        .contentShape(Rectangle())
    }
}
