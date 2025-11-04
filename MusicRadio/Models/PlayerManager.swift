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


/*
 
 in my SwiftUI code I have a "player = AVPlayer(url: url)", how to I add a volume control to this player?
 
 */

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
