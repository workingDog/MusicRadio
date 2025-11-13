//
//  DataModels.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftData
import SwiftUI


// https://de1.api.radio-browser.info/#General


@Model
final class Country: Codable {
    var name: String
    var iso_3166_1: String
    var stationcount: Int? = nil
    
    enum CodingKeys: String, CodingKey {
        case name, iso_3166_1, stationcount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        iso_3166_1 = try container.decode(String.self, forKey: .iso_3166_1)
        stationcount = try container.decodeIfPresent(Int.self, forKey: .stationcount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(iso_3166_1, forKey: .iso_3166_1)
        try container.encodeIfPresent(stationcount, forKey: .stationcount)
    }
}

@Model
final class RadioStation: Codable {

    // these are not encoded or decoded
    static var defaultImg = UIImage(named: "radio")!
    var isFavourite: Bool = false
    var isPlaying: Bool = false
    var faviconData: Data? = nil
    
    var changeuuid: String
    var stationuuid: String
    var name: String
    var url: String
    var urlResolved: String
    var homepage: String
    var favicon: String
    var tags: String
    var country: String
    var countrycode: String
    var iso3166_2: String?
    var state: String
    var language: String
    var languagecodes: String
    var votes: Int
    var clickcount: Int?
    var clicktrend: Int?
    var geoLat: Double?
    var geoLong: Double?
    var geoDistance: Double?
    
//    var lastchangetime: String
//    var lastchangetimeIso8601: Date?
//    var codec: String
//    var bitrate: Int
//    var hls: Int
//    var lastcheckok: Int
//    var lastchecktime: String
//    var lastchecktimeIso8601: Date?
//    var lastcheckoktime: String?
//    var lastcheckoktimeIso8601: Date?
//    var lastlocalchecktime: String?
//    var lastlocalchecktimeIso8601: Date?
//    var clicktimestamp: String?
//    var clicktimestampIso8601: Date?
//    var sslError: Int?
//    var hasExtendedInfo: Bool?
    
