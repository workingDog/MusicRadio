//
//  EqualizerView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI


struct EqualizerView: View {
    @Environment(ColorsModel.self) var colorsModel

    @State private var barHeights: [CGFloat] = [0.2, 0.5, 0.3, 0.7, 0.4, 0.2]
    @State private var lastTickTime: Date = .distantPast

    private let updateInterval: TimeInterval = 0.2
    private let animationDuration: TimeInterval = 0.3

    var body: some View {
        TimelineView(.periodic(from: .now, by: updateInterval)) { timeline in
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(barHeights.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: .infinity)
                        .frame(height: barHeights[i] * 34)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    colorsModel.equaliserColor.opacity(0.9),
                                    colorsModel.equaliserColor.opacity(0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask(RoundedRectangle(cornerRadius: 8))
                        )
                        .shadow(color: colorsModel.equaliserColor.opacity(0.35),
                                radius: 10, x: 0, y: 4)
                }
            }
            // Detect tick (new timeline date)
            .onChange(of: timeline.date) {
                // throttle updates to exactly one per 0.2s
                guard timeline.date.timeIntervalSince(lastTickTime) >= updateInterval * 0.9 else { return }
                lastTickTime = timeline.date

                // animate bar change
                withAnimation(.easeInOut(duration: animationDuration)) {
                    barHeights = barHeights.map { _ in CGFloat.random(in: 0.2...1.0) }
                }
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
    }
}
