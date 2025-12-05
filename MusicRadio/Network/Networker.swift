//
//  Networker.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import UIKit
import SwiftUI


// for testing
struct StationsTags: Codable {
    var name: String?
    var stationcount: Int?
}

enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    var errorDescription: String? {
        switch self {
            case .unknown: return "Unknown error"
            case .apiError(let reason), .parserError(let reason): return reason
            case .networkError(let from): return from.localizedDescription
        }
    }
}

struct NetworkerKey: EnvironmentKey {
    static let defaultValue = Networker()
}

extension EnvironmentValues {
    var networker: Networker {
        get { self[NetworkerKey.self] }
        set { self[NetworkerKey.self] = newValue }
    }
}

struct Networker {
    
    // radio stations
    var radioServer = "https://de1.api.radio-browser.info/json"
    
    // lyrics
    let lyricsServer = "https://lrclib.net/api"
    
    // artists
    let itunesServer = "https://itunes.apple.com/search?entity=song&limit=1"
    
    let decoder = JSONDecoder()
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
    }
    
    static func defaultTVImg() -> UIImage {
        UIImage(named: "teve")!
    }
    
    static func defaultRadioImg() -> UIImage {
        UIImage(named: "radio")!
    }
    
    func defaultImg(for station: RadioStation) -> UIImage {
        station.isTV ? Networker.defaultTVImg() : Networker.defaultRadioImg()
    }
    
    private func fetchJSON<T: Decodable>(_ endpoint: String) async throws -> [T] {
        guard let theUrl = URL(string: "\(radioServer)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: theUrl)
        request.httpMethod = "GET"
        request.setValue("MusicRadio/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        return try decoder.decode([T].self, from: data)
    }
    
    func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        
        switch http.statusCode {
        case 200..<300: return
        case 401: throw APIError.apiError(reason: "Unauthorized")
        case 402: throw APIError.apiError(reason: "Quota exceeded")
        case 403: throw APIError.apiError(reason: "Resource forbidden")
        case 404: throw APIError.apiError(reason: "Resource not found")
        case 429: throw APIError.apiError(reason: "Requesting too quickly")
        case 405..<500: throw APIError.apiError(reason: "Client error")
        case 500..<600: throw APIError.apiError(reason: "Server error")
        default: throw APIError.networkError(from: URLError(.badServerResponse))
        }
    }
    
    func getStationsForCountryCode(_ code: String) async throws -> [RadioStation] {
        let stations:[RadioStation] = try await fetchJSON("stations/bycountrycodeexact/\(code)")
        convertAllToHttps(stations)
        return stations
    }
    
    func getAllCountries() async throws -> [Country] {
        let allCountries: [Country] = try await fetchJSON("countries")

        // normalize and de-duplicate
        let grouped = Dictionary(
            grouping: allCountries.map { country -> Country in
                let c = country
                c.name = c.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if c.name.hasPrefix("The ") {
                    c.name.removeFirst("The ".count)
                }
                return c
            },
            by: \.name
        )

        return grouped.values
            .compactMap { $0.max(by: { $0.stationcount ?? 0 < $1.stationcount ?? 0 }) }
            .sorted { $0.name < $1.name }
    }
    
    func getTopVotes( _ limit: Int = 10) async throws -> [RadioStation] {
        let stations:[RadioStation] = try await fetchJSON("stations/topvote/\(limit)")
        convertAllToHttps(stations)
        return stations
    }
    
    func getTopVotesFor(_ code: String, limit: Int = 10) async throws -> [RadioStation] {
        let stations:[RadioStation] = try await fetchJSON("stations/search?countrycode=\(code)&order=votes&reverse=true&limit=\(limit)")
        convertAllToHttps(stations)
        return stations
    }
    
    func findStations(_ station: String) async throws -> [RadioStation] {
        let stations:[RadioStation] = try await fetchJSON("stations/byname/\(station)")
        convertAllToHttps(stations)
        return stations
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
        
        let urlString = "\(itunesServer)&term=\(query)&country=\(countryCode.lowercased())"
        guard let theUrl = URL(string: urlString) else { return nil }
        
        print("---> fetchArtist url: \(theUrl.absoluteString)")
        
        do {
            // Fetch data from the local iTunes
            let (data, response) = try await URLSession.shared.data(from: theUrl)
            //        print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
            
            try validate(response)
            
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
                    
          //          print("---> fetchArtist artworkUrl: \(artworkUrl.absoluteString)")
                    
                    // Fetch the artwork image data
                    let (imageData, _) = try await URLSession.shared.data(from: artworkUrl)
                    
                    try validate(response)
                    
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
    // https://lrclib.net/docs
    
    func findLyrics(_ artist: Artist) async throws -> String {
        if let name = artist.artistName, let track = artist.trackName {
            let queryText = "\(lyricsServer)/get?artist_name=\(name)&track_name=\(track)"
            let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let theUrl = URL(string: query) {
                print("---> findLyrics fetching theUrl: \(theUrl.absoluteString)")
                do {
                    let (data, response) = try await URLSession.shared.data(from: theUrl)
                    //     print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    
                    try validate(response)
                    
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
    
    private func fetchFavicon(for station: RadioStation) async {
        if station.favicon == "null" || station.favicon.isEmpty { return }
        guard let faviconURL = URL(string: station.favicon) else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: faviconURL)
            try validate(response)
            station.faviconData = data
        } catch {
            print(error)
        }
    }
    
    func faviconImage(for station: RadioStation) async -> UIImage {
        // If no data cached, fetch it
        if station.faviconData == nil {
            await fetchFavicon(for: station)
            if let data = station.faviconData, let img = UIImage(data: data) {
                return img
            } else {
                let fallback = defaultImg(for: station)
                station.faviconData = fallback.pngData()
                return fallback
            }
        }
        // If data exists, try to decode it
        if let data = station.faviconData, let img = UIImage(data: data) {
            return img
        } else {
            let fallback = defaultImg(for: station)
            station.faviconData = fallback.pngData()
            return fallback
        }
    }
    

    
    
    // for testing
    func getAllTags() async throws -> [StationsTags] {
        if let theUrl = URL(string: "\(radioServer)/tags") {
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
        if let theUrl = URL(string: "\(radioServer)/stations") {
            print("---> getAllStations fetching theUrl: \(theUrl.absoluteString)")
            do {
                let (data, _) = try await URLSession.shared.data(from: theUrl)
                print("---> data: \(data)") // 62 MB
                let stations = try decoder.decode([RadioStation].self, from: data)
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
        if let theUrl = URL(string: "\(radioServer)/servers") {
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

}
