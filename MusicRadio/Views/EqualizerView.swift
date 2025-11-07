//
//  EqualizerView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI


struct EqualizerView: View {
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
                            gradient: Gradient(colors: [Color.accentColor.opacity(0.95), Color.accentColor.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    )
                    .shadow(color: Color.accentColor.opacity(0.35), radius: 10, x: 0, y: 4)
                    .animation(.easeInOut(duration: 0.3), value: barHeights[i])
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.03), Color.clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    )
            } else {
                // fallback for older platforms
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.80))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
            }
        }
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


struct EqualizerView2: View {
    @State private var barHeights: [Double] = [0.2, 0.5, 0.3, 0.7, 0.4, 0.2]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<barHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 22)
                    .fill(.tint)
                 //   .frame(width: 5, height: 35 * barHeights[index])
                    .scaleEffect(y: barHeights[index], anchor: .bottom)
                    .shadow(color: .orange.opacity(0.6), radius: 20, y: 10)
                    .animation(.easeInOut(duration: 0.3), value: barHeights[index])
            }
        }
   //     .frame(height: 45, alignment: .bottom)
        .contentShape(Rectangle())
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                withAnimation {
                    barHeights = barHeights.map { _ in Double.random(in: 0.2...1.0) }
                }
            }
        }
    }
}
