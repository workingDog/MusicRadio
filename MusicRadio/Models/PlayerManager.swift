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
        preset = Preset(rawValue: defaults.string(forKey: "audioPreset") ?? "") ?? .custom
        audio.delegate = self
        equalizer.activate()
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

        if selectedPreset != .custom {
            selectedPreset = .custom
        }

        audioBands[index].gain = gain
        equalizer.update(gain: gain, for: index)
        saveCustomGains()
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














/*
 
@MainActor
@Observable
final class PlayerManager: NSObject, AudioPlayerDelegate {
    
    var station: RadioStation?
    var isPlaying = false
    var currentSong = ""
    var errorMessage: String?
    
    private(set) var equalizerBands: [Band] = []
    
    var selectedPreset: Preset = .custom {
        didSet {
            guard oldValue != selectedPreset else { return }
            applyPreset(selectedPreset)
            UserDefaults.standard.set(selectedPreset.rawValue, forKey: "audioPreset")
        }
    }
    
    var currentTime: Double {
        guard let player = player else { return 0 }
        return player.progress
    }
    
    @ObservationIgnored var player: AudioPlayer?
    @ObservationIgnored var equalizer: AVAudioUnitEQ?
    
    private let frequencies: [Float] = [32, 63, 125, 250, 500, 1_000, 2_000, 4_000, 8_000, 16_000]
    
    private let defaults = UserDefaults.standard

    override init() {
        super.init()
        equalizerBands = frequencies.enumerated().map {
            Band(id: $0.offset, frequency: $0.element, gain: 0)
        }
        let savedPreset = defaults.string(forKey: "audioPreset")
        selectedPreset = Preset(rawValue: savedPreset ?? "") ?? .custom
        configureEqualizer()
    }

    private func configureEqualizer() {
        let eq = AVAudioUnitEQ(numberOfBands: frequencies.count)
        for (index, band) in eq.bands.enumerated() {
            band.frequency = frequencies[index]
            band.bandwidth = 1
            band.filterType = .parametric
            band.gain = 0
            band.bypass = false
        }
        equalizer = eq
        loadCustomGains()
        applyPreset(selectedPreset)
    }

    private func createPlayer() {
        guard let equalizer else { return }
        let audioPlayer = AudioPlayer()
        audioPlayer.delegate = self
        audioPlayer.attach(node: equalizer)
        player = audioPlayer
    }

    func setStation(_ radioStation: RadioStation) {
        stop()
        guard let url = URL(string: radioStation.url) else {
            errorMessage = "Invalid station URL."
            return
        }
        station = radioStation
        currentSong = ""
        errorMessage = nil
        createPlayer()
        player?.play(url: url)
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        guard let player else { return }
        player.resume()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    func setCustomGain(_ gain: Float, at index: Int) {
        guard equalizerBands.indices.contains(index),
              let equalizer,
              equalizer.bands.indices.contains(index) else { return }
        equalizerBands[index].gain = gain
        equalizer.bands[index].gain = gain
        selectedPreset = .custom
        saveCustomGains()
    }

    private func applyPreset(_ preset: Preset) {
        let gains: [Float]
        if preset == .custom {
            gains = loadCustomGains()
        } else {
            gains = preset.gains
        }
        guard let equalizer else { return }
        for (index, gain) in gains.enumerated() where equalizerBands.indices.contains(index) {
            equalizerBands[index].gain = gain
            equalizer.bands[index].gain = gain
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
        guard let data = try? JSONEncoder().encode(equalizerBands.map(\.gain)) else { return }
        defaults.set(data, forKey: "customEQGains")
    }

    func audioPlayerDidStartPlaying(player: AudioPlayer, with entryId: AudioEntryId) {
        Task { @MainActor in
            self.isPlaying = true
        }
    }

    func audioPlayerDidFinishBuffering(player: AudioPlayer, with entryId: AudioEntryId) {}

    func audioPlayerStateChanged(player: AudioPlayer, with newState: AudioPlayerState, previous: AudioPlayerState) {
        // The library reports state changes here.
    }

    func audioPlayerDidFinishPlaying(player: AudioPlayer, entryId: AudioEntryId, stopReason: AudioPlayerStopReason, progress: Double, duration: Double) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }

    func audioPlayerUnexpectedError(player: AudioPlayer, error: AudioPlayerError) {
        Task { @MainActor in
            self.errorMessage = String(describing: error)
            self.isPlaying = false
        }
    }

    func audioPlayerDidCancel(player: AudioPlayer, queuedItems: [AudioEntryId]) {}

    func audioPlayerDidReadMetadata(player: AudioPlayer, metadata: [String: String]) {
        Task { @MainActor in
            if let title = metadata.first(where: { $0.key.localizedCaseInsensitiveContains("title") })?.value {
                self.currentSong = title
            }
        }
    }
}





@MainActor
@Observable
class PlayerManager1 {
    
    let audio = AudioController()
    
    var station: RadioStation?
    var isPlaying = false
    var currentSong: String = ""
    
    private var metadataOutput: AVPlayerItemMetadataOutput?
    var radio: RadioPlayer?
    
    var currentTime: Double {
        guard let player = radio?.player else { return 0 }
        return player.currentTime().seconds
    }
    
    var equalizerBands: [Band] {
        audio.bands
    }

    var selectedPreset: Preset {
        get { audio.selectedPreset }
        set { audio.apply(newValue)}
    }
    
    private var customGains: [Float] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "customEQGains"),
                  let gains = try? JSONDecoder().decode([Float].self, from: data) else {
                return Array(repeating: 0, count: audio.bands.count)
            }
            return gains
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: "customEQGains")
        }
    }
    
    init() {
        Task {
            await keepPlayInBackground()
        }
    }
    
    func setCustomGain(_ gain: Float, at index: Int) {
        audio.setGain(gain, at: index)
        customGains = audio.bands.map(\.gain)
    }

    // call this for every new station
    func setStation(_ radioStation: RadioStation) {
        self.station = radioStation
        if let station = station {
            guard let url = URL(string: station.url) else { return }
            radio = RadioPlayer(observer: self)
            radio?.playStream(url: url)
        }
    }
    
    func togglePlayback() {
        guard let player = radio?.player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func play() {
        radio?.player?.play()
        isPlaying = true
    }
    
    func pause() {
        radio?.stop()
        isPlaying = false
    }
    
    func stop() {
        pause()
        station = nil
    }
    
    func keepPlayInBackground() async {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try await session.activate(options: [])
        } catch {
            AppLogger.logPublic("AudioSession error", error)
        }
    }

}

// To get the song title
class RadioPlayer: NSObject, AVPlayerItemMetadataOutputPushDelegate, @unchecked Sendable {
    var player: AVPlayer?
    var metadataOutput: AVPlayerItemMetadataOutput?
    weak var observer: PlayerManager?
    
    init(observer: PlayerManager) {
        self.observer = observer
        super.init()
    }
    
    func playStream(url: URL) {
        let item = AVPlayerItem(url: url)
        let output = AVPlayerItemMetadataOutput()
        output.setDelegate(self, queue: .main) 
        item.add(output)
        metadataOutput = output
        player = AVPlayer(playerItem: item)
 //       player?.allowsExternalPlayback = false
    }

    func stop() {
        player?.pause()
        player = nil
        metadataOutput = nil
    }
    
    // get the title of the song
    func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                        didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                        from track: AVPlayerItemTrack?) {
        // Delegate runs on main queue, safe to update observable
        for group in groups {
            for item in group.items {
                Task { @MainActor in
                    if let key = item.identifier?.rawValue.lowercased(),
                       key.contains("title"),
                       let title = try? await item.load(.value) as? String {
                        await MainActor.run {
                            observer?.currentSong = title
                        }
                        return
                    }
                }
            }
        }
    }
   
}


*/
