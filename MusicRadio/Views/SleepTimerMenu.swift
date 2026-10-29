//
//  SleepTimerMenu.swift
//  MusicPlayer
//
//  Created by Ringo Wathelet on 2026/10/01.
//
import SwiftUI


struct SleepTimerMenu: View {

    @State private var sleepTimer: SleepTimerManager
    
    init(playerManager: PlayerManager) {
        _sleepTimer = State(wrappedValue: SleepTimerManager(playerManager: playerManager))
    }

    var body: some View {
        Menu {
            ForEach(SleepTimerOption.allCases) { option in
                Button {
                    sleepTimer.select(option)
                } label: {
                    HStack {
                        Text(option.title).font(.title3)
                        Spacer()
                        if sleepTimer.selectedOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label(sleepTimer.selectedOption.title, systemImage: "moon.zzz").font(.title3)
        }
    }
}

