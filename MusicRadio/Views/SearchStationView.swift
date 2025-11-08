//
//  SearchStationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/08.
//
import SwiftUI
import SwiftData



struct SearchStationView: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(Selector.self) var selector
    
    let network = Networker()
    
    @State private var stations: [RadioStation] = []
    @State private var isSearching = false
    
    var body: some View {
        @Bindable var selector = selector
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: ViewTypes.stations.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    CapsuleSearchField(text: $selector.searchStation)
                        .onSubmit {
                            Task {
                                isSearching = true
                                stations = try await fetchStations()
                                isSearching = false
                            }
                        }
                    Spacer()
                }
                .padding(15)

                if isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                StationListView(stations: stations, columns: 2)
                
                Spacer()
            }
        }
    }
    
    func fetchStations() async throws -> [RadioStation] {
        let trimmed = selector.searchStation.trimmingCharacters(in: .whitespacesAndNewlines)
        selector.searchStation = trimmed
        if !trimmed.isEmpty {
            return try await network.findStations(trimmed)
        }
        return []
    }
    
}

struct CapsuleSearchField: View {
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 21))
                .foregroundStyle(.secondary)

            TextField("Search stations", text: $text)
                .focused($focused)
                .font(.system(size: 22))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .background(.clear)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background( Capsule().fill(.thinMaterial) )
        .task {
            focused = true
        }
    }
}
