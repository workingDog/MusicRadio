//
//  EqualizerView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI


struct EqualizerView: View {
    @State private var barHeights: [Double] = [0.2, 0.5, 0.3, 0.7, 0.4, 0.2, 0.5]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<barHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.tint)
                    .frame(width: 6, height: 35 * barHeights[index])
                    .scaleEffect(y: barHeights[index], anchor: .bottom)
                    .animation(.easeInOut(duration: 0.3), value: barHeights[index])
            }
        }
        .frame(height: 45, alignment: .bottom)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                withAnimation {
                    barHeights = barHeights.map { _ in Double.random(in: 0.2...1.0) }
                }
            }
        }
    }
}
