//
//  EqualizerService.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/10/29.
// from: https://github.com/dimitris-c/AudioStreaming
//
import AVFoundation
import AVFAudio


@MainActor
final class EqualizerService {
    private let playerService: AudioPlayerService
    private var eqUnit: AVAudioUnitEQ

    private(set) var isActivated = false

    init(playerService: AudioPlayerService, frequencies: [Float] = [
        32, 63, 125, 250, 500,
        1_000, 2_000, 4_000, 8_000, 16_000
    ]) {
        self.playerService = playerService
        eqUnit = AVAudioUnitEQ(numberOfBands: frequencies.count)

        for (index, frequency) in frequencies.enumerated() {
            let band = eqUnit.bands[index]
            band.bypass = false
            band.filterType = .parametric
            band.frequency = frequency
            band.bandwidth = 1
            band.gain = 0
        }
    }

    var bands: [AVAudioUnitEQFilterParameters] {
        eqUnit.bands
    }

    func update(gain: Float, for index: Int) {
        guard eqUnit.bands.indices.contains(index) else { return }
        eqUnit.bands[index].gain = gain
    }

    func reset() {
        eqUnit.bands.forEach { $0.gain = 0 }
    }

    func activate() {
        guard !isActivated else { return }
        playerService.add(eqUnit)
        isActivated = true
    }

    func deactivate() {
        guard isActivated else { return }
        playerService.remove(eqUnit)
        isActivated = false
    }
}
