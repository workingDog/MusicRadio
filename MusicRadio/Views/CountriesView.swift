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
                        HStack {
                            Image(country.iso_3166_1.lowercased())
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 40, height: 30)
                            Spacer()
                            Text(country.name).bold()
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .searchable(text: $searchText, prompt: "Search countries")
                .onSubmit(of: .search) {
                    doSearch()
                }
                .onChange(of: searchText) {
                    if searchText.isEmpty {
                        filteredCountries = countries
                    }
                }
            }
            .navigationBarTitle("Countries")
        }
        .onAppear {
            filteredCountries = countries
            print("---> countries: \(countries.count)\n")
        }
    }
    
    private func doSearch() {
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



/*
 
 I have this SwiftUI code, but the background of the List
 is white and I want it to show the LinearGradient under it, how to achieve this?
 
 "var body: some View {
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
                     doSearch()
                 }
             }
             .scrollContentBackground(.hidden)
         }
         .navigationBarTitle("Countries")
     }
 }"
 
 */
