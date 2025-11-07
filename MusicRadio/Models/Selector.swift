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
    var view: ViewTypes = .favorites
    var filter: FilterTypes = .all
    var topCount: Int = 20
    var tag: StationTag = .all
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
    case favorites = "Favorites"
    case countries = "Countries"
    case stations = "Interesting"
    
    var id: String { rawValue }
    
    // Each type defines its own color scheme and emoji
    var gradient: [Color] {
        let opa = 0.5
        switch self {
        case .favorites: return [.pink.opacity(opa), .purple.opacity(opa)]
        case .stations: return [.blue.opacity(opa), .cyan.opacity(opa)]
        case .countries: return [.mint.opacity(opa), .mint.opacity(opa)]
        }
    }
    
    var icon: String {
        switch self {
            case .favorites: return "🎵"
            case .stations: return "📻"
            case .countries: return "🎙️"
        }
    }
    
    var description: String {
        switch self {
            case .favorites: return "Enjoy your favorite songs."
            case .stations: return "Interesting stations."
            case .countries: return "Check all countries radio stations."
        }
    }
}

enum StationTag: String, CaseIterable, Codable, Identifiable {
    case all
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

    /// User-friendly name for UI display
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
}
