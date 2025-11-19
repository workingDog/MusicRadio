//
//  Artists.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/15.
//
import Foundation
import UIKit

// see https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/UnderstandingSearchResults.html#//apple_ref/doc/uid/TP40017632-CH8-SW1


struct iTunesInfo: Codable {
    let resultCount: Int?
    let results: [Artist]?
}

struct Artist: Identifiable, Codable {
    let id = UUID()
    
    var imageData: UIImage?
    
    var wrapperType, kind: String
    var artistID, collectionID, trackID: Int
    var artistName, collectionName, trackName, collectionCensoredName: String?
    var trackCensoredName: String
    var artistViewURL, collectionViewURL, trackViewURL: String
    var previewURL: String?
    var artworkUrl30, artworkUrl60, artworkUrl100: String?
    var collectionPrice, trackPrice: Double?
    var releaseDate: Date?
    var collectionExplicitness, trackExplicitness: String
    var discCount, discNumber, trackCount, trackNumber: Int?
    var trackTimeMillis: Int?
    var country, currency, primaryGenreName: String?
    var isStreamable: Bool

    enum CodingKeys: String, CodingKey {
        case wrapperType, kind
        case artistID = "artistId"
        case collectionID = "collectionId"
        case trackID = "trackId"
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case trackViewURL = "trackViewUrl"
        case previewURL = "previewUrl"
        case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
        case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice
        case releaseDate, collectionExplicitness, trackExplicitness, discCount, discNumber
        case trackCount, trackNumber, trackTimeMillis, country, currency, primaryGenreName, isStreamable
    }
}

struct Lyrics: Identifiable, Codable {
    let id: Int
    var name, trackName: String?
    var artistName: String?
    var albumName: String?
    var duration: Double?
    var instrumental: Bool?
    var plainLyrics: String?
    var syncedLyrics: String?
}
