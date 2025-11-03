//
//  ContentView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var audioPlayer = AudioPlayerModel()
    @State private var selectedTool: ToolTypes = .favorite

    let network = Networker()

    @Query private var stations: [RadioStation]
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: selectedTool.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
             .animation(.easeInOut(duration: 0.4), value: selectedTool)
            
            VStack {
                ToolsView(selectedTool: $selectedTool)
                switch selectedTool {
                    case .favorite: BaseStationsView(stations: stations.filter({$0.isFavourite}), columns: 2)
                    
                    case .radio: BaseStationsView(stations: stations, columns: 3)
                    
                    case .podcasts: Text("no implemented")
                } 
            }
        }
        .environment(audioPlayer)

//        .task {
//            do {
//                let stacions = try await network.getStationsForCountry(country: "Australia")
//                for station in stacions.prefix(24) {
//                    print("-----> Australia: \(station.url)")
//                }
//            } catch {
//                print(error)
//            }
//        }
    }
    
}



//    .task {
//        do {
//            let stacions = try await network.getStationsForCountry(country: "Australia")
//  //          self.stations = stacions.prefix(24)
//  //          print("-----> Australia: \(stations.count)")
//            
//            for station in stacions.prefix(24) {
//                modelContext.insert(station)
//                print("-----> Australia: \(station.url)")
//            }
//            
//        } catch {
//            print(error)
//        }
//    }


//        .task {
//            do {
//                stations = try await network.getStationsForCountry(country: "Fiji")
//                countries = try await network.getAllCountries()
//            } catch {
//                print(error)
//            }
//        }

//                Button{
//                    for station in stations {
//                        modelContext.insert(station)
//                    }
//                    for country in countries {
//                        modelContext.insert(country)
//                    }
//                } label: {
//                    Image(systemName: "square.and.arrow.up.circle")
//                }.font(.system(size: 60))










/*
struct ContentView2: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
*/
