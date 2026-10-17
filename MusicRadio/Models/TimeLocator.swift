//
//  TimeLocator.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/10/17.
//
import Foundation
import CoreLocation
import MapKit
import SwiftUI


struct TimeLocator {
    
    static func stationTimeZone(country: String, state: String) async throws -> TimeZone? {
        let country = country.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !country.isEmpty else { return nil }
        
        let state = state.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !state.isEmpty,
           let zone = try await geocodedTimeZone(for: "\(state), \(country)") {
            return zone
        }
        
        // Fallback: geocode the country by itself.
        return try await geocodedTimeZone(for: country)
    }
    
    static private func geocodedTimeZone(for query: String) async throws -> TimeZone? {
        guard let request = MKGeocodingRequest(addressString: query) else {
            return nil
        }
        
        let mapItems = try await request.mapItems
        return mapItems.first { $0.timeZone != nil }?.timeZone
    }
    
    static func getLocalTimeZone(lat: Double, lon: Double) async -> TimeZone {
        let location = CLLocation(latitude: lat, longitude: lon)
        do {
            guard let request = MKReverseGeocodingRequest(location: location) else {
                throw LocalTimeError.invalidLocation
            }
            let mapItems = try await request.mapItems
            guard let item = mapItems.first else {
                throw LocalTimeError.noResult
            }
            guard let tz = item.timeZone else {
                throw LocalTimeError.timeZoneUnavailable
            }
            
            return tz
            
        } catch {
            print("-----> getLocalTimeZone error: \(error)")
            return TimeZone.gmt
        }
    }
      
}

enum LocalTimeError: Error {
    case invalidLocation
    case noResult
    case timeZoneUnavailable
}
