//
//  SwiftDataHelper.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import Foundation
import SwiftData


class SwiftDataHelper {
    
    static func updateOrInsert(station: RadioStation, in context: ModelContext) {
        var descriptor = FetchDescriptor<RadioStation>(
            predicate: #Predicate { $0.stationuuid == station.stationuuid }
        )
        descriptor.fetchLimit = 1
        
        // if already in SwiftData
        if let existing = try? context.fetch(descriptor).first {
            existing.isFavourite = station.isFavourite
            print("------> existing: \(station.isFavourite)")
            return
        } else {
            print("------> inserting")
            // else insert this station in SwiftData
            context.insert(station)
        }
    }
    
    static func findAndRemove(station: RadioStation, in context: ModelContext) {
        var descriptor = FetchDescriptor<RadioStation>(
            predicate: #Predicate { $0.stationuuid == station.stationuuid }
        )
        descriptor.fetchLimit = 1
        
        // if already in SwiftData
        if let existing = try? context.fetch(descriptor).first {
            context.delete(station)
        }
    }

}
