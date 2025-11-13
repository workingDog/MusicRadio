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
    @State private var timer: Timer?

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(barHeights.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .frame(maxWidth: .infinity)
                    .frame(height: barHeights[i] * 34)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [colorsModel.equaliserColor.opacity(0.90), colorsModel.equaliserColor.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    )
                    .shadow(color: colorsModel.equaliserColor.opacity(0.35), radius: 10, x: 0, y: 4)
                    .animation(.easeInOut(duration: 0.3), value: barHeights[i])
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .onAppear {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                withAnimation {
                    barHeights = barHeights.map { _ in CGFloat.random(in: 0.2...1.0) }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}
