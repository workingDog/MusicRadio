//
//  AudioController.swift
//  Musak
//
//  Created by Ringo Wathelet on 2026/09/28.
//
import AVFoundation


struct Band: Identifiable {
    let id: Int
    let frequency: Float
    var gain: Float
}

enum Preset: String, CaseIterable, Identifiable {
    case custom = "Custom"
    case bassBoost = "Bass"
    case trebleBoost = "Treble"
    case vocal = "Vocal"
    case rock = "Rock"

    var id: Self { self }

    var gains: [Float] {
        switch self {
            case .custom: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            case .bassBoost: [8, 7, 5, 3, 1, 0, 0, 0, 0, 0]
            case .trebleBoost: [0, 0, 0, 0, 0, 1, 3, 5, 7, 8]
            case .vocal: [-3, -2, -1, 2, 4, 4, 3, 1, 0, -1]
            case .rock: [5, 4, 2, -1, -2, 1, 3, 5, 5, 4]
        }
    }
}
