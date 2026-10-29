//
//  NewStationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/10/29.
//
import SwiftUI
import SwiftData


struct NewStationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ColorsModel.self) var colorsModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var stationUrl = "https://"
    @State private var artUrl = ""
    @State private var errorMessage: String?
    
    private var isValid: Bool {
        !name.trim().isEmpty &&
        URL(string: stationUrl)?.scheme?.lowercased().hasPrefix("https") == true
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            AppBackground().ignoresSafeArea()
            
            VStack(spacing: 30) {
//                HStack {
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .buttonStyle(.bordered)
//                    Spacer()
//                }
//                .padding(8)
                
                Text("Add a New Station").font(.title)
                
                VStack(spacing: 30) {
                    TextField("Station name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Stream URL", text: $stationUrl)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Artwork URL (optional)", text: $artUrl)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    if let errorMessage {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                    
                    Button("Save", action: doSave)
                        .buttonStyle(.borderedProminent)
                        .disabled(!isValid)
                        .padding(.top, 30)
                }
                .padding(.top, 30)
            }
        }
        
    }
    
    private func doSave() {
        let streamURL = stationUrl.trim()
        let artworkURL = artUrl.trim()
        
        guard let url = URL(string: streamURL),
              let scheme = url.scheme?.lowercased(),
              ["https"].contains(scheme),
              url.host != nil else {
            errorMessage = "Enter a valid stream URL, https."
            return
        }
        
        if !artworkURL.isEmpty {
            guard let artwork = URL(string: artworkURL),
                  let scheme = artwork.scheme?.lowercased(),
                  ["https"].contains(scheme),
                  artwork.host != nil else {
                errorMessage = "Enter a valid artwork URL, https."
                return
            }
        }
        
        let station = RadioStation(name: name, url: stationUrl, favicon: artUrl)
        station.isFavourite = true
        
        modelContext.insert(station)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Unable to save station: \(error.localizedDescription)"
        }
    }
}
