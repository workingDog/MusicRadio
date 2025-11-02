//
//  ContentView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    //   @Environment(\.modelContext) private var modelContext
    //   @Query private var items: [Item]
    
    let network = Networker()
    @State private var stations: [RadioStation] = []
    @State private var countries: [Country] = []
    
    @State private var selectedTool: ToolTypes = .favorite
    
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

                if stations.isEmpty {
                    ProgressView()
                } else {
                    List(stations) { station in
                        Text("station at \(station.name)").foregroundStyle(Color.red)
                    }
                }
                Divider()
                if countries.isEmpty {
                    ProgressView()
                } else {
                    List(countries) { country in
                        Text("country at \(country.name)").foregroundStyle(Color.blue)
                    }
                }
            }
        }
        .task {
//            do {
//                stations = try await network.getStationsForCountry(country: "Fiji")
//                countries = try await network.getAllCountries()
//            } catch {
//                print(error)
//            }
        }
    }
}


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
