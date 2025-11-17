//
//  Artists.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/15.
//
import Foundation
import UIKit

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
        case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case trackViewURL = "trackViewUrl"
        case previewURL = "previewUrl"
        case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice, releaseDate, collectionExplicitness, trackExplicitness, discCount, discNumber, trackCount, trackNumber, trackTimeMillis, country, currency, primaryGenreName, isStreamable
    }
}

