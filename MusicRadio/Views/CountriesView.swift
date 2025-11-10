//
//  CountriesView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct CountriesView: View {

    @Query(sort: \Country.name) private var countries: [Country]
    
    @State private var searchText = ""
    
    private var filteredCountries: [Country] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return countries }
        return countries.filter { country in
            let cleanName = country.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanName.lowercased().starts(with: searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: ViewTypes.countries.gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                List(filteredCountries) { country in
                    NavigationLink(destination: CountryView(country: country)) {
                        HStack {
                            Image(country.iso_3166_1.lowercased())
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 40, height: 30)
                            Text("\(country.stationcount ?? 0)")
                            Spacer()
                            Text(country.name).bold()
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search countries")
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Countries")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}
