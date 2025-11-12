//
//  RatingStarsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct RatingStarsView: View {
    @Environment(LooksModel.self) var looksModel
    
    let station: RadioStation
    let maxRating: Int
    
    @State private var stars: Int = 0
    
    init(_ station: RadioStation, _ maxRating: Int) {
        self.station = station
        self.maxRating = maxRating
    }
    
    var body: some View {
        HStack {
            ForEach(0..<stars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(looksModel.starColor)
            }
        }
        .offset(y: -6)
        .padding(.horizontal, 6)
        .onAppear {
            if station.votes <= 0 {
                station.votes = 1
            }
            let value = min(Double(station.votes) / Double(maxRating) * 5.0, 5.0)
            stars = Int(value.rounded(.up))
        }
    }
}
