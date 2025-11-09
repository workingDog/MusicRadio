//
//  Networker.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI
import SwiftData


/*
 for API endpoints see:
 
 https://docs.radio-browser.info/?utm_source=chatgpt.com#list-of-radio-stations
 
 */

class Networker {
    
    var defaultServer = "https://de1.api.radio-browser.info/json/"
    
    
    // for testing
    func getAllStations() async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)stations") {
            print("---> getAllStations fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                print("---> data: \(data)") // 62 MB
                let stations = try JSONDecoder().decode([RadioStation].self, from: data)
                print("---> stations: \(stations.count)") // 51680
                print("\n---> done fetching getAllStations \n")
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }

    func getStationsForCountry(_ country: String) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)stations/bycountryexact/\(country)") {
            print("---> getStationsForCountry fetching theUrl: \(theUrl.absoluteString)")
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
        if let theUrl = URL(string: "\(defaultServer)countries") {
            print("---> getAllCountries fetching theUrl: \(theUrl.absoluteString)")
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

    // for testing
    func getServers() async throws {
        if let theUrl = URL(string: "\(defaultServer)servers") {
            print("---> getServers fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                 print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
       //         let countries = try JSONDecoder().decode([Country].self, from: data)
      //          print("---> countries: \(countries.count)")
      //          return countries
            } catch {
                print(error)
            }
        }
        return
    }

    func getTopVotes( _ limit: Int = 10) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)stations/topvote/\(limit)") {
            print("---> getTopVotes fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
// print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let stations = try decoder.decode([RadioStation].self, from: data)
       //         print("---> stations: \(stations)")
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }

    func getTopVotesFor(_ country: String, limit: Int = 10) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)stations/search?country=\(country)&order=votes&reverse=true&limit=\(limit)") {
            print("---> getTopVotesFor fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
// print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let stations = try decoder.decode([RadioStation].self, from: data)
       //         print("---> stations: \(stations)")
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }
    
//    func saveAllStations(_ stations: [RadioStation], context: ModelContext) {
//        let batchSize = 500
//
//        for chunk in stride(from: 0, to: stations.count, by: batchSize) {
//            let batch = Array(stations[chunk..<min(chunk + batchSize, stations.count)])
//            for station in batch {
//                context.insert(station)
//            }
//            try? context.save()
//        }
//    }
    
    func findStations(_ station: String) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)stations/byname/\(station)") {
            print("---> findStations fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
    //            print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let stations = try decoder.decode([RadioStation].self, from: data)
                //         print("---> stations: \(stations)")
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }
    
}
