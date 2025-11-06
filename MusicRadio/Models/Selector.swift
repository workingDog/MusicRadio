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
}

enum FilterTypes: String, CaseIterable, Identifiable {
    case topRated = "Top rated"
    case all = "All"
    
    var id: String { rawValue }
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



