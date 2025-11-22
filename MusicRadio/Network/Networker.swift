//
//  Networker.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import UIKit


// for testing 
struct StationsTags: Codable {
    var name: String?
    var stationcount: Int?
}

class Networker {
    
    var defaultServer = "https://de1.api.radio-browser.info/json"
    
    let decoder = JSONDecoder()

    init() {
        decoder.dateDecodingStrategy = .iso8601
    }
    
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
                for tag in sortedTags.prefix(200) {
                    print(" \(tag.name ?? "no name")  \(tag.stationcount ?? 0)")
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
    
    func getStationsForCountry(_ country: String) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations/bycountryexact/\(country)") {
            print("---> getStationsForCountry fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, response) = try await URLSession.shared.data(from: theUrl)
                // print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                
                // Check HTTP status
                if let httpResponse = response as? HTTPURLResponse {
                    if (400...599).contains(httpResponse.statusCode) {
                        print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                        return []
                    }
                }
                
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
                let (data, response) = try await URLSession.shared.data(from: theUrl)
                // print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                
                // Check HTTP status
                if let httpResponse = response as? HTTPURLResponse {
                    if (400...599).contains(httpResponse.statusCode) {
                        print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                        return []
                    }
                }
                
                let countries = try JSONDecoder().decode([Country].self, from: data)
                // print("---> countries: \(countries.count)")
                return countries
            } catch {
                print(error)
            }
        }
        return []
    }

    func getTopVotes( _ limit: Int = 10) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations/topvote/\(limit)") {
            print("---> getTopVotes fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, response) = try await URLSession.shared.data(from: theUrl)
// print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                
                // Check HTTP status
                if let httpResponse = response as? HTTPURLResponse {
                    if (400...599).contains(httpResponse.statusCode) {
                        print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                        return []
                    }
                }

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
                let (data, response) = try await URLSession.shared.data(from: theUrl)
// print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                
                // Check HTTP status
                if let httpResponse = response as? HTTPURLResponse {
                    if (400...599).contains(httpResponse.statusCode) {
                        print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                        return []
                    }
                }

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
    
    func findStations(_ station: String) async throws -> [RadioStation] {
        if let theUrl = URL(string: "\(defaultServer)/stations/byname/\(station)") {
            print("---> findStations fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, response) = try await URLSession.shared.data(from: theUrl)
    //            print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                
                // Check HTTP status
                if let httpResponse = response as? HTTPURLResponse {
                    if (400...599).contains(httpResponse.statusCode) {
                        print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                        return []
                    }
                }

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

    // Fetch the artist artwork from iTunes from the local station country,
    // will also try the US if need be
    func fetchArtist(for queryText: String, countryCode: String, tries: Int = 0) async throws -> Artist? {
        // URL encode the search query
        let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(query)&entity=song&limit=1&country=\(countryCode.lowercased())"
        guard let theUrl = URL(string: urlString) else { return nil }
        
        print("---> fetchArtist url: \(theUrl.absoluteString)")
        
        do {
            // Fetch data from the local iTunes
            let (data, response) = try await URLSession.shared.data(from: theUrl)
    //        print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                if (400...599).contains(httpResponse.statusCode) {
                    print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                    return nil
                }
            }

            let arts = try decoder.decode(iTunesInfo.self, from: data)

            if var artist = arts.results?.first {
                
                // make sure all are https
                artist.artistViewURL = artist.artistViewURL.replacingOccurrences(of: "http://", with: "https://")
                artist.collectionViewURL = artist.collectionViewURL.replacingOccurrences(of: "http://", with: "https://")
                artist.trackViewURL = artist.trackViewURL.replacingOccurrences(of: "http://", with: "https://")
                artist.previewURL = artist.previewURL?.replacingOccurrences(of: "http://", with: "https://")
                artist.artworkUrl100 = artist.artworkUrl100?.replacingOccurrences(of: "http://", with: "https://")
                artist.artworkUrl30 = artist.artworkUrl30?.replacingOccurrences(of: "http://", with: "https://")
                artist.artworkUrl60 = artist.artworkUrl60?.replacingOccurrences(of: "http://", with: "https://")
                
                if let artwork = artist.artworkUrl100 {
                    // Replace "100x100" with "600x600" for high-resolution image
                    let artworkUrlString: String = artwork.replacingOccurrences(of: "100x100", with: "600x600")
                    
                    guard let artworkUrl = URL(string: artworkUrlString) else { return nil }
                    
                    print("---> fetchArtist artworkUrl: \(artworkUrl.absoluteString)")
                    
                    // Fetch the artwork image data
                    let (imageData, _) = try await URLSession.shared.data(from: artworkUrl)
                    
                    // Check HTTP status
                    if let httpResponse = response as? HTTPURLResponse {
                        if (400...599).contains(httpResponse.statusCode) {
                            print("\n---> HTTP error: \(httpResponse.statusCode) artworkUrl: \(artworkUrl.absoluteString)")
                            return nil
                        }
                    }
                    
                    // add the imageData to the artist
                    artist.imageData = UIImage(data: imageData)
                    return artist
                }
            } else {
                // try to fetch the info from the US, when no local results
                if tries < 1 {
                    Task {
                        return try await fetchArtist(
                            for: queryText,
                            countryCode: "us",
                            tries: tries + 1)
                    }
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    // see: https://lrclib.net/
    // https://openpublicapis.com/api/lrclib?utm_source=chatgpt.com
    
    func findLyrics(_ artist: Artist) async throws -> String {
        let lrclib = "https://lrclib.net/api"
        
        if let name = artist.artistName, let track = artist.trackName {
            let queryText = "\(lrclib)/get?artist_name=\(name)&track_name=\(track)"
            let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let theUrl = URL(string: query) {
                print("---> findLyrics fetching theUrl: \(theUrl.absoluteString)")
                do {
                    let (data, response) = try await URLSession.shared.data(from: theUrl)
                    //     print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    
                    // Check HTTP status
                    if let httpResponse = response as? HTTPURLResponse {
                        if (400...599).contains(httpResponse.statusCode) {
                            print("\n---> HTTP error: \(httpResponse.statusCode) theUrl: \(theUrl.absoluteString)")
                            return "no lyrics"
                        }
                    }

                    let lyrics = try JSONDecoder().decode(Lyrics.self, from: data)
                    if let txt = lyrics.plainLyrics {
                        return txt
                    }
                } catch {
                    print(error)
                }
            }
        }
        return "no lyrics"
    }

}
