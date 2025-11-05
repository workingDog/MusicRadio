//
//  PopularView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct PopularView: View {
    let maxValue: Double = 10000.0
    let station: RadioStation
    let clampedValue: Double
    
    init(_ station: RadioStation) {
        self.station = station
        let count = station.clickcount != nil ? Double(station.clickcount!) : 0
        self.clampedValue = Double(station.votes).isFinite
        ? min(max(count, 0), self.maxValue)
        : 0
    }
    
    var body: some View {
        ProgressView(value: clampedValue, total: maxValue)
            .padding(.horizontal, 10)
    }
}