    enum CodingKeys: String, CodingKey {
        case changeuuid, stationuuid, name, url
        case state, language, languagecodes, votes, lastchangetime
        case clickcount, clicktrend, countrycode
        case homepage, favicon, tags, country
        case urlResolved = "url_resolved"
        case iso3166_2 = "iso_3166_2"
        case geoLat = "geo_lat"
        case geoLong = "geo_long"
        case geoDistance = "geo_distance"

//        case lastchangetimeIso8601 = "lastchangetime_iso8601"
//        case codec, bitrate, hls, lastcheckok, lastchecktime
//        case lastchecktimeIso8601 = "lastchecktime_iso8601"
//        case lastcheckoktime
//        case lastcheckoktimeIso8601 = "lastcheckoktime_iso8601"
//        case lastlocalchecktime
//        case lastlocalchecktimeIso8601 = "lastlocalchecktime_iso8601"
//        case clicktimestamp
//        case clicktimestampIso8601 = "clicktimestamp_iso8601"
//        case sslError = "ssl_error"
//        case hasExtendedInfo = "has_extended_info"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        changeuuid = try container.decode(String.self, forKey: .changeuuid)
        stationuuid = try container.decode(String.self, forKey: .stationuuid)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        urlResolved = try container.decode(String.self, forKey: .urlResolved)
        homepage = try container.decode(String.self, forKey: .homepage)
        favicon = try container.decode(String.self, forKey: .favicon)
        tags = try container.decode(String.self, forKey: .tags)
        country = try container.decode(String.self, forKey: .country)
        countrycode = try container.decode(String.self, forKey: .countrycode)
        iso3166_2 = try container.decodeIfPresent(String.self, forKey: .iso3166_2)
        state = try container.decode(String.self, forKey: .state)
        language = try container.decode(String.self, forKey: .language)
        languagecodes = try container.decode(String.self, forKey: .languagecodes)
        votes = try container.decode(Int.self, forKey: .votes)
        clickcount = try container.decodeIfPresent(Int.self, forKey: .clickcount)
        clicktrend = try container.decodeIfPresent(Int.self, forKey: .clicktrend)
        geoLat = try container.decodeIfPresent(Double.self, forKey: .geoLat)
        geoLong = try container.decodeIfPresent(Double.self, forKey: .geoLong)
        geoDistance = try container.decodeIfPresent(Double.self, forKey: .geoDistance)
        
//        sslError = try container.decodeIfPresent(Int.self, forKey: .sslError)
//        lastchangetime = try container.decode(String.self, forKey: .lastchangetime)
//        lastchangetimeIso8601 = try container.decode(Date.self, forKey: .lastchangetimeIso8601)
//        codec = try container.decode(String.self, forKey: .codec)
//        bitrate = try container.decode(Int.self, forKey: .bitrate)
//        hls = try container.decode(Int.self, forKey: .hls)
//        lastcheckok = try container.decode(Int.self, forKey: .lastcheckok)
//        lastchecktime = try container.decode(String.self, forKey: .lastchecktime)
//        lastchecktimeIso8601 = try container.decodeIfPresent(Date.self, forKey: .lastchecktimeIso8601)
//        lastcheckoktime = try container.decodeIfPresent(String.self, forKey: .lastcheckoktime)
//        lastcheckoktimeIso8601 = try container.decodeIfPresent(Date.self, forKey: .lastcheckoktimeIso8601)
//        lastlocalchecktime = try container.decodeIfPresent(String.self, forKey: .lastlocalchecktime)
//        lastlocalchecktimeIso8601 = try container.decodeIfPresent(Date.self, forKey: .lastlocalchecktimeIso8601)
//        clicktimestamp = try container.decodeIfPresent(String.self, forKey: .clicktimestamp)
//        clicktimestampIso8601 = try container.decodeIfPresent(Date.self, forKey: .clicktimestampIso8601)
//        hasExtendedInfo = try container.decodeIfPresent(Bool.self, forKey: .hasExtendedInfo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(changeuuid, forKey: .changeuuid)
        try container.encode(stationuuid, forKey: .stationuuid)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(urlResolved, forKey: .urlResolved)
        try container.encode(homepage, forKey: .homepage)
        try container.encode(favicon, forKey: .favicon)
        try container.encode(tags, forKey: .tags)
        try container.encode(country, forKey: .country)
        try container.encode(countrycode, forKey: .countrycode)
        try container.encodeIfPresent(iso3166_2, forKey: .iso3166_2)
        try container.encode(state, forKey: .state)
        try container.encode(language, forKey: .language)
        try container.encode(languagecodes, forKey: .languagecodes)
        try container.encode(votes, forKey: .votes)
        try container.encodeIfPresent(clickcount, forKey: .clickcount)
        try container.encodeIfPresent(clicktrend, forKey: .clicktrend)
        try container.encodeIfPresent(geoLat, forKey: .geoLat)
        try container.encodeIfPresent(geoLong, forKey: .geoLong)
        try container.encodeIfPresent(geoDistance, forKey: .geoDistance)
        
//        try container.encodeIfPresent(sslError, forKey: .sslError))
//        try container.encode(lastchangetime, forKey: .lastchangetime)
//        try container.encode(lastchangetimeIso8601, forKey: .lastchangetimeIso8601)
//        try container.encode(codec, forKey: .codec)
//        try container.encode(bitrate, forKey: .bitrate)
//        try container.encode(hls, forKey: .hls)
//        try container.encode(lastcheckok, forKey: .lastcheckok)
//        try container.encode(lastchecktime, forKey: .lastchecktime)
//        try container.encode(lastchecktimeIso8601, forKey: .lastchecktimeIso8601)
//        try container.encode(lastcheckoktime, forKey: .lastcheckoktime)
//        try container.encode(lastcheckoktimeIso8601, forKey: .lastcheckoktimeIso8601)
//        try container.encode(lastlocalchecktime, forKey: .lastlocalchecktime)
//        try container.encode(lastlocalchecktimeIso8601, forKey: .lastlocalchecktimeIso8601)
//        try container.encodeIfPresent(clicktimestamp, forKey: .clicktimestamp)
//        try container.encodeIfPresent(clicktimestampIso8601, forKey: .clicktimestampIso8601)
//        try container.encodeIfPresent(hasExtendedInfo, forKey: .hasExtendedInfo)
    }
    
    func faviconImage() -> UIImage {
        if faviconData == nil {
            Task { await fetchFavicon() }
            if faviconData != nil, let img = UIImage(data: faviconData!) {
                return img
            } else {
                return RadioStation.defaultImg
            }
        } else {
            if let img = UIImage(data: faviconData!) {
                return img
            } else {
                return RadioStation.defaultImg
            }
        }
    }
    
    func fetchFavicon() async {
        if favicon == "null" || favicon.isEmpty { return }
        guard let faviconURL = URL(string: favicon) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: faviconURL)
            self.faviconData = data
        } catch {
            print(error)
        }
    }
    
}
