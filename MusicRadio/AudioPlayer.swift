//
//  AudioPlayer.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftData
import SwiftUI
import AVKit


@Observable
class AudioPlayer {
    var player: AVPlayer?
    var isPlaying = false

    func play(url: URL) {
        if player == nil {
            player = AVPlayer(url: url)
        }
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func togglePlayPause(url: URL) {
        if isPlaying {
            pause()
        } else {
            play(url: url)
        }
    }

}
