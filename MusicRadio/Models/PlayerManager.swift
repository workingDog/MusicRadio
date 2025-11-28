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


@MainActor
@Observable
class PlayerManager {
    
    var station: RadioStation?
    var isPlaying = false
    var currentSong: String = ""
    
    private var metadataOutput: AVPlayerItemMetadataOutput?
    var radio: RadioPlayer?
    
    init() {
        Task {
            await keepPlayInBackground()
        }
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
            try session.setActive(true)
        } catch {
            print("---> AudioSession error:", error)
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
