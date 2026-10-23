//
//  Networker.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import UIKit
import SwiftUI
import LRCLIBKit


extension String {
    func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


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

enum ServerHostError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, reason: String)
}

struct Networker {
    
    // radio stations
    let radioServer = URL(string: "https://de1.api.radio-browser.info/json")!
    
    // lyrics client
    let lyricsClient: LrcClient
    let lrclibID = "uffDOEor4luWEl3ltIARG5BFdaw29uImqIKBTIHVBYY"
    
    // artists
    let itunesServer = URL(string: "https://itunes.apple.com/search")!
    
    let decoder = JSONDecoder()
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        configuration.waitsForConnectivity = false
        
        let session = URLSession(configuration: configuration)
        
        lyricsClient = LrcClient(lrclibID: lrclibID, session: session)
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

    private func fetchJSON<T: Decodable>(_ components: URLComponents) async throws -> T {
        guard let url = components.url else {
            throw ServerHostError.invalidURL
        }
        let data = try await fetch(url)
        return try decoder.decode(T.self, from: data)
    }
    
    private func fetch(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("MusicRadio/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        
        return data
    }
    
    private func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw ServerHostError.invalidResponse
        }
        guard (200..<300).contains(response.statusCode) else {
            let reason = switch response.statusCode {
                case 401: "Unauthorized"
                case 402: "Quota exceeded"
                case 403: "Resource forbidden"
                case 404: "Resource not found"
                case 429: "Requesting too quickly"
                case 400..<500: "Client error"
                case 500..<600: "Server error"
                default: "Unexpected HTTP status"
            }
            throw ServerHostError.httpError(statusCode: response.statusCode, reason: reason)
        }
    }
    
    func getStationsForCountryCode(_ code: String) async throws -> [RadioStation] {
        let components = URLComponents(
            url: radioServer.appending(path: "stations/bycountrycodeexact/\(code)"),
            resolvingAgainstBaseURL: false
        )!
        
        let stations: [RadioStation] = try await fetchJSON(components)
        
        convertAllToHttps(stations)
        return stations
    }
    
    func getAllCountries() async throws -> [Country] {
        let components = URLComponents(
            url: radioServer.appending(path: "countries"),
            resolvingAgainstBaseURL: false
        )!
        
        let allCountries: [Country] = try await fetchJSON(components)
        
        // normalize and de-duplicate
        let grouped = Dictionary(
            grouping: allCountries.map { country -> Country in
                let c = country
                c.name = c.name.trim()
                if c.name.hasPrefix("The ") {
                    c.name.removeFirst("The ".count)
                }
                return c
            },
            by: \.name
        )
        
        return grouped.values
            .compactMap { countries in
                countries.max { ($0.stationcount ?? 0) < ($1.stationcount ?? 0) }
            }
            .sorted { $0.name < $1.name }
    }
    
    func getTopVotes( _ limit: Int = 10) async throws -> [RadioStation] {
        var components = URLComponents(
            url: radioServer.appending(path: "stations/topvote"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        let stations: [RadioStation] = try await fetchJSON(components)
        
        convertAllToHttps(stations)
        return stations
    }
    
    func getTopVotesFor(_ code: String, limit: Int = 10) async throws -> [RadioStation] {
        var components = URLComponents(
            url: radioServer.appending(path: "stations/search"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "countrycode", value: code),
            URLQueryItem(name: "order", value: "votes"),
            URLQueryItem(name: "reverse", value: "true"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        let stations: [RadioStation] = try await fetchJSON(components)
        
        convertAllToHttps(stations)
        return stations
    }
    
    func findStations(_ station: String) async throws -> [RadioStation] {
        var components = URLComponents(
            url: radioServer.appending(path: "stations/search"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "name", value: station)
        ]
        
        let stations: [RadioStation] = try await fetchJSON(components)
        
        convertAllToHttps(stations)
        return stations
    }
    
    private func httpsURL(_ string: String) -> String {
        guard string.hasPrefix("http://") else { return string }
        return "https://" + string.dropFirst("http://".count)
    }
    
    // some url are http must make them all https
    private func convertAllToHttps(_ stations: [RadioStation]) {
        for station in stations {
            station.url = httpsURL(station.url)
            station.homepage = httpsURL(station.homepage)
            station.favicon = httpsURL(station.favicon)
            station.urlResolved = httpsURL(station.urlResolved)
        }
    }
    
    // Fetch the artist artwork from iTunes from the US,
    // will also try the local station country if need be
    func fetchArtist(for queryText: String, countryCode: String) async throws -> Artist? {
        if let artist = try await searchArtist(queryText, countryCode: "us") {
            return try await fetchArtwork(for: artist)
        }
        guard countryCode.lowercased() != "us" else { return nil }
        guard let artist = try await searchArtist(queryText, countryCode: countryCode) else { return nil }
        return try await fetchArtwork(for: artist)
    }
    
    private func searchArtist(_ queryText: String, countryCode: String) async throws -> Artist? {
        guard !queryText.isEmpty else { return nil }

        var components = URLComponents(url: itunesServer, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "term", value: queryText),
            URLQueryItem(name: "country", value: countryCode.lowercased())
        ]
        guard let url = components.url else {
            throw ServerHostError.invalidURL
        }

        let data = try await fetch(url)
        
        let response = try decoder.decode(iTunesInfo.self, from: data)
        
        guard var artist = response.results?.first else { return nil }
        artist.artistViewURL = httpsURL(artist.artistViewURL)
        artist.collectionViewURL = httpsURL(artist.collectionViewURL)
        artist.trackViewURL = httpsURL(artist.trackViewURL)
        artist.previewURL = artist.previewURL.map(httpsURL)
        artist.artworkUrl100 = artist.artworkUrl100.map(httpsURL)
        artist.artworkUrl30 = artist.artworkUrl30.map(httpsURL)
        artist.artworkUrl60 = artist.artworkUrl60.map(httpsURL)
        
        return artist
    }
    
    private func fetchArtwork(for artist: Artist) async throws -> Artist? {
        guard let artwork = artist.artworkUrl100 else { return artist }
        let artworkURLString = artwork.replacingOccurrences(of: "100x100", with: "600x600")
        guard let artworkURL = URL(string: artworkURLString) else {
            throw ServerHostError.invalidURL
        }
        var artist = artist
        
        let (data, response) = try await URLSession.shared.data(from: artworkURL)
        
        try validate(response)
        artist.imageData = UIImage(data: data)
        
        return artist
    }
    
    // see: https://lrclib.net/
    // https://lrclib.net/docs
    func findLyrics(_ artist: Artist) async throws -> String {
        guard let name = artist.artistName, let track = artist.trackName else {
            return "no lyrics"
        }
        do {
            let lyrics = try await lyricsClient.getLyrics(trackName: track, artistName: name)
            return lyrics.plainLyrics ?? "no lyrics"
        } catch let LRCLIBKit.ServerError.apiError(error, retryAfter: _) where error.statusCode == 404 {
            return "no lyrics"
        } catch LRCLIBKit.ServerError.httpErrorCode(404) {
            return "no lyrics"
        }
    }

    private func fetchFavicon(for station: RadioStation) async {
        if station.favicon == "null" || station.favicon.isEmpty { return }
        guard let faviconURL = URL(string: station.favicon) else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: faviconURL)
            try validate(response)
            station.faviconData = data
        } catch {
            AppLogger.logPublic(error)
        }
    }
    
    func faviconImage(for station: RadioStation) async -> UIImage {
        if let data = station.faviconData, let image = UIImage(data: data) {
            return image
        }
        await fetchFavicon(for: station)
        if let data = station.faviconData, let image = UIImage(data: data) {
            return image
        }
        let fallback = defaultImg(for: station)
        station.faviconData = fallback.pngData()
        return fallback
    }
    
    
    //-------------------------------------------------------------------
    //-------------------------testing-----------------------------------
    //-------------------------------------------------------------------
    
    // for testing
    func getAllTags() async throws -> [StationsTags] {
        let theUrl = radioServer.appending(path: "/tags")
        print("---> getAllTags fetching theUrl: \(theUrl.absoluteString)")
        var request = URLRequest(url: theUrl)
        request.httpMethod = "GET"
        //           request.setValue("MusicRadio/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let tags = try JSONDecoder().decode([StationsTags].self, from: data)
            print("---> tags: \(tags.count)\n")
            
            let sortedTags = tags.sorted(by: { ($0.stationcount ?? 0) > ($1.stationcount ?? 0) })
            for tag in sortedTags.prefix(200) {
                print(" \(tag.name ?? "no name")  \(tag.stationcount ?? 0)")
            }
            return tags
        } catch {
            AppLogger.logPublic(error)
        }
        return []
    }
    
    // for testing
    func getAllStations() async throws -> [RadioStation] {
        let theUrl = radioServer.appending(path: "/stations")
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
            AppLogger.logPublic(error)
        }
        return []
    }
    
    // for testing
    func getServers() async throws {
        let theUrl = radioServer.appending(path: "/servers")
        print("---> getServers fetching theUrl: \(theUrl.absoluteString)")
        do {
            let (data, _) = try await URLSession.shared.data(from: theUrl)
            print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
        } catch {
            AppLogger.logPublic(error)
        }
        return
    }
    
}
