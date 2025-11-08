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
    
    
    var body: some View {
        @Bindable var selector = selector
        ZStack {
            Color.mint.opacity(0.2).ignoresSafeArea()
            
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
                    
//                    Section("Other Options") {
//                        Text("Choose Options here")
//                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding()

                Spacer()
                
            }
            
        }
        .onDisappear {
            selector.storeDefaults()
        }
    }
}

struct CompactStepper: View {
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
        .clipShape(Capsule())
        .contentShape(Rectangle())
    }
}
