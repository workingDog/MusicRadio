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

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: ToolTypes.countries.gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                List(countries) { country in
                    NavigationLink(destination: CountryView(country: country)) {
                        Text(country.name).bold()
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitle("Countries")
        }
    }

}
