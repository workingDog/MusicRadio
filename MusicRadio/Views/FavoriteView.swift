//
//  FavoriteView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct FavoriteView: View {
    @Environment(AudioPlayerModel.self) var audioPlayer
    @Environment(SelectionModel.self) var selector
    
    @Query(filter: #Predicate<RadioStation> { $0.isFavourite })
    private var stations: [RadioStation]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        BaseStationView(stations: stations, columns: columns)
    }
}
