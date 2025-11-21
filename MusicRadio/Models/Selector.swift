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
    var pingSound: Bool = true
    
    static let keyTopCount: String = "topCount"
    static let keyTag: String = "tag"
    static let keyPingSound: String = "pingSound"
    
    
    func storeSettings() {
        UserDefaults.standard.set(self.topCount, forKey: Selector.keyTopCount)
        UserDefaults.standard.set(self.tag.rawValue, forKey: Selector.keyTag)
        UserDefaults.standard.set(self.pingSound, forKey: Selector.keyPingSound)
    }
    
    func retrieveSettings() {
        let xcount = UserDefaults.standard.integer(forKey: Selector.keyTopCount)
        self.topCount = (xcount != 0) ? xcount : 10
        
        let xtag = UserDefaults.standard.string(forKey: Selector.keyTag) ?? StationTag.all.rawValue
        self.tag = StationTag(rawValue: xtag) ?? .all
        
        self.pingSound = UserDefaults.standard.bool(forKey: Selector.keyPingSound)
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
    case all = "All types"
    case mix
    case jazz
    case pop
    case rock
    case indie
    case classical
    case hits
    case variety
    case metal
    case news
    case talk
    case worldMusic = "world music"
    case oldies
    case country
    case blues
    case soul
    case relax
    case reggae
    case latin
    case hipHop = "hip-hop"
    case dance
    case techno
    case children
    case sports
    case tv
    case community
    case adultHits = "Adult hits"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    private static var baseHints: [StationTag: [String]] = [
        
            .pop: [
                "pop", "pop music", "top 40", "top40", "top hits",
                "pop en español", "pop en inglés", "latin pop",
                "mainstream", "charts", "top charts", "chart", "idol", "top 40", "mainstream", "kpop", "jpop"
            ],
        
            .news: [
                "news", "local news", "news talk", "noticias",
                "noticias locales", "noticias en español",
                "information", "talk & speech", "headline", "current affairs", "update"
            ],
        
            .rock: [
                "rock", "classic rock", "hard rock",
                "alternative rock", "rock clásico"
            ],
        
            .classical: [
                "classical", "classic", "instrumental"
            ],
        
            .variety: [
                "entretenimiento", "entertainment", "variety",
                "diversión"
            ],
        
            .hits: [
                "hits", "classic hits", "top hits", "top 100",
                "80s", "90s", "70s", "60s", "retro"
            ],
        
            .dance: [
                "dance", "club", "eurodance", "disco",
                "edm", "house", "deep house", "party"
            ],
        
            .latin: ["latin", "salsa", "bossa", "tango", "bachata", "merengue"],
        
            .hipHop: ["hip-hop", "rap", "trap", "rnb", "urban"],

            .relax: [
                "easy listening", "chill", "chillout", "lounge", "relax"
            ],
        
            .talk: [
                "talk", "talk radio",  "podcast", "interview", "discussion"
            ],
        
            .worldMusic: ["world", "global", "african", "asian", "celtic", "folk", "balkan"],
        
            .oldies: ["oldies", "retro", "classic hits", "gold", "vintage", "50s", "60s", "70s"],
        
            .jazz: ["jazz", "bop", "swing", "fusion", "bebop", "cool", "big band", "post-bop", "avant"],
        
            .children: ["kids", "children", "nursery", "disney"],

            .community: [
                "public radio", "community radio", "college radio",
                "university radio", "community"
            ],
        
            .techno: ["electronic", "electronica", "electro", "techno", "trance", "hardstyle", "minimal"],
        
            .adultHits: [
                "adult contemporary", "hot adult contemporary",
                "adult hits", "easy listening"
            ],
        
            .country: ["country", "bluegrass", "americana", "honky tonk"],
        
            .metal: [
                "metal", "heavy metal"
            ],
        
            .soul: [
                "soul", "rnb", "r&b"
            ],
        
            .indie: [
                "indie", "alternative", "alternative rock"
            ],
        
            .sports: [
                "sports", "sport", "deportes"
            ],
        
            .reggae: ["reggae", "dub", "ska", "dancehall"],
        
            .tv: [
                "tv", "television", "video", "stream",
                "broadcast", "live tv", "tv station",
                "canal", "canal tv", "televisión",
                "noticias tv", "news tv", "music tv",
                "video stream", "m3u8"
            ]
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
