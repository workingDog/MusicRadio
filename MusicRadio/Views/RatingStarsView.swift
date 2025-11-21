//
//  RatingStarsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct RatingStarsView: View {
    @Environment(ColorsModel.self) var colorsModel
    
    let station: RadioStation
    let maxRating: Int
    
    @State private var stars: Int = 1
    
    init(_ station: RadioStation, _ maxRating: Int) {
        self.station = station
        self.maxRating = maxRating
    }
    
    var body: some View {
        HStack {
            ForEach(0..<stars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(colorsModel.starColor)
            }
        }
        .offset(y: -6)
        .padding(.horizontal, 6)
        .onAppear {
            if station.votes <= 0 { station.votes = 1 }
            let maxVal = maxRating <= 0 ? 1.0 : Double(maxRating)
            let value = min(Double(station.votes) / maxVal * 5.0, 5.0)
            stars = Int(value.rounded(.up))
        }
    }
}
