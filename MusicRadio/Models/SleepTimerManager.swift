//
//  SleepTimerManager.swift
//  MusicPlayer
//
//  Created by Ringo Wathelet on 2026/10/01.
//
import SwiftUI


enum SleepTimerOption: CaseIterable, Identifiable {
    case none
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case fortyFiveMinutes
    case oneHour
    
    var id: Self { self }
    
    var title: String {
        switch self {
            case .none: "No Setting"
            case .fiveMinutes: "5 Minutes"
            case .fifteenMinutes: "15 Minutes"
            case .thirtyMinutes: "30 Minutes"
            case .fortyFiveMinutes: "45 Minutes"
            case .oneHour: "1 Hour"
        }
    }
    
    var duration: Duration? {
        switch self {
            case .none: nil
            case .fiveMinutes: .seconds(5 * 60)
            case .fifteenMinutes: .seconds(15 * 60)
            case .thirtyMinutes: .seconds(30 * 60)
            case .fortyFiveMinutes: .seconds(45 * 60)
            case .oneHour: .seconds(60 * 60)
        }
    }
}

@MainActor
@Observable
final class SleepTimerManager {
    
    private let playerManager: PlayerManager
    
    private(set) var selectedOption: SleepTimerOption = .none
    
    private var timerTask: Task<Void, Never>?
    
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
    }
    
    func select(_ option: SleepTimerOption) {
        timerTask?.cancel()
        timerTask = nil
        
        selectedOption = option
        
        guard let duration = option.duration else {
            return
        }

        timerTask = Task { @MainActor [weak self] in
            guard let self else {
                print("SleepTimerManager no longer exists")
                return
            }
            
            do {
                try await Task.sleep(for: duration)
            } catch {
                print("Sleep timer cancelled")
                self.timerTask = nil
                return
            }
            
            guard !Task.isCancelled else {
                self.timerTask = nil
                return
            }

            self.stopPlayback()
            
            // Break the manager/task retain cycle after completion.
            self.timerTask = nil
        }
    }
    
    func cancel() {
        timerTask?.cancel()
        timerTask = nil
        selectedOption = .none
    }
    
//    func trackDidFinish() {
//        guard selectedOption == .endOfTrack else {
//            return
//        }
//        stopPlayback()
//        selectedOption = .none
//    }
    
    private func stopPlayback() {
        playerManager.stop()
    }
}
