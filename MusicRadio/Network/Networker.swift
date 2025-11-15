//
//  Networker.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI
import SwiftData


// for testing 
struct StationsTags: Codable {
    var name: String?
    var stationcount: Int?
}

class Networker {
    
    var defaultServer = "https://de1.api.radio-browser.info/json"
    
    // for testing
    func getAllTags() async throws -> [StationsTags] {
        if let theUrl = URL(string: "\(defaultServer)/tags") {
            print("---> getAllTags fetching theUrl: \(theUrl.absoluteString)")
            var request = URLRequest(url: theUrl)
            request.httpMethod = "GET"
            request.setValue("MusicRadio/1.0", forHTTPHeaderField: "User-Agent")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let tags = try JSONDecoder().decode([StationsTags].self, from: data)
                print("---> tags: \(tags.count)\n")
                
                let sortedTags = tags.sorted(by: { ($0.stationcount ?? 0) > ($1.stationcount ?? 0) })
                for tag in sortedTags.prefix(50) {
                    print("---> tag: \(tag.name ?? "no name")  \(tag.stationcount ?? 0)")
                }
                
                print("\n---> done fetching getAllTags \n")
                return tags
            } catch {
                print(error)
            }
        }
        return []
    }
    
    
    // for testing
    func getAllStations() async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations") {
            print("---> getAllStations fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                print("---> data: \(data)") // 62 MB
                let stations = try JSONDecoder().decode([RadioStation].self, from: data)
                print("---> stations: \(stations.count)") // 51680
                print("\n---> done fetching getAllStations \n")
                convertAllToHttps(stations)
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }

    func getStationsForCountry(_ country: String) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations/bycountryexact/\(country)") {
            print("---> getStationsForCountry fetching theUrl: \(theUrl.absoluteString)")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                // print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let stations = try decoder.decode([RadioStation].self, from: data)
                print("---> stations: \(stations.count)")
                convertAllToHttps(stations)
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }
    
    func getAllCountries() async throws -> [Country] {
        if let theUrl = URL(string: "\(defaultServer)/countries") {
            print("---> getAllCountries fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                // print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let countries = try JSONDecoder().decode([Country].self, from: data)
                // print("---> countries: \(countries.count)")
                return countries
            } catch {
                print(error)
            }
        }
        return []
    }

    // for testing
    func getServers() async throws {
        if let theUrl = URL(string: "\(defaultServer)/servers") {
            print("---> getServers fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                 print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
            } catch {
                print(error)
            }
        }
        return
    }

    func getTopVotes( _ limit: Int = 10) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations/topvote/\(limit)") {
            print("---> getTopVotes fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
// print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let stations = try decoder.decode([RadioStation].self, from: data)
       //         print("---> stations: \(stations)")
                convertAllToHttps(stations)
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }

    func getTopVotesFor(_ country: String, limit: Int = 10) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations/search?country=\(country)&order=votes&reverse=true&limit=\(limit)") {
            print("---> getTopVotesFor fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
// print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let stations = try decoder.decode([RadioStation].self, from: data)
       //         print("---> stations: \(stations)")
                convertAllToHttps(stations)
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
        if let theUrl = URL(string: "\(defaultServer)/stations/byname/\(station)") {
            print("---> findStations fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
    //            print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let stations = try decoder.decode([RadioStation].self, from: data)
                //         print("---> stations: \(stations)")
                convertAllToHttps(stations)
                return stations
            } catch {
                print(error)
            }
        }
        return []
    }
    
    // some url are http must make them all https
    func convertAllToHttps(_ stations: [RadioStation]) {
        for station in stations {
            if station.url.starts(with: "http://") {
                station.url = station.url.replacingOccurrences(of: "http://", with: "https://")
            }
            if station.homepage.starts(with: "http://") {
                station.homepage = station.homepage.replacingOccurrences(of: "http://", with: "https://")
            }
            if station.favicon.starts(with: "http://") {
                station.favicon = station.favicon.replacingOccurrences(of: "http://", with: "https://")
            }
            if station.urlResolved.starts(with: "http://") {
                station.urlResolved = station.urlResolved.replacingOccurrences(of: "http://", with: "https://")
            }
        }
    }

    // Fetch the artist with the high-resolution album artwork for a given song or artist from iTunes
    func fetchArtist(for queryText: String) async throws -> Artist? {
        // URL encode the search query
        let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=song&limit=1"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            // Fetch data from iTunes
            let (data, _) = try await URLSession.shared.data(from: url)
    //        print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let arts = try decoder.decode(iTunesInfo.self, from: data)
    //        print("---> arts: \(arts)\n")
            
            if var artist = arts.results?.first {
                if let artwork = artist.artworkUrl100 {
                    // Replace "100x100" with "600x600" for high-resolution image
                    let artworkUrlString: String = artwork.replacingOccurrences(of: "100x100", with: "600x600") ?? ""
                    
                    guard let artworkUrl = URL(string: artworkUrlString) else { return nil }
                    
                    // Fetch the artwork image data
                    let (imageData, _) = try await URLSession.shared.data(from: artworkUrl)
                    // add the imageData to the artist
                    artist.imageData = UIImage(data: imageData)
                    return artist
                }
            }
        } catch {
            print(error)
        }
        return nil
    }

}
