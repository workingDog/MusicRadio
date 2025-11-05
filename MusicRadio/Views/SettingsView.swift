//
//  SettingsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            Spacer()
            Text("settings").font(.largeTitle)
        }
    }
}
