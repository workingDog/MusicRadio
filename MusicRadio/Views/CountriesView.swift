//
//  CountriesView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct CountriesView: View {
    @Environment(ColorModel.self) var colorModel
    
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
                colorModel.gradient.ignoresSafeArea()
                List(filteredCountries) { country in
                    NavigationLink(destination: CountryView(country: country)) {
                        CountryRow(country: country)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
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

struct CountryRow: View {
    @Environment(ColorModel.self) var colorModel
    
    let country: Country
    
    var body: some View {
        HStack(spacing: 16) {
            Image(country.iso_3166_1.lowercased())
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 35)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                    .foregroundColor(.black)
                Text("\(country.stationcount ?? 0) stations")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        .background(colorModel.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 3)
    }
}
