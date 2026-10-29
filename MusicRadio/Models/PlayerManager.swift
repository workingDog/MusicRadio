//
//  PlayerManager.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI
import AVKit
import AVFoundation
import AVFAudio
import AudioStreaming


@MainActor
@Observable
final class PlayerManager {
    
    var videoPlayer: AVPlayer?

    let audio: AudioPlayerService
    let equalizer: EqualizerService

    var station: RadioStation?
    var isPlaying = false
    var currentSong = ""
    var errorMessage: String?

    var equalizerBands: [Band] {
        audioBands
    }

    private var audioBands: [Band] = []

    var selectedPreset: Preset {
        get { preset }
        set {
            guard preset != newValue else { return }
            preset = newValue
            applyPreset(newValue)
            UserDefaults.standard.set(newValue.rawValue, forKey: "audioPreset")
        }
    }

    private var preset: Preset = .custom
    
    var isPresetModified: Bool {
        guard selectedPreset != .custom else { return false }
        return audioBands.map(\.gain) != selectedPreset.gains
    }

    private let frequencies: [Float] = [
        32, 63, 125, 250, 500,
        1_000, 2_000, 4_000, 8_000, 16_000
    ]
    
    var currentTime: Double {
        audio.progress
    }

    private let defaults = UserDefaults.standard

    init() {
        audio = AudioPlayerService(
            audioPlayerProvider: {
                AudioPlayer(
                    configuration: .init(
                        flushQueueOnSeek: false,
                        enableLogs: true
                    )
                )
            }
        )
        equalizer = EqualizerService(playerService: audio, frequencies: frequencies)
        audioBands = frequencies.enumerated().map {
            Band(id: $0.offset, frequency: $0.element, gain: 0)
        }

        audio.delegate = self
        equalizer.activate()
        
        let savedPreset = defaults.string(forKey: "audioPreset")
            .flatMap(Preset.init(rawValue:)) ?? .custom

        preset = savedPreset
        applyPreset(savedPreset)
    }

    func setStation(_ radioStation: RadioStation) {
        guard let url = URL(string: radioStation.url) else {
            errorMessage = "Invalid station URL."
            return
        }
        audio.stop()
        station = radioStation
        currentSong = ""
        errorMessage = nil
        audio.play(url: url)
    }
    
    func playVideo(url: URL) {
        videoPlayer?.pause()
        videoPlayer = AVPlayer(url: url)
        videoPlayer?.play()
    }
    
    func stopVideo() {
        videoPlayer?.pause()
        videoPlayer = nil
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        guard station != nil else { return }
        audio.resume()
    }

    func pause() {
        audio.pause()
        isPlaying = false
    }

    func stop() {
        audio.stop()
        station = nil
        currentSong = ""
        isPlaying = false
    }
    
    func setCustomGain(_ gain: Float, at index: Int) {
        guard audioBands.indices.contains(index) else { return }
        audioBands[index].gain = gain
        equalizer.update(gain: gain, for: index)
        if selectedPreset == .custom {
            saveCustomGains()
        }
    }
    
    private func applyPreset(_ preset: Preset) {
        let gains = preset == .custom ? loadCustomGains() : preset.gains

        for (index, gain) in gains.enumerated() where audioBands.indices.contains(index) {
            audioBands[index].gain = gain
            equalizer.update(gain: gain, for: index)
        }
    }

    private func loadCustomGains() -> [Float] {
        guard let data = defaults.data(forKey: "customEQGains"),
              let gains = try? JSONDecoder().decode([Float].self, from: data),
              gains.count == frequencies.count else {
            return Preset.custom.gains
        }

        return gains
    }

    private func saveCustomGains() {
        guard let data = try? JSONEncoder().encode(audioBands.map(\.gain)) else { return }
        defaults.set(data, forKey: "customEQGains")
    }
}

extension PlayerManager: AudioPlayerServiceDelegate {
    
    func didStartPlaying(id: AudioEntryId) {
        isPlaying = true
    }

    func didStopPlaying(id: AudioEntryId, reason: AudioPlayerStopReason) {
        isPlaying = false
    }

    func statusChanged(status: AudioPlayerState) {
        isPlaying = status == .playing
    }

    func errorOccurred(error: AudioPlayerError) {
        errorMessage = String(describing: error)
        isPlaying = false
    }

    func metadataReceived(metadata: [String: String]) {
        if let title = metadata.first(where: {
            $0.key.localizedCaseInsensitiveContains("title")
        })?.value {
            currentSong = title
        }
    }
}
