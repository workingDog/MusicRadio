//
//  LyricsTTMLClient.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/11/09.
//
import Foundation
import LRCLIBKit
import Yams

/// A Better Lyrics API client.
///
/// see the documentations at:   https://docs.betterlyrics.org/
///
public struct LyricsTTMLClient {
    private let baseURL: URL
    private let lrclibID: String?
    private let userAgent: String
    private let session: URLSession
    
    private let maxAttempts = 3
    private let defaultRetryDelay: TimeInterval = 1
    
    public init(
        baseURL: URL = URL(string: "https://api.betterlyrics.org/")!,
        lrclibID: String? = nil,
        userAgent: String = "testing",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.lrclibID = lrclibID
        self.userAgent = userAgent
        self.session = session
    }
    
    public func getLyricsFile(
        trackName: String,
        artistName: String,
        albumName: String? = nil,
        duration: UInt? = nil
    ) async throws -> LyricsFile {
        
        let endpoint = "getLyrics"
        var queryItems = [
            URLQueryItem(name: "s", value: trackName),
            URLQueryItem(name: "a", value: artistName)
        ]
        if let albumName {
            queryItems.append(URLQueryItem(name: "al", value: albumName))
        }
        if let duration {
            queryItems.append(URLQueryItem(name: "d", value: String(duration)))
        }
        
        let betterLyrics: BetterLyrics = try await request(endpoint, queryItems: queryItems)

        let ttml: LyricsTTML = try TTMLParser().parse(betterLyrics.ttml)
        
        return LyricsFile(
            ttml: ttml,
            title: trackName,
            artist: artistName,
            album: albumName ?? "",
            durationMs: Int((duration ?? 0) * 1000)
        )
    }
    
    /// Server request
    private func request<T: Decodable>(_ endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        
        let url = baseURL
            .appending(path: endpoint)
            .appending(queryItems: queryItems)
        
        print("-----> LyricsTTMLClient request url: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
 //       request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

//        if let theKey {
//            request.setValue(theKey, forHTTPHeaderField: "X-API-Key")
//        }
        
        for attempt in 1...maxAttempts {
            let data: Data
            let response: URLResponse
            
            do {
                (data, response) = try await session.data(for: request)
                
  //              print("-----> LyricsTTMLClient request data: \(String(data: data, encoding: .utf8))")
                
            } catch {
                guard attempt < maxAttempts, shouldRetry(error) else {
                    throw error
                }
                try await Task.sleep(for: .seconds(defaultRetryDelay * pow(2, Double(attempt - 1))))
                continue
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerTTMLError.invalidResponse
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                let retryable = [429, 503].contains(httpResponse.statusCode)
                guard retryable, attempt < maxAttempts else {
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    if let error = try? JSONDecoder().decode(LyricsTTMLError.self, from: data) {
                        throw ServerTTMLError.apiError(error, retryAfter: retryAfter)
                    }
                    throw ServerTTMLError.httpErrorCode(httpResponse.statusCode)
                }
                let delay = retryDelay(from: httpResponse, attempt: attempt)
                try await Task.sleep(for: .seconds(delay))
                continue
            }
            return try JSONDecoder().decode(T.self, from: data)
        }
        throw ServerTTMLError.invalidResponse
    }
    
    private func retryDelay(from response: HTTPURLResponse?, attempt: Int) -> TimeInterval {
        if let value = response?.value(forHTTPHeaderField: "Retry-After") {
            if let seconds = TimeInterval(value), seconds >= 0 {
                return seconds
            }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            if let date = formatter.date(from: value) {
                return max(0, date.timeIntervalSinceNow)
            }
        }
        return defaultRetryDelay * pow(2, Double(attempt - 1))
    }
    
    private func shouldRetry(_ error: Error) -> Bool {
        guard !Task.isCancelled, let error = error as? URLError else { return false }
        return [
            .timedOut,
            .networkConnectionLost,
            .notConnectedToInternet,
            .cannotConnectToHost,
            .cannotFindHost,
            .dnsLookupFailed
        ].contains(error.code)
    }

}

/// server errors
public enum ServerTTMLError: Error, Equatable {
    case httpErrorCode(_ responseCode: Int)
    case searchBothNil
    case invalidResponse
    case apiError(LyricsTTMLError, retryAfter: String?)
}

/// the error returned
public struct LyricsTTMLError: Codable, Sendable, Equatable {
    public let statusCode: Int
    public let name: String
    public let message: String
    
    public init(statusCode: Int, name: String, message: String) {
        self.statusCode = statusCode
        self.name = name
        self.message = message
    }
}

