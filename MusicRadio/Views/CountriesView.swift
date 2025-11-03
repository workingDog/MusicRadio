//
//  CountriesView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct CountriesView: View {
    @Query(sort: [SortDescriptor(\Country.name, order: .forward)])
    private var countries: [Country]
    
    @State private var searchText = ""
    @State private var filteredCountries: [Country] = []

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: ToolTypes.countries.gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                List(filteredCountries) { country in
                    NavigationLink(destination: CountryView(country: country)) {
                        Text(country.name).bold()
                    }
                    .listRowBackground(Color.clear)
                    .searchable(text: $searchText, prompt: "Search countries")
                    .onSubmit(of: .search) {
                        applySearch()
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitle("Countries")
        }
        .onAppear{
            filteredCountries = countries
        }
    }
    
    private func applySearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter {
                $0.name.lowercased().starts(with: searchText.lowercased())
            }
        }
    }
    
}
