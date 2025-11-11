//
//  Selector.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/06.
//
import Foundation
import SwiftUI


@MainActor
@Observable
class Selector {
    var view: ViewTypes = .favourites
    var filter: FilterTypes = .all
    var tag: StationTag = .all
    var topCount: Int = 10
    var searchStation: String = ""
    
    static let keyTopCount: String = "topCount"
    static let keyFilter: String = "filter"
    static let keyTag: String = "tag"
    

    func storeSettings() {
        UserDefaults.standard.set(self.topCount, forKey: Selector.keyTopCount)
        UserDefaults.standard.set(self.tag.rawValue, forKey: Selector.keyTag)
    }
    
    func retrieveSettings() {
        let xcount = UserDefaults.standard.integer(forKey: Selector.keyTopCount)
        self.topCount = (xcount != 0) ? xcount : 10

        let xtag = UserDefaults.standard.string(forKey: Selector.keyTag) ?? StationTag.all.rawValue
        self.tag = StationTag(rawValue: xtag) ?? .all
    }

}

enum FilterTypes: Identifiable, Hashable {
    case topRated(Int)
    case all

    var id: String {
        switch self {
            case .topRated(let value): return "Top \(value)"
            case .all: return "all"
        }
    }

    var displayName: String {
        switch self {
            case .topRated(let value): return "Top \(value)"
            case .all: return "All"
        }
    }

    static func allCases(topRatedValue: Int) -> [FilterTypes] {
        return [.topRated(topRatedValue),.all]
    }
}

enum ViewTypes: String, CaseIterable, Identifiable {
    case favourites = "Favourites"
    case countries = "Countries"
    case stations = "Stations"
    
    var id: String { rawValue }
    
    // Each type defines its own color scheme and emoji
    var gradient: [Color] {
        let opa = 0.5
        switch self {
        case .favourites: return [.pink.opacity(opa), .purple.opacity(opa)]
        case .stations: return [.blue.opacity(opa), .cyan.opacity(opa)]
        case .countries: return [.mint.opacity(opa), .mint.opacity(opa)]
        }
    }
    
    var icon: String {
        switch self {
            case .favourites: return "🎵"
            case .stations: return "📻"
            case .countries: return "🎙️"
        }
    }
    
    var description: String {
        switch self {
            case .favourites: return "Enjoy your favorite songs."
            case .stations: return "Search for radio stations."
            case .countries: return "Check all countries radio stations."
        }
    }
}

enum StationTag: String, CaseIterable, Codable, Identifiable {
    case all
    case mix
    case jazz
    case pop
    case rock
    case indie
    case electronic
    case ambient
    case classical
    case metal
    case news
    case talk
    case worldMusic = "world music"
    case oldies
    case country
    case blues
    case reggae
    case latin
    case hipHop = "hip-hop"
    case dance
    case chillout
    case techno
    case house
    case tag00s = "00s"
    case tag10s = "10s"
    case tag80s = "80s"
    case tag90s = "90s"
    case christmas
    case children
    case sports

    var id: String { rawValue }

    var displayName: String {
        switch self {
            case .all: return "All types"
            case .hipHop: return "Hip-Hop"
            case .worldMusic: return "World Music"
            case .tag00s: return "2000s"
            case .tag10s: return "2010s"
            case .tag80s: return "1980s"
            case .tag90s: return "1990s"
            default: return rawValue.capitalized
        }
    }

    private static var baseHints: [StationTag: [String]] = [
        .jazz: ["jazz", "bop", "swing", "fusion", "bebop", "cool", "big band", "post-bop", "avant"],
        .pop: ["pop", "chart", "idol", "top 40", "mainstream", "kpop", "jpop"],
        .rock: ["rock", "punk", "grunge", "garage", "alt", "hardcore", "metalcore"],
        .indie: ["indie", "alternative", "shoegaze", "lofi"],
        .electronic: ["edm", "electro", "electronic", "synth", "dubstep", "drum and bass"],
        .ambient: ["ambient", "atmospheric", "drone", "downtempo", "new age"],
        .classical: ["classical", "symphony", "orchestra", "baroque", "opera", "concerto"],
        .metal: ["metal", "heavy metal", "thrash", "black metal", "death metal", "doom"],
        .news: ["news", "headline", "current affairs", "update"],
        .talk: ["talk", "podcast", "interview", "discussion"],
        .worldMusic: ["world", "global", "african", "asian", "celtic", "folk", "balkan"],
        .oldies: ["oldies", "retro", "classic hits", "gold", "vintage", "50s", "60s", "70s"],
        .country: ["country", "bluegrass", "americana", "honky tonk"],
        .blues: ["blues", "rhythm and blues", "r&b"],
        .reggae: ["reggae", "dub", "ska", "dancehall"],
        .latin: ["latin", "salsa", "bossa", "tango", "bachata", "merengue"],
        .hipHop: ["hip-hop", "rap", "trap", "rnb", "urban"],
        .dance: ["dance", "club", "disco", "party"],
        .chillout: ["chill", "lounge", "relax", "café", "smooth"],
        .techno: ["techno", "trance", "hardstyle", "minimal"],
        .house: ["house", "deep house", "progressive", "tech house"],
        .tag80s: ["80s", "eighties"],
        .tag90s: ["90s", "nineties"],
        .tag00s: ["00s", "2000s", "millennium"],
        .tag10s: ["10s", "2010s"],
        .christmas: ["christmas", "holiday", "xmas"],
        .children: ["kids", "children", "nursery", "disney"],
        .sports: ["sports", "football", "soccer", "baseball", "basketball"]
    ]
    
    static func inferDominantGenre(from tags: String) -> StationTag {
        let normalized = tags
            .lowercased()
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        if normalized.isEmpty { return .mix }
        
        var scores: [StationTag: Int] = [:]
        
        for tag in normalized {
            for (genre, hints) in baseHints {
                if hints.contains(where: { tag.contains($0) }) {
                    scores[genre, default: 0] += 1
                }
            }
        }
        
        // get highest score
        let bestGenre = scores
            .sorted {
                if $0.value == $1.value {
                    return $0.key.rawValue < $1.key.rawValue
                }
                return $0.value > $1.value
            }
            .first?.key ?? .mix
        
        return bestGenre
    }
    
}
