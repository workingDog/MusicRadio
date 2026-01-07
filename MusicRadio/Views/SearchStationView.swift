//
//  SearchStationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/08.
//
import SwiftUI


struct SearchStationView: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    @Environment(\.networker) private var networker
    
    @State private var stations: [RadioStation] = []
    @State private var isSearching = false
    
    @FocusState private var focused: Bool
    
    var body: some View {
        @Bindable var selector = selector
        ZStack {
            colorsModel.gradient.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    CapsuleSearchField(text: $selector.searchStation, focused: $focused, onStartUp: doFetch)
                        .onSubmit {
                            Task {
                                await doFetch()
                            }
                        }
                        .onChange(of: selector.searchStation) {
                            if selector.searchStation.isEmpty {
                                stations = []
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

                StationListView(stations: stations)
                    .onTapGesture {
                        focused = false
                    }
                
                Spacer()
            }
        }
    }
    
    func doFetch() async {
        do {
            isSearching = true
            stations = try await fetchStations()
            isSearching = false
        } catch {
            AppLogger.logPublic(error)
        }
    }
    
    func fetchStations() async throws -> [RadioStation] {
        let trimmed = selector.searchStation.trimmingCharacters(in: .whitespacesAndNewlines)
        selector.searchStation = trimmed
        if !trimmed.isEmpty {
            return try await networker.findStations(trimmed)
        }
        return []
    }
    
}

struct CapsuleSearchField: View {
    @Binding var text: String
    @FocusState.Binding var focused: Bool
    
    var onStartUp: () async -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 21))
                .foregroundStyle(.secondary)

            TextField("Search for stations", text: $text)
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
            await onStartUp()
        }
    }
}
