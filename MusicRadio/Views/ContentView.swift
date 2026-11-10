//
//  ContentView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//

import SwiftUI
import SwiftData
import LRCLIBKit


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ColorsModel.self) var colorsModel
    @Environment(\.networker) private var networker
    
    @AppStorage("lastCountriesUpdate") private var lastUpdate: Date = .distantPast
    
    @State private var playerManager = PlayerManager()
    @State private var selector = Selector()
    
    @State private var showEqualizer = false
    @State private var showNewStation = false
    
    @Query private var stations: [RadioStation]
    @Query private var countries: [Country]
    
    var body: some View {
        ZStack(alignment: .top) {
            AppBackground().ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: selector.view)
            
            VStack {
                
                Text("MusicRadio").font(.system(size: 34, design: .serif)).bold()
                
                ToolsView()
                
                if selector.view != .countries {
                    HStack {
//                        Spacer()
//                        Button {
//                            showEqualizer = true
//                        } label: {
//                            Image(systemName: "slider.horizontal.3")
//                        }
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .shadow(radius: 2)
                        Spacer()
                        FilterToolsView().fixedSize()
                        Spacer()
//                        Button {
//                            showNewStation = true
//                        } label: {
//                            Image(systemName: "radio")
//                        }
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .shadow(radius: 2)
//                        Spacer()
                    }
                    .padding(.top, 8)
                }
                
                switch selector.view {
                    case .favourites: StationListView(stations: stations.filter({$0.isFavourite}))
                    case .countries: CountriesView()
                    case .stations: SearchStationView()
                }
            }
//            .sheet(isPresented: $showEqualizer) {
//                SoundEqualizerControl()
//                    .environment(playerManager)
//            }
//            .sheet(isPresented: $showNewStation) {
//                NewStationView()
//                    .environment(playerManager)
//                    .environment(colorsModel)
//            }
            .onAppear {
                selector.retrieveSettings()
                colorsModel.retrieveSettings()
                
//                for station in stations {
//                    print("---> \(station.name)\n \(station.url)\n  \(station.favicon)")
//                }
            }
        }
        .environment(playerManager)
        .environment(selector)
        .task {
            do {
                if countries.isEmpty {
                    // First launch: fetch and store all countries
                    let allCountries = try await networker.getAllCountries()
                    for country in allCountries where !country.name.trim().isEmpty {
                        modelContext.insert(country)
                    }
                    try modelContext.save()
                    
                    // Add top-voted stations to Favourites
                    let countryCode = Locale.current.region?.identifier ?? ""
                    let topStations = countryCode.isEmpty
                    ? try await networker.getTopVotes(selector.topCount)
                    : try await networker.getTopVotesFor(countryCode, limit: selector.topCount)
                    for station in topStations {
                        station.isFavourite = true
                        modelContext.insert(station)
                    }
                    try modelContext.save()
                    lastUpdate = .now
                } else if Date.now.timeIntervalSince(lastUpdate) >= 30 * 24 * 60 * 60 { // 30 days
                    // Refresh country station counts after 30 days
                    let allCountries = try await networker.getAllCountries()
                    let existingCountries = Dictionary(uniqueKeysWithValues: countries.map { ($0.name, $0) })
                    for country in allCountries where !country.name.trim().isEmpty {
                        if let existing = existingCountries[country.name] {
                            existing.stationcount = country.stationcount
                        } else {
                            modelContext.insert(country)
                        }
                    }
                    try modelContext.save()
                    lastUpdate = .now
                }
            } catch {
                AppLogger.logPublic(error)
            }
            
 //           await test()
            
        }
    }

    func test() async {
        let betterLyricsClient = LyricsTTMLClient()
        do {
            if let artist = try await networker.fetchArtist(for: "E85", countryCode: "us"),
               let name = artist.artistName,
               let track = artist.trackName,
               let album = artist.collectionName,
               let duration = artist.trackTimeMillis {
   
                let testlyricsfile = try await betterLyricsClient.getLyricsFile(
                    trackName: track,
                    artistName: name,
                    albumName: album,
                    duration: UInt(duration / 1000)
                )
 //               print("\n---> test testlyricsfile: \(testlyricsfile)\n")
            }
        } catch {
            print(error)
        }
    }
    
    func test1() async {
  //      let url = URL(string: "https://api.betterlyrics.org/getLyrics")!
        
        let url = URL(string: "https://api.betterlyrics.org/getLyrics?s=E85&a=Don%20Toliver&al=OCTANE&d=154")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("test1/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
  //          print("---> data:\n \(String(data: data, encoding: .utf8) as AnyObject)\n")
           
            let results = try JSONDecoder().decode(BetterLyrics.self, from: data)
            
  //          print("---> results: \(results)\n")
            
            let ttml: LyricsTTML = try TTMLParser().parse(results.ttml)
            
            let lyricsFile = LyricsFile(
                ttml: ttml,
                title: "E85",
                artist: "Don Toliver",
                album: "OCTANE",
                durationMs: 153181
            )
            
 //           print("---> lyricsFile: \(lyricsFile)")
            
//            for part in ttml.songParts {
//                print("---> Section: \(part.name ?? "")")
//                
//                for line in part.lines {
//                    print("---> Line: \(line.text)")
//                    print("---> Start: \(line.start) End: \(line.end)")
//                    
//                    for word in line.words {
//                        print("---> \(word.text) \(word.start) - \(word.end)")
//                    }
//                }
//            }

        } catch {
            print(error)
        }
        
        
    }
    
}
