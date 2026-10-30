//
//  FilterToolsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/06.
//
import SwiftUI


struct FilterToolsView: View {
    @Environment(Selector.self) var selector
        
    var body: some View {
        @Bindable var selector = selector
        VStack {
            StationTagMenu()
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 2)
        }
    }
}

struct StationTagMenu: View {
    @Environment(Selector.self) var selector
    
    var body: some View {
        Menu {
            ForEach(StationTag.allCases) { tag in
                Button {
                    selector.tag = tag
                } label: {
                    HStack {
                        Text(tag.displayName)
                        if tag == selector.tag {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label(selector.tag.displayName, systemImage: "music.note.list")
        }
        .menuStyle(.button)
        .tint(.primary)
        .onChange(of: selector.tag) {
            selector.storeSettings()
        }
    }
}
