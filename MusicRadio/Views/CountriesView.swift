//
//  CountriesView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct CountriesView: View {
    @Environment(ColorsModel.self) var colorsModel
    @Environment(Selector.self) var selector
    
    @Query(sort: \Country.name) private var countries: [Country]

    private var filteredCountries: [Country] {
        let trimmed = selector.searchCountry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return countries }
        return countries.filter { country in
            let cleanName = country.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanName.lowercased().starts(with: trimmed.lowercased())
        }
    }
    
    var body: some View {
        @Bindable var selector = selector
        NavigationStack {
            ZStack {
                colorsModel.gradient.ignoresSafeArea()
                List(filteredCountries) { country in
                    NavigationLink(destination: CountryView(country: country)) {
                        CountryRow(country: country)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                }
                .searchable(text: $selector.searchCountry, placement: .navigationBarDrawer, prompt: "Search countries")
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Countries")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

struct CountryRow: View {
    @Environment(ColorsModel.self) var colorsModel
    
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
                Capsule()
                    .fill(colorsModel.countryBackColor)
                    .overlay {
                        Text("\(country.stationcount ?? 0)")
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .frame(width: 70, height: 25)
            }
            Spacer()
        }
        .padding()
        .background(colorsModel.countryBackColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 3)
    }
}
