//
//  SoundEqualizerView.swift
//  Musak
//
//  Created by Ringo Wathelet on 2026/09/28.
//
import SwiftUI


struct SoundEqualizerControl: View {
    @Environment(PlayerManager.self) private var playerManager
    
    
    var body: some View {
        @Bindable var playerManager = playerManager
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Text("Preset").font(.title2).padding(.bottom, 5)
                    Picker("", selection: $playerManager.selectedPreset) {
                        ForEach(Preset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 360)

                    Text("dB").font(.title3).offset(y: 30)
                    
                    ScrollView(.horizontal) {
                        HStack(alignment: .center, spacing: 12) {
                            ForEach(playerManager.equalizerBands) { band in
                                VStack(spacing: 4) {
                                    Text("\(band.gain, specifier: "%.1f")")
                                        .font(.caption2)
                                        .monospacedDigit()
                                        .frame(height: 20)
                                    Slider(
                                        value: Binding(
                                            get: { playerManager.equalizerBands[band.id].gain },
                                            set: { playerManager.setCustomGain($0, at: band.id) }
                                        ),
                                        in: -12...12,
                                        step: 0.5
                                    )
                                    .frame(width: 320, height: 50)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 50, height: 320)
                                    Text(formatFrequency(band.frequency))
                                        .font(.caption2)
                                        .frame(height: 20)
                                }
                                .frame(width: 65, height: 370)
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func formatFrequency(_ frequency: Float) -> String {
        if frequency >= 1_000 {
            return "\(Int(frequency / 1_000)) kHz"
        } else {
            return "\(Int(frequency)) Hz"
        }
    }
}

