//
//  RatingLineView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/05.
//
import SwiftUI


struct RatingLineView: View {
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
                    .foregroundColor(.yellow)
            }
        }
        .offset(y: -8)
        .padding(.horizontal, 6)
        .onAppear {
            let value = min(Double(station.votes) / Double(maxRating) * 5.0, 5.0)
            stars = Int(value.rounded(.up))
            //print("---> maxRating: \(maxRating) station.votes: \(station.votes) value: \(value.rounded(.up))  stars: \(stars)")
        }
    }
}
