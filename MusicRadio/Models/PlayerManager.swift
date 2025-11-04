//
//  AudioPlayerModel.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI
import AVKit
import AVFoundation
import Combine


@MainActor
@Observable
class PlayerManager {
    
    var station: RadioStation?
    var isPlaying = false
    var progress: Double = 0
    var volume: Float = 0.5
    var currentSong: String = ""
    
    private var metadataOutput: AVPlayerItemMetadataOutput?
    private var radio: RadioPlayer?
    
    
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
    
    func updateVolume(_ newValue: Double) {
        volume = Float(newValue)
        radio?.player?.volume = volume
    }
    
}

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
        output.setDelegate(self, queue: .main) // main queue is safe
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




/*
 
 
 @MainActor
 @Observable
 class PlayerManager {
     
     var station: RadioStation?
     var player: AVPlayer?
     var isPlaying = false
     var progress: Double = 0
     var volume: Float = 0.5
     
     
     func setStation(_ radioStation: RadioStation) {
         self.station = radioStation
         if let station = station {
             guard let url = URL(string: station.url) else { return }
             print("---> station url: \(url.absoluteString)")
             player = AVPlayer(url: url)
         }
     }
     
     func togglePlayback() {
         guard let player else { return }
         if isPlaying {
             player.pause()
         } else {
             player.play()
         }
         isPlaying.toggle()
     }
     
     func play(url: URL) {
         if player == nil {
             player = AVPlayer(url: url)
         }
         player?.play()
         isPlaying = true
     }
     
     func play() {
         player?.play()
         isPlaying = true
     }
     
     func pause() {
         player?.pause()
         isPlaying = false
     }
  
 }
 
 */
