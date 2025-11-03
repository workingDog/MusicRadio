//
//  Networker.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI


class Networker {
    
    var defaultURL = "https://de1.api.radio-browser.info/json/"
    
    func getStationsForCountry(_ country: String) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultURL)stations/bycountryexact/\(country)") {
            print("---> fetching theUrl: \(theUrl.absoluteString)")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                // print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let stations = try decoder.decode([RadioStation].self, from: data)
                print("---> stations: \(stations.count)")
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }
    
    func getAllCountries() async throws -> [Country] {
        if let theUrl = URL(string: "\(defaultURL)countries") {
            print("---> fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                // print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let countries = try JSONDecoder().decode([Country].self, from: data)
                print("---> countries: \(countries.count)")
                return countries
            } catch {
                print(error)
            }
        }
        return []
    }

}
